# September 2026 reference inventory

## Raw benchmark snapshot

| Source | Saved file | Retrieved | SHA-256 |
| --- | --- | --- | --- |
| [TechEmpower Round 23 physical-server JSON](https://www.techempower.com/benchmarks/results/round23/ph.json) | [techempower-r23-physical.json](techempower-r23-physical.json) | 2026-09-18 | `9300a12950f64852af228556e342896e971122cf821433382d7f8b6d432c1023` |

The snapshot identifies run `91a66052-9d86-446c-b31a-eadbd669ed08` and benchmark source commit [`523534bb61450e3522d775a749ad060753e26e3a`](https://github.com/TechEmpower/FrameworkBenchmarks/tree/523534bb61450e3522d775a749ad060753e26e3a). The source file is retained unchanged. The sibling [report](../report.md) contains the selected measurements and interpretation.

## Interpretation references

| Reference | Used for |
| --- | --- |
| [TechEmpower test definitions](https://github.com/TechEmpower/FrameworkBenchmarks/wiki/Project-Information-Framework-Tests-Overview) | Test behavior, concurrency, and query counts. |
| [TechEmpower results explanation](https://github.com/TechEmpower/FrameworkBenchmarks/wiki/Project-Information-Results-Website) | Successful-request calculation and error meaning. |
| [Round 23 announcement](https://www.techempower.com/blog/2025/03/17/framework-benchmarks-round-23/) | Publication context and hardware change. |
| [Round 23 Express configuration](https://github.com/TechEmpower/FrameworkBenchmarks/blob/523534bb61450e3522d775a749ad060753e26e3a/frameworks/JavaScript/express/benchmark_config.json) and [Postgres.js documentation](https://github.com/porsager/postgres) | The `express-postgresjs` variant is labeled `orm=Full` by TechEmpower, while Postgres.js describes itself as a PostgreSQL client. |
| [Round 23 Nest configuration](https://github.com/TechEmpower/FrameworkBenchmarks/blob/523534bb61450e3522d775a749ad060753e26e3a/frameworks/TypeScript/nest/benchmark_config.json) and [package file](https://github.com/TechEmpower/FrameworkBenchmarks/blob/523534bb61450e3522d775a749ad060753e26e3a/frameworks/TypeScript/nest/package.json) | The Express and Fastify variants are both labeled PostgreSQL/`full`; the package declares TypeORM and `pg`. |

The JSON's `testMetadata.orm` field contains a broad `raw` or `full` classification, not a verified ORM name for every configuration. The links above establish specific implementation details only where stated. Naming a variant `gorm` or declaring TypeORM as a package dependency does not by itself prove which library each benchmark endpoint uses. Other database drivers and ORMs in the report have not been individually verified in this pass. Database throughput is therefore displayed without a rank.

## Gaps retained in this pass

- The [report's learning-curve table](../report.md#learning-curve) links the official framework documentation used for qualitative judgments. Those live pages were not frozen as source files.
- No comparable memory and startup measurements were found for the selected configurations, so runtime footprint remains unranked.
- Framework convention strength and API versioning are not TechEmpower measurements. A decision that depends on them needs separate, cited capability research.
