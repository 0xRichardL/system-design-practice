#!/usr/bin/env node

// Read-only query tool for TechEmpower result JSON. It writes results to stdout.

const fs = require("node:fs");
const path = require("node:path");

const ERROR_FIELDS = ["5xx", "connect", "read", "write", "timeout"];

function usage(exitCode = 0) {
  const stream = exitCode === 0 ? process.stdout : process.stderr;
  stream.write(`Usage:
  node query-techempower.js <result.json> [options]

Options:
  --test <names>       Test keys, comma-separated (json,db,query,update)
  --id <names>         Configuration IDs, comma-separated
  --language <names>   Metadata languages, comma-separated
  --database <names>   Metadata databases, comma-separated
  --orm <names>        Metadata ORM classes, comma-separated
  --level <numbers>    Concurrency or query counts, comma-separated
  --best               Keep the highest-RPS row per configuration and test
  --sort <field>       id (default) or rps
  --format <format>    json (default) or table
  --list               List matching configuration metadata, without results
  --help               Show this help

Examples:
  node query-techempower.js round.json --test json --language go,javascript --best --sort rps --format table
  node query-techempower.js round.json --test query,update --level 10 --id gin,chi --format table
  node query-techempower.js round.json --list --language go --database postgres
`);
  process.exit(exitCode);
}

function values(value) {
  return new Set(value.split(",").map((item) => item.trim().toLowerCase()).filter(Boolean));
}

function parseArgs(argv) {
  const options = { filters: {}, format: "json", sort: "id", best: false, list: false };
  const positional = [];
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--help") usage();
    if (!argument.startsWith("--")) {
      positional.push(argument);
      continue;
    }
    if (argument === "--best") {
      options.best = true;
      continue;
    }
    if (argument === "--list") {
      options.list = true;
      continue;
    }
    const name = argument.slice(2);
    const value = argv[index + 1];
    if (!value || value.startsWith("--")) {
      throw new Error(`Missing value for ${argument}`);
    }
    index += 1;
    if (["test", "id", "language", "database", "orm", "level"].includes(name)) {
      options.filters[name] = values(value);
    } else if (name === "format") {
      options.format = value.toLowerCase();
    } else if (name === "sort") {
      options.sort = value.toLowerCase();
    } else {
      throw new Error(`Unknown option: ${argument}`);
    }
  }
  if (positional.length !== 1) throw new Error("Provide exactly one TechEmpower result JSON file");
  if (!["json", "table"].includes(options.format)) throw new Error("--format must be json or table");
  if (!["id", "rps"].includes(options.sort)) throw new Error("--sort must be id or rps");
  options.file = positional[0];
  return options;
}

function matches(value, allowed) {
  return !allowed || allowed.has(String(value).toLowerCase());
}

function levelsFor(source, test, rowCount) {
  if (["query", "update"].includes(test)) return source.queryIntervals;
  if (test === "cached-query") return source.cachedQueryIntervals;
  if (source.concurrencyLevels?.length === rowCount) return source.concurrencyLevels;
  return Array.from({ length: rowCount }, (_, index) => index + 1);
}

function query(source, options) {
  const metadata = new Map(source.testMetadata.map((item) => [item.name, item]));
  const selectedMetadata = [...metadata.values()].filter((item) =>
    matches(item.name, options.filters.id) &&
    matches(item.language, options.filters.language) &&
    matches(item.database, options.filters.database) &&
    matches(item.orm, options.filters.orm)
  );

  if (options.list) {
    return selectedMetadata.map(({ name, display_name, language, framework, database, orm }) => ({
      id: name,
      displayName: display_name,
      language,
      framework,
      database,
      orm,
    }));
  }

  const selectedIds = new Set(selectedMetadata.map((item) => item.name));
  const tests = Object.keys(source.rawData).filter((test) => matches(test, options.filters.test));
  const records = [];
  for (const test of tests) {
    for (const [id, rows] of Object.entries(source.rawData[test])) {
      if (!selectedIds.has(id)) continue;
      const meta = metadata.get(id);
      const levels = levelsFor(source, test, rows.length);
      rows.forEach((row, index) => {
        const level = levels[index] ?? index + 1;
        if (!matches(level, options.filters.level)) return;
        const errors = ERROR_FIELDS.reduce((total, field) => total + (row[field] ?? 0), 0);
        const successfulRequests = row.totalRequests - errors;
        records.push({
          id,
          test,
          language: meta.language,
          database: meta.database,
          orm: meta.orm,
          level,
          levelType: ["query", "update", "cached-query"].includes(test) ? "queryCount" : "concurrency",
          totalRequests: row.totalRequests,
          errors,
          successfulRequests,
          requestsPerSecond: Math.round(successfulRequests / source.duration),
          averageLatency: row.latencyAvg,
        });
      });
    }
  }

  const result = options.best
    ? [...records.reduce((groups, record) => {
        const key = `${record.test}\0${record.id}`;
        const current = groups.get(key);
        if (!current || record.requestsPerSecond > current.requestsPerSecond) groups.set(key, record);
        return groups;
      }, new Map()).values()]
    : records;

  result.sort(options.sort === "rps"
    ? (left, right) => right.requestsPerSecond - left.requestsPerSecond
    : (left, right) => left.id.localeCompare(right.id) || left.test.localeCompare(right.test) || left.level - right.level);
  return result;
}

try {
  const options = parseArgs(process.argv.slice(2));
  const file = path.resolve(options.file);
  const source = JSON.parse(fs.readFileSync(file, "utf8"));
  if (!source.rawData || !source.testMetadata || !source.duration) {
    throw new Error("File does not look like a TechEmpower result JSON document");
  }
  const result = query(source, options);
  if (options.format === "table") console.table(result);
  else process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
} catch (error) {
  process.stderr.write(`Error: ${error.message}\n\n`);
  usage(1);
}
