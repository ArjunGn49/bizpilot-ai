# Architecture Decision Record (ADR)

Project: BizPilot AI
Status: Accepted
Last Updated: 09 July 2026

---

## ADR-001
### Title
Use Clean Architecture

Status
Accepted

Context
The project is intended to demonstrate production-quality engineering while remaining maintainable as features grow.

Decision
Adopt Clean Architecture with feature-first organization.

Presentation
↓

Domain
↓

Data

Consequences

Pros

High maintainability

Independent business logic

Easy testing

Scalable feature modules

Cons

More boilerplate

Higher initial setup cost

---

## ADR-002
### Title
Offline First Architecture

Status
Accepted

Decision

Business operations must continue without internet connectivity.

Local database becomes the primary source of truth.

Cloud synchronization is deferred to Phase 2.

Reason

Retail shops cannot stop billing because the internet is unavailable.

---

## ADR-003
### Title
Firebase Authentication

Status
Accepted

Decision

Use Firebase Authentication.

Reason

Reliable

Secure

Minimal implementation effort

Easy future cloud integration

Alternatives Considered

Local PIN

Supabase Auth

Custom authentication

---

## ADR-004
### Title
Encrypted Local Database

Status
Accepted

Decision

Use Drift with SQLCipher.

Reason

Protect customer information

Protect invoice history

Avoid future database migration

---

## ADR-005
### Title
Single Device MVP

Status
Accepted

Decision

Support one business operating on one device.

Reason

Reduces complexity

Allows architecture to stabilize

Future cloud sync remains possible

Future Decision

Move to multi-device synchronization in Phase 2.

---

## ADR-006
### Title
Invoice Number Generation

Status
Accepted

Decision

Invoice numbers are generated locally using a transaction-safe sequence.

Reason

Works completely offline.

Future Change

When synchronization is introduced, invoice numbers may include:

Device ID

Business ID

Server sequence

---

## ADR-007
### Title
Cached Aggregate Values

Status
Accepted

Decision

The following values are cached:

Product.stockQuantity

Customer.totalOutstanding

Invoice.paidAmount

Reason

Improves dashboard and reporting performance.

Constraint

Repositories must update cached values within the same database transaction.

---

## ADR-008
### Title
Repository Transaction Rule

Status
Accepted

Decision

Business rules may never update tables directly.

All writes pass through repositories.

Repositories own transactions.

Reason

Guarantees business invariants remain valid.

Examples

Invoice creation

Payment recording

Stock movement

Invoice cancellation

Expense recording

---

ADR-009
Title
Repository Ownership

Status
Accepted

Decision

Repositories are the only layer permitted to coordinate local and remote data sources.

Rules

• UI never accesses databases.
• Use Cases never know storage implementation.
• Transactions belong exclusively to repositories.
• Repositories enforce all business invariants.

Reason

Centralizes business logic.

Maintains data consistency.

Allows storage implementations to change without affecting the domain layer.

---

# Future ADRs

ADR-009 Cloud Synchronization

ADR-010 Barcode Scanner

ADR-011 Push Notifications

ADR-012 AI Assistant

ADR-013 Multi-store Support