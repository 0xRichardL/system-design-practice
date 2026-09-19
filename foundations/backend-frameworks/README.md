# Backend framework research

Each research pass has its own dated folder. Keep the raw references and one self-contained report together so later passes can revisit the analysis without changing earlier results.

## Two-step workflow

1. **Collect references.** Create a dated folder such as `sep_2026`. Save the raw benchmark response under `references/` without editing it. Record the URL, retrieval date, checksum, physical or cloud environment, run ID, source commit, and implementation links in `references/sources.md`.
2. **Query and report.** Use `query-techempower.js` to inspect and filter the saved JSON. Calculate and cross-check the selected results, then write the measurements and interpretation into that run's `report.md`. The query tool only reads JSON and prints to stdout; it does not generate or modify the report.

Examples, run from this folder:

```sh
node query-techempower.js sep_2026/references/techempower-r23-physical.json --test json --language go,javascript,typescript --best --sort rps --format table
node query-techempower.js sep_2026/references/techempower-r23-physical.json --test query,update --level 10 --id gin,chi --format table
node query-techempower.js sep_2026/references/techempower-r23-physical.json --list --language go --database postgres
```

Run `node query-techempower.js --help` for all filters. The JSON path is an argument, so the same tool works with future dated folders and benchmark rounds.

For database comparisons, inspect the benchmark endpoint code at the recorded commit. Record the actual client or ORM, database, and query/update path with a source link in the run's references. Only rank configurations when all three match for that test. Leave unverified implementations visible in the report without a rank. A benchmark's `raw`/`full` ORM field alone does not establish a match. If a later pass uses a new data source or different test definitions, document its calculation rather than silently combining results.

| Research pass | References | Report |
| --- | --- | --- |
| September 2026 (`sep_2026`) | [Source inventory](sep_2026/references/sources.md) | [Go and Node.js Round 23 report](sep_2026/report.md) |

Create a new sibling folder for the next pass. If more than one pass happens in a month, include the day in its folder name.
