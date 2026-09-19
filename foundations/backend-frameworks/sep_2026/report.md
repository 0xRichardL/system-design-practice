# Go and Node.js backend performance: TechEmpower Round 23

This [September 2026 research pass](../README.md) is a reference for choosing which backend stacks deserve closer evaluation. It compares **tested configurations**, not framework overhead in isolation. It contains the selected measurements, calculation checks, and interpretation in one document. The [reference inventory](references/sources.md) records the raw source and implementation evidence.

## Source and method

- The [Round 23 results page](https://www.techempower.com/benchmarks/#section=data-r23) is dated **2025-02-24**. TechEmpower's [announcement](https://www.techempower.com/blog/2025/03/17/framework-benchmarks-round-23/) appeared **2025-03-17**. The [benchmark repository](https://github.com/TechEmpower/FrameworkBenchmarks) was archived in 2026.
- This pass uses only the saved [physical-server JSON](references/techempower-r23-physical.json), run `91a66052-9d86-446c-b31a-eadbd669ed08`, source commit `523534bb61450e3522d775a749ad060753e26e3a`. Its SHA-256 is recorded in the reference inventory. The reusable [JavaScript query tool](../query-techempower.js) was used to filter and recalculate rows; it does not generate this report.
- Successful requests/s = `(totalRequests − 5xx − connect − read − write − timeout errors) / 15`, rounded to a whole number. The 15 seconds come from the configured sample duration; second-resolution start/end timestamps sometimes differ by 16. Missing error fields count as zero. The source's `latencyAvg` is copied as reported; request totals cannot reconstruct an average or tail latency. [TechEmpower's results explanation](https://github.com/TechEmpower/FrameworkBenchmarks/wiki/Project-Information-Results-Website).
- JSON and single-query entries use each configuration's highest successful requests/s across concurrency 16–512. Multiple-query and update entries show counts 1, 5, 10, 15, and 20 at concurrency 512. [TechEmpower test definitions](https://github.com/TechEmpower/FrameworkBenchmarks/wiki/Project-Information-Framework-Tests-Overview).

## How to read the tests

| Test | Useful signal | Main limit |
| --- | --- | --- |
| [JSON serialization](#json-serialization) | Small-response HTTP/serialization capacity; throughput ranked within this selected set. | No database or business logic. |
| [Single database query](#single-database-query) | Basic database-backed read path. | Database client and query implementation differ. |
| [Multiple database queries](#multiple-database-queries) | How throughput changes from 1 to 20 separate reads; 10-query is a convenient reference point. | Test forbids one combined `IN` query; real endpoints may batch. |
| [Database updates](#database-updates) | How a simple read-and-write path changes from 1 to 20 rows; 10-query is a convenient reference point. | Bulk-update and transaction strategies differ. |

The JSON table has a throughput rank because the test has no database path. **Database tables deliberately have no rank yet.** TechEmpower's `raw`/`full` field is a broad classification, not an ORM or client identity. For example, `express-postgresjs` is labeled `full` while its named Postgres.js library is a client. The Nest package declares TypeORM and `pg`, but this pass has not confirmed its endpoint path. The access column states what the checked evidence supports; `unverified` is an explicit research gap. A database comparison can be ranked only after confirming the same database, access library, and test path from the benchmark implementation. A larger requests/s number in the displayed tables does not by itself measure a framework difference.

The tables mark missing tests **unavailable**. Beego, Iris, and AdonisJS are absent from this Round 23 physical-server snapshot. For any production shortlist, separately assess conventions, versioning, validation, documentation, and the actual application workload; TechEmpower does not measure those capabilities.

## Selected configurations and coverage

| Ecosystem | Configuration | Database | TFB ORM class | Actual access library / evidence status | JSON | Single | Multiple | Updates |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Go | Go net/http (`go`) | — | — | — | measured | unavailable | unavailable | unavailable |
| Go | Gin (`gin`) | mysql | raw | unverified | measured | measured | measured | measured |
| Go | Gin + GORM (`gin-gorm`) | postgres | full | GORM (variant name; endpoint unverified) | unavailable | measured | measured | measured |
| Go | Chi (`chi`) | mysql | raw | unverified | measured | measured | measured | measured |
| Go | Fiber (`fiber`) | postgres | raw | unverified | measured | measured | measured | measured |
| Go | Echo (`echo`) | postgres | raw | unverified | measured | measured | measured | measured |
| Go | Hertz (`hertz`) | postgres | raw | unverified | measured | measured | measured | measured |
| Go | Hertz + GORM (`hertz-gorm`) | postgres | full | GORM (variant name; endpoint unverified) | unavailable | measured | measured | measured |
| Node.js | Node.js node:http (`nodejs`) | — | — | — | measured | unavailable | unavailable | unavailable |
| Node.js | Express (`express`) | — | — | — | measured | unavailable | unavailable | unavailable |
| Node.js | Express + postgres.js (`express-postgresjs`) | postgres | full | Postgres.js client (named variant; endpoint unverified) | measured | measured | measured | measured |
| Node.js | Fastify (`fastify`) | — | — | — | measured | unavailable | unavailable | unavailable |
| Node.js | Fastify + PostgreSQL (`fastify-postgres`) | postgres | raw | unverified | unavailable | measured | measured | measured |
| Node.js | NestJS / Express (`nestjs`) | postgres | full | TypeORM and pg declared; endpoint unverified | measured | measured | measured | measured |
| Node.js | NestJS / Fastify (`nestjs-fastify`) | postgres | full | TypeORM and pg declared; endpoint unverified | measured | measured | measured | measured |
| Node.js | Koa (`koa`) | mongodb | raw | unverified | measured | measured | measured | unavailable |
| Node.js | Koa + PostgreSQL (`koa-postgres`) | postgres | raw | unverified | unavailable | measured | measured | unavailable |
| Node.js | Hono (`hono`) | — | — | — | measured | unavailable | unavailable | unavailable |
| Node.js | Hono + PostgreSQL (`hono-postgres`) | postgres | raw | unverified | unavailable | measured | measured | measured |
| Node.js | hapi (`hapi`) | mongodb | full | unverified | measured | measured | measured | measured |
| Node.js | hapi + PostgreSQL (`hapi-postgres`) | postgres | full | unverified | unavailable | measured | measured | measured |

Beego, Iris, and AdonisJS have no result in this Round 23 physical-server snapshot.

## JSON serialization

Ranked by successful throughput among selected configurations. Each row uses its best measured concurrency.

| Rank | Configuration | Successful requests/s | Avg latency | Errors | Concurrency |
| --- | --- | ---: | --- | ---: | ---: |
| 1 | Node.js node:http (`nodejs`) | 1,147,305 | 454.46us | 0 | 512 |
| 2 | Hertz (`hertz`) | 1,028,233 | 545.43us | 0 | 512 |
| 3 | Echo (`echo`) | 855,437 | 372.64us | 0 | 256 |
| 4 | Fastify (`fastify`) | 844,960 | 608.14us | 0 | 512 |
| 5 | NestJS / Fastify (`nestjs-fastify`) | 778,831 | 656.11us | 0 | 512 |
| 6 | Hono (`hono`) | 740,451 | 817.80us | 0 | 512 |
| 7 | Koa (`koa`) | 572,932 | 0.89ms | 0 | 512 |
| 8 | Fiber (`fiber`) | 542,699 | 248.41us | 0 | 128 |
| 9 | hapi (`hapi`) | 516,627 | 1.00ms | 0 | 512 |
| 10 | Gin (`gin`) | 498,192 | 1.39ms | 0 | 512 |
| 11 | Go net/http (`go`) | 388,485 | 1.58ms | 0 | 512 |
| 12 | Chi (`chi`) | 352,272 | 2.98ms | 0 | 512 |
| 13 | Express + postgres.js (`express-postgresjs`) | 301,214 | 1.99ms | 0 | 512 |
| 14 | Express (`express`) | 224,163 | 2.47ms | 0 | 512 |
| 15 | NestJS / Express (`nestjs`) | 192,830 | 1.47ms | 0 | 256 |

## Single database query

Results are displayed by database and TFB class for lookup. No database rank is assigned without a source-verified match on database, access library, and test path. Each row uses its best measured concurrency.

| Database | TFB class | Access library / evidence status | Configuration | Successful requests/s | Avg latency | Errors | Concurrency |
| --- | --- | --- | --- | ---: | --- | ---: | ---: |
| mongodb | full | unverified | hapi (`hapi`) | 59,318 | 8.64ms | 0 | 512 |
| mongodb | raw | unverified | Koa (`koa`) | 123,286 | 4.23ms | 0 | 512 |
| mysql | raw | unverified | Gin (`gin`) | 222,675 | 2.97ms | 0 | 512 |
| mysql | raw | unverified | Chi (`chi`) | 208,056 | 3.06ms | 0 | 512 |
| postgres | full | GORM (variant name; endpoint unverified) | Hertz + GORM (`hertz-gorm`) | 293,747 | 0.89ms | 0 | 256 |
| postgres | full | GORM (variant name; endpoint unverified) | Gin + GORM (`gin-gorm`) | 245,228 | 1.02ms | 0 | 256 |
| postgres | full | Postgres.js client (named variant; endpoint unverified) | Express + postgres.js (`express-postgresjs`) | 214,177 | 2.49ms | 0 | 512 |
| postgres | full | TypeORM and pg declared; endpoint unverified | NestJS / Fastify (`nestjs-fastify`) | 164,572 | 3.15ms | 0 | 512 |
| postgres | full | unverified | hapi + PostgreSQL (`hapi-postgres`) | 126,540 | 4.01ms | 0 | 512 |
| postgres | full | TypeORM and pg declared; endpoint unverified | NestJS / Express (`nestjs`) | 84,218 | 6.18ms | 0 | 512 |
| postgres | raw | unverified | Hertz (`hertz`) | 523,241 | 489.03us | 0 | 256 |
| postgres | raw | unverified | Fiber (`fiber`) | 440,178 | 596.90us | 0 | 256 |
| postgres | raw | unverified | Fastify + PostgreSQL (`fastify-postgres`) | 437,130 | 1.21ms | 0 | 512 |
| postgres | raw | unverified | Echo (`echo`) | 432,423 | 566.12us | 0 | 256 |
| postgres | raw | unverified | Hono + PostgreSQL (`hono-postgres`) | 381,827 | 1.42ms | 0 | 512 |
| postgres | raw | unverified | Koa + PostgreSQL (`koa-postgres`) | 137,326 | 3.70ms | 0 | 512 |

## Multiple database queries

All five query counts use client concurrency 512. Cells show **successful requests/s · source average latency · errors**. Rows are grouped by database and TFB class for lookup; they are not ranked until the access library and test path are verified as matched.

| Database | TFB class | Access library / evidence status | Configuration | 1 | 5 | 10 | 15 | 20 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mongodb | full | unverified | hapi (`hapi`) | 57,972 · 8.83ms · 0 | 15,828 · 32.10ms · 0 | 8,396 · 60.32ms · 0 | 5,638 · 89.74ms · 0 | 4,307 · 117.29ms · 0 |
| mongodb | raw | unverified | Koa (`koa`) | 101,671 · 5.42ms · 0 | 36,633 · 13.98ms · 0 | 20,981 · 24.23ms · 0 | 14,802 · 34.27ms · 0 | 11,475 · 44.15ms · 0 |
| mysql | raw | unverified | Gin (`gin`) | 218,434 · 3.01ms · 0 | 62,276 · 8.63ms · 0 | 33,409 · 15.44ms · 0 | 22,904 · 22.28ms · 0 | 17,305 · 29.37ms · 0 |
| mysql | raw | unverified | Chi (`chi`) | 196,541 · 3.20ms · 0 | 57,710 · 9.26ms · 0 | 31,306 · 16.46ms · 0 | 21,734 · 23.47ms · 0 | 16,282 · 31.20ms · 0 |
| postgres | full | Postgres.js client (named variant; endpoint unverified) | Express + postgres.js (`express-postgresjs`) | 201,678 · 2.63ms · 0 | 134,050 · 3.90ms · 0 | 96,402 · 5.40ms · 0 | 75,290 · 6.87ms · 0 | 62,037 · 8.26ms · 0 |
| postgres | full | GORM (variant name; endpoint unverified) | Hertz + GORM (`hertz-gorm`) | 288,331 · 2.56ms · 0 | 65,109 · 8.42ms · 0 | 33,485 · 15.53ms · 0 | 22,587 · 22.68ms · 0 | 17,078 · 29.83ms · 0 |
| postgres | full | TypeORM and pg declared; endpoint unverified | NestJS / Fastify (`nestjs-fastify`) | 154,438 · 3.40ms · 0 | 47,568 · 16.08ms · 0 | 24,971 · 20.35ms · 0 | 16,384 · 30.95ms · 0 | 12,048 · 42.07ms · 0 |
| postgres | full | GORM (variant name; endpoint unverified) | Gin + GORM (`gin-gorm`) | 219,024 · 3.22ms · 0 | 52,821 · 10.15ms · 0 | 23,012 · 236.53ms · 0 | 15,464 · 321.72ms · 0 | 11,060 · 383.56ms · 0 |
| postgres | full | unverified | hapi + PostgreSQL (`hapi-postgres`) | 122,072 · 4.14ms · 0 | 38,895 · 13.03ms · 0 | 21,519 · 23.55ms · 0 | 14,913 · 33.98ms · 0 | 11,208 · 45.20ms · 0 |
| postgres | full | TypeORM and pg declared; endpoint unverified | NestJS / Express (`nestjs`) | 80,066 · 6.45ms · 0 | 36,318 · 22.99ms · 0 | 21,199 · 23.96ms · 0 | 14,648 · 34.64ms · 0 | 11,070 · 45.81ms · 0 |
| postgres | raw | unverified | Fastify + PostgreSQL (`fastify-postgres`) | 426,358 · 1.23ms · 0 | 214,244 · 2.43ms · 0 | 135,605 · 3.78ms · 0 | 98,022 · 5.22ms · 0 | 76,157 · 6.68ms · 0 |
| postgres | raw | unverified | Hono + PostgreSQL (`hono-postgres`) | 369,527 · 1.46ms · 0 | 194,512 · 2.70ms · 0 | 126,260 · 4.09ms · 0 | 92,287 · 5.56ms · 0 | 72,501 · 7.04ms · 0 |
| postgres | raw | unverified | Fiber (`fiber`) | 275,942 · 1.96ms · 0 | 64,394 · 7.86ms · 0 | 33,160 · 15.28ms · 0 | 22,306 · 22.72ms · 0 | 16,834 · 30.10ms · 0 |
| postgres | raw | unverified | Hertz (`hertz`) | 289,407 · 1.84ms · 0 | 64,389 · 7.87ms · 0 | 32,721 · 15.48ms · 0 | 21,992 · 23.04ms · 0 | 16,602 · 30.52ms · 0 |
| postgres | raw | unverified | Echo (`echo`) | 219,828 · 2.51ms · 0 | 59,936 · 8.45ms · 0 | 31,592 · 16.04ms · 0 | 21,466 · 23.61ms · 0 | 16,230 · 31.22ms · 0 |
| postgres | raw | unverified | Koa + PostgreSQL (`koa-postgres`) | 135,572 · 3.73ms · 0 | 44,414 · 11.41ms · 0 | 24,922 · 20.34ms · 0 | 17,389 · 29.15ms · 0 | 13,295 · 38.11ms · 0 |

## Database updates

All five query counts use client concurrency 512. Cells show **successful requests/s · source average latency · errors**. Rows are grouped by database and TFB class for lookup; they are not ranked until the access library and test path are verified as matched.

| Database | TFB class | Access library / evidence status | Configuration | 1 | 5 | 10 | 15 | 20 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mongodb | full | unverified | hapi (`hapi`) | 36,422 · 14.02ms · 0 | 9,237 · 54.85ms · 0 | 4,821 · 104.82ms · 0 | 3,236 · 155.94ms · 0 | 2,414 · 208.43ms · 0 |
| mysql | raw | unverified | Gin (`gin`) | 84,794 · 17.17ms · 0 | 17,820 · 69.96ms · 0 | 9,858 · 54.98ms · 0 | 5,842 · 112.84ms · 0 | 4,887 · 104.09ms · 0 |
| mysql | raw | unverified | Chi (`chi`) | 82,984 · 15.93ms · 0 | 17,304 · 70.85ms · 0 | 9,760 · 55.09ms · 0 | 5,834 · 133.35ms · 0 | 4,609 · 115.62ms · 0 |
| postgres | full | Postgres.js client (named variant; endpoint unverified) | Express + postgres.js (`express-postgresjs`) | 148,353 · 3.69ms · 0 | 102,630 · 5.29ms · 0 | 77,347 · 6.68ms · 0 | 61,762 · 8.32ms · 0 | 50,819 · 10.05ms · 0 |
| postgres | full | GORM (variant name; endpoint unverified) | Gin + GORM (`gin-gorm`) | 127,146 · 4.00ms · 0 | 26,350 · 19.31ms · 0 | 13,221 · 38.32ms · 0 | 8,821 · 57.40ms · 0 | 6,604 · 76.61ms · 0 |
| postgres | full | GORM (variant name; endpoint unverified) | Hertz + GORM (`hertz-gorm`) | 122,126 · 4.19ms · 0 | 24,961 · 20.36ms · 0 | 12,526 · 40.44ms · 0 | 8,350 · 60.64ms · 0 | 6,264 · 80.79ms · 0 |
| postgres | full | TypeORM and pg declared; endpoint unverified | NestJS / Fastify (`nestjs-fastify`) | 86,573 · 5.88ms · 0 | 20,498 · 26.95ms · 0 | 10,851 · 46.65ms · 0 | 7,306 · 69.27ms · 0 | 5,483 · 92.26ms · 0 |
| postgres | full | TypeORM and pg declared; endpoint unverified | NestJS / Express (`nestjs`) | 53,624 · 9.55ms · 0 | 18,907 · 29.34ms · 0 | 10,579 · 47.91ms · 0 | 7,161 · 70.65ms · 0 | 5,385 · 93.93ms · 0 |
| postgres | full | unverified | hapi + PostgreSQL (`hapi-postgres`) | 53,715 · 9.45ms · 0 | 14,497 · 34.95ms · 0 | 7,634 · 66.32ms · 0 | 5,136 · 98.39ms · 0 | 3,888 · 129.90ms · 0 |
| postgres | raw | unverified | Fastify + PostgreSQL (`fastify-postgres`) | 253,588 · 2.27ms · 0 | 149,684 · 3.50ms · 0 | 99,902 · 5.16ms · 0 | 73,409 · 6.96ms · 0 | 56,771 · 8.94ms · 0 |
| postgres | raw | unverified | Hono + PostgreSQL (`hono-postgres`) | 232,385 · 2.39ms · 0 | 140,946 · 3.70ms · 0 | 95,779 · 5.37ms · 0 | 71,376 · 7.16ms · 0 | 55,713 · 9.12ms · 0 |
| postgres | raw | unverified | Fiber (`fiber`) | 148,132 · 3.45ms · 0 | 53,713 · 9.48ms · 0 | 29,518 · 17.17ms · 0 | 20,427 · 24.81ms · 0 | 15,709 · 32.26ms · 0 |
| postgres | raw | unverified | Hertz (`hertz`) | 155,252 · 3.30ms · 0 | 53,407 · 9.54ms · 0 | 29,307 · 17.29ms · 0 | 20,243 · 25.03ms · 0 | 15,551 · 32.58ms · 0 |
| postgres | raw | unverified | Echo (`echo`) | 133,314 · 3.87ms · 0 | 31,575 · 16.06ms · 0 | 16,350 · 30.99ms · 0 | 11,108 · 45.61ms · 0 | 8,338 · 60.72ms · 0 |

## Latency sanity check

A row-by-row check against the prior extraction found the same requests/s, average latency, errors, and concurrency or query-count values. The following rows have `successful requests/s × average latency in seconds` greater than **twice** the stated client concurrency of 512. This is a screening heuristic under a steady-state assumption, not proof that the source latency is wrong. The saved JSON lacks per-request timings and run logs, so the average cannot be independently recomputed or explained here. All source values above are preserved.

| Test | Configuration | Query count | Total requests | Calculated requests/s | Source avg | Implied in-flight requests |
| --- | --- | ---: | ---: | ---: | --- | ---: |
| query | `gin-gorm` | 10 | 345,180 | 23,012 | 236.53ms | 5,443 |
| query | `gin-gorm` | 15 | 231,966 | 15,464 | 321.72ms | 4,975 |
| query | `gin-gorm` | 20 | 165,893 | 11,060 | 383.56ms | 4,242 |
| update | `gin` | 1 | 1,271,903 | 84,794 | 17.17ms | 1,456 |
| update | `gin` | 5 | 267,298 | 17,820 | 69.96ms | 1,247 |
| update | `chi` | 1 | 1,244,758 | 82,984 | 15.93ms | 1,322 |
| update | `chi` | 5 | 259,564 | 17,304 | 70.85ms | 1,226 |

## Other decision categories

### Runtime footprint: unranked—no comparable measurement

“Lightest” means **process memory and startup time** here. The Round 23 JSON does not report either metric. The public measurements found for individual frameworks use different workloads and environments, so they do not support a reliable ranking across this shortlist. Source-line counts and throughput are not substitutes. Measure resident memory and time to ready on the same hardware, runtime versions, and representative application if these constraints affect a decision.

### Learning curve

These are **qualitative judgments**, not TechEmpower results. They assume a developer already knows Go or Node.js. Low means a first useful API needs few framework-specific concepts; medium means learning a distinct request model, plugin system, or substantial assembly; high means a larger set of required conventions. The linked project documentation is the basis for each judgment.

| Family | Curve | Why |
| --- | --- | --- |
| Go [`net/http`](https://pkg.go.dev/net/http) | Low | No package setup; built-in handlers and `ServeMux`, with application middleware assembled as needed. |
| [Gin](https://gin-gonic.com/en/docs/) | Low | Install the package; routes, binding, and middleware use a small set of conventions. |
| [Chi](https://github.com/go-chi/chi) | Low | Install a router; handlers retain familiar `net/http` interfaces and middleware composition. |
| [Fiber](https://docs.gofiber.io/) | Medium | Install the package, then learn its request context and `fasthttp`-based API conventions. |
| [Echo](https://echo.labstack.com/docs) | Low | Install the package; routes, binding, and middleware have few required conventions and support `net/http` integration. |
| [Hertz](https://www.cloudwego.io/docs/hertz/) | Medium | Install the package, then learn its request context, server conventions, and optional microservice tooling. |
| Node.js [`node:http`](https://nodejs.org/api/http.html) | Medium | No package setup or framework conventions, but routing, parsing, and middleware must be assembled manually. |
| [Express](https://expressjs.com/en/guide/routing.html) | Low | Install the package; a direct route and middleware model has few required conventions. |
| [Fastify](https://fastify.dev/docs/latest/) | Medium | Install the package, then learn plugin encapsulation, hooks, and route schemas. |
| [NestJS](https://docs.nestjs.com/first-steps) | High | Project setup follows Nest conventions; modules, providers, dependency injection, decorators, and HTTP adapters all matter. |
| [Koa](https://koajs.com/) | Medium | Install the core and choose surrounding packages; learn its async middleware flow. |
| [Hono](https://hono.dev/docs/getting-started/nodejs) | Low | Install Hono and its Node adapter; routing and middleware follow a compact Web Standards API. |
| [hapi](https://hapi.dev/tutorials/en_us/getting-started) | Medium | Install the package, then learn server configuration, plugins, and request lifecycle conventions. |

### How to use this reference

1. Use **JSON** to understand the small-response HTTP path. It does not predict a database-backed endpoint's capacity.
2. Use **single query** for a basic read path. Use the **multi-query trajectory** to see the cost of repeated database operations; a real endpoint may batch work that this test deliberately separates.
3. Use **updates** for a simple write path. It does not model your transactions, contention, indexes, or domain logic.
4. Check database, ORM, and driver choices before drawing a framework conclusion. Average latency at benchmark load does not establish a p95 or p99 service objective. If a shortlist is close to a real capacity or latency requirement, test the actual workload.

The [Round 23 announcement](https://www.techempower.com/blog/2025/03/17/framework-benchmarks-round-23/) reports new hardware and networking. Do not compare these absolute throughput numbers directly with earlier rounds.
