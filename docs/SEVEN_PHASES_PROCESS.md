# The Correct System Design Process (7 Phases)

This is the canonical loop. Every serious system design follows it, consciously or not.

## Phase 0 — Define the System Boundary

> **Question:** _What problem am I actually responsible for solving?_

**Must define:**

1. What is inside the system
2. What is outside
3. Who owns failures

_Example:_

| Term                                                                                             | Correctness |
| ------------------------------------------------------------------------------------------------ | ----------- |
| "Payment system"                                                                                 | ❌ Wrong    |
| "Internal money ledger for transfers,<br>Excluding: KYC, FX rates, and external bank settlement" | ✅ Correct  |

**Without boundaries:**

- You over-design
- You argue endlessly
- You copy others blindly

## Phase 1 — Requirements

Split requirements into 4 buckets (not just functional vs non-functional).

### 1. Functional (What it must do)

1. User stories
2. Commands vs queries
3. State transitions

_Example:_

1. Transfer money
2. Check balance
3. Reverse transaction

### 2. Non-Functional (How well)

1. Latency
2. Throughput
3. Availability
4. Consistency
5. Durability

> You must rank them.\
> Not everything can be "high".

_Examples:_

- For a payment system: Consistency > Availability > Latency
- For a social media feed: Availability > Latency > Consistency

### 3. Constraints (What you cannot change)

These drive architecture more than features.

_Examples:_

- Team size = 7
- One DB allowed
- Must support audit for 7 years
- Must be multi-region

### 4. Failure Model (What can go wrong)

You must explicitly answer:

- What can fail?
- How often?
- What happens when it does?

Most designs collapse here.

## Phase 2 — Identify the Core Invariants

**Invariant = a condition that must NEVER be violated**

_Examples:_

- Balance must never go negative
- Total debits == total credits
- Idempotency per transfer request
- Same event processed at least once but effect exactly once

If you cannot state invariants clearly:

- Your design is hand-wavy
- Your patterns are cargo cult

> **Patterns exist to protect invariants under failure.**

## Phase 3 — Data Model Before Architecture

Architecture emerges from data, not the other way around.

**Ask:**

1. What is the source of truth?
2. What is append-only?
3. What is derived?
4. What can be rebuilt?

_Example:_

- Ledger table = truth
- Balance table = cache
- Read models = projections

> If you start with microservices before data: ❌ You’re guessing

## Phase 4 — Choose Consistency Model Explicitly

This is where 90% of confusion comes from.

You must decide consistency model per operation:

| Consistency Model         | Description                                                                                  | When to Use                                |
| ------------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------ |
| Strong Consistency        | All nodes see the same data at the same time.<br>Lower availability, higher latency.         | Critical invariants (e.g., balance checks) |
| Eventual/weak Consistency | Updates will propagate to all nodes eventually.<br>Higher availability, potential conflicts. | Non-critical data (e.g., user profiles)    |
| Causal Consistency        | A user always sees their own updates immediately.                                            | User-specific data (e.g., shopping carts)  |
| Session Consistency       | Once a user reads data, they will not see older data.                                        | Session data (e.g., browsing history)      |

_Example:_

| Operation       | Consistency Model    |
| --------------- | -------------------- |
| Debit operation | Strong Consistency   |
| View balance    | Eventual Consistency |
| Analytics       | Eventual Consistency |

## Phase 5 — Failure-Driven Design

Design by answering:

> _"What happens if this step fails?"_

For each interaction:

- Network fails?
- Service retries?
- Message duplicated?
- Partial write?

This is where:

- Idempotency keys appear
- Exactly-once becomes effectively-once
- Retries become safe

If your design cannot survive retries: ❌ It’s broken

## Phase 6 — Only Now: Pick Patterns

The patterns jump in to solve consistency problems:

**Consistency & Atomicity Patterns:**

- **CQRS** → when read/write consistency differs.
- **Distributed locks** → when you need to serialize access.
- **Consensus algorithms** → when you need agreement across nodes.
- **Quorum reads/writes** → when you need a balance between availability and consistency.

**Distributed Transaction Patterns:**

- **SAGA** → when distributed atomicity is impossible.
- **Outbox** → when you need to reliably publish events.
- **Idempotency** → when retries are needed.

**State & History Patterns:**

- **Event Sourcing** → when you need an audit log and rebuildable state.
- **Change Data Capture (CDC)** → when you need to react to DB changes.

**Conflict Resolution Patterns:**

- **Vector clocks** → when you need to track causality.
- **Conflict-free Replicated Data Types (CRDTs)** → when you need automatic conflict resolution.
- **Last Write Wins (LWW)** → when you can afford to lose some updates.

## Phase 7 — Validate With Stress & Evolution

**Ask:**

- What breaks at 10× traffic?
  - At 100×?
- When team doubles?
- When schema changes?

**Good design:**

- Degrades predictably
- Evolves locally
- Fails loudly

**Bad design:**

- Works "until it doesn’t"
