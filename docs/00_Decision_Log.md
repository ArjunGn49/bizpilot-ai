# 00 – Decision Log (Architecture Decision Records)

**Last Updated:** 2026-07-09  
**Owner:** Arjun G Nair

---

## ADR-001 — Architecture Style: Clean Architecture

**Status:** Accepted  
**Date:** 2026-07-09

**Context:**  
BizPilot AI is a business-critical mobile app intended to run in production and serve as a portfolio demonstration of senior engineering practices. The codebase must be testable, maintainable, and extensible as features are added over multiple sprints.

**Decision:**  
Adopt Clean Architecture with feature-first folder organization. Every feature has three layers: data/, domain/, and presentation/. Dependencies point inward only: presentation depends on domain, data depends on domain, domain depends on nothing outside Dart core.

**Options Considered:**  
- MVC: too flat for the number of features planned; business logic drifts into controllers.
- MVVM without layers: fine for small apps, but repositories and use cases become informal conventions rather than enforced boundaries.
- Clean Architecture: enforces dependency direction at the import level; enables testing each layer in isolation.

**Consequences:**  
- More initial boilerplate per feature.
- Every feature requires creating files in three folders before writing logic.
- Domain layer is fully unit-testable with no Flutter dependency.
- Adding new data sources (e.g., Firebase Firestore in Phase 2) requires only a new repository implementation, not changes to use cases or UI.

---

## ADR-002 — State Management: Riverpod

**Status:** Accepted  
**Date:** 2026-07-09

**Context:**  
State management is one of the highest-impact decisions in a Flutter app. It affects testability, architecture compliance, and how readable the code is across the project lifetime.

**Decision:**  
Use Riverpod 2.x (AsyncNotifierProvider, NotifierProvider, StreamProvider) for all state management. Riverpod also serves as the DI mechanism, eliminating the need for a separate service locator.

**Options Considered:**  
- GetX: fast to write but encourages hidden dependencies via Get.find(). Breaks the Clean Architecture dependency rule. Rejected.
- Bloc: very structured and enterprise-grade, but verbose for this project's complexity.
- Provider: superseded by Riverpod from the same author. No compile-time safety. Rejected.
- Riverpod: compile-time safe, context-independent, excellent scoping primitives, integrates cleanly with AsyncValue for loading/error/data states.

**Consequences:**  
- Providers declared as top-level constants; missing dependencies fail at compile time.
- No BuildContext threading required to access state.
- All providers are overridable in tests using ProviderContainer.
- Learning curve if developers are familiar only with GetX or Bloc.

---

## ADR-003 — Dependency Injection: Riverpod Providers (No get_it)

**Status:** Accepted  
**Date:** 2026-07-09

**Context:**  
The project needs a DI mechanism to wire repositories, use cases, and data sources together without tight coupling.

**Decision:**  
Use Riverpod providers as the sole DI mechanism. No get_it, no injectable, no service locator pattern outside of Riverpod.

**Options Considered:**  
- get_it: widely used, but adds a second dependency graph alongside Riverpod. Two systems doing the same job is redundant.
- injectable (code gen for get_it): adds another build_runner step.
- Riverpod: already present for state management; providers naturally express dependencies. One system, one mental model.

**Consequences:**  
- Dependency chain is explicit and visible in each provider definition.
- Any change in a dependency is caught immediately at the provider that uses it.
- No runtime registration errors; everything is resolved at compile time.

---

## ADR-004 — Local Database: Drift with SQLCipher

**Status:** Accepted  
**Date:** 2026-07-09

**Context:**  
BizPilot AI is offline-first. All business data must persist locally. The domain model is relational (Invoice to InvoiceItems to Products, Customer to Invoices). Data integrity requires atomic transactions across multiple tables.

**Decision:**  
Use Drift as the local database ORM with SQLCipher for at-rest encryption. Enable SQLCipher from the first database setup in Sprint 2. Do not defer encryption to a later sprint.

**Options Considered:**  
- Hive / Isar: NoSQL; cannot enforce relational invariants without application-level joins. Rejected.
- sqflite: raw SQL with no type safety, no migration helpers, no code generation. Drift is sqflite with all the missing infrastructure added.
- Drift without SQLCipher: would require a migration to add encryption later, which is risky and time-consuming.
- Drift with SQLCipher: encryption from day one; no migration cost; satisfies NFR-031.

**Consequences:**  
- drift and sqlcipher_flutter_libs added as dependencies.
- All table schemas defined as Dart classes; migrations are explicit and versioned.
- Stream-based watch queries integrate cleanly with Riverpod StreamProvider.
- Encrypted database cannot be inspected with standard SQLite tools during development.

---

## ADR-005 — Backend Platform: Firebase

**Status:** Accepted  
**Date:** 2026-07-09

**Context:**  
The app requires authentication and a path to cloud sync in Phase 2.

**Decision:**  
Use Firebase Auth for authentication in MVP. Firebase Firestore is the planned sync target for Phase 2 but is not integrated in Phase 1. No custom backend will be built for MVP.

**Options Considered:**  
- Supabase: strong alternative for relational data. Firebase's Firestore offline-first SDK is more proven for Flutter. Not selected for MVP.
- Custom backend (Node.js / FastAPI): doubles the MVP scope. Rejected.
- Firebase: managed auth, mature Flutter SDK, Firestore offline support aligns with Phase 2 sync strategy.

**Consequences:**  
- Firebase project setup required before Sprint 3 (authentication sprint).
- firebase_auth and firebase_core added as dependencies.
- Auth state is managed by Firebase; the local users table stores only business profile data (not credentials).
- Switching backends in Phase 2 requires only a new repository implementation; Firebase is behind the AuthRepository interface.

---

## ADR-006 — Offline-First Repository Strategy

**Status:** Accepted  
**Date:** 2026-07-09

**Context:**  
The primary user is a small shop owner in an environment where internet connectivity may be intermittent or unavailable. All core business operations must work offline without degraded functionality.

**Decision:**  
All reads and writes go to the local Drift database as the primary data store. Firebase is not consulted for any business operation in Phase 1. The repository layer abstracts this so Phase 2 can introduce a sync strategy without changing use cases or UI.

Data flow: UI → Use Case → Repository → Drift (Phase 1). In Phase 2, Repository → Drift + Firestore with sync resolution.

Every Drift table includes sync_status (SYNCED, PENDING, CONFLICT) and updated_at for Phase 2 conflict resolution.

**Options Considered:**  
- Online-first with local cache: unacceptable; core features would fail without internet.
- Firebase Firestore with offline persistence: introduces Firestore as a Phase 1 dependency before sync is ready. Rejected for MVP.
- Drift local-first with deferred sync: cleanest separation; sync can be added as a new data source behind the existing repository interface.

**Consequences:**  
- All primary keys are UUIDs, not auto-increment integers, so records can be created offline without collision.
- sync_status column is present from the first schema version and is ignored until Phase 2.
- Phase 2 sync implementation requires no changes to domain or presentation layers.

---

## ADR-007 — Payment as a First-Class Aggregate Entity

**Status:** Accepted  
**Date:** 2026-07-09

**Context:**  
Early designs treated payment as a set of fields on the Invoice (paid_amount, payment_status). This is common in simple apps but limits flexibility.

**Decision:**  
Payment is a first-class entity in its own payments table, linked to an invoice. Invoice.paid_amount and Invoice.balance_amount are cached derived values. The source of truth is always the sum of Payment records for an invoice.

**Options Considered:**  
- Payment as invoice fields only: simple, but cannot record partial payment history, multiple payments, or payment method per transaction. Requires schema redesign later.
- Payment as a separate entity: supports multiple payments per invoice, payment method tracking, and future refund modeling. Avoids a breaking schema change in Phase 2.

**Consequences:**  
- payments table added to schema from Sprint 2.
- All transactions that insert a Payment row must also update Invoice.paid_amount, Invoice.balance_amount, and Invoice.payment_status atomically (enforced in InvoiceRepositoryImpl).
- MVP behavior (single payment at invoice creation) is a subset of what the schema supports; no migration needed to add "record another payment" later.

---

## ADR-008 — Invoice Number Generation Strategy

**Status:** Accepted  
**Date:** 2026-07-09

**Context:**  
Invoices need a human-readable, sequential number (e.g., INV-001042) that shop owners can reference when speaking with customers. This is different from the internal UUID primary key.

**Decision:**  
Phase 1: Generate invoice numbers from a local counter stored in the settings table (invoice_number_sequence key). The counter is incremented inside the CreateInvoice transaction to ensure no gaps or duplicates within a single device.

Phase 2: When multi-device support is added, switch to either a server-assigned sequence (Firebase Cloud Function increments an atomic counter) or device-prefixed numbers (e.g., KER01-001042).

**Why this matters:**  
Invoice IDs (UUIDs) and invoice numbers serve different purposes. The UUID is the stable internal reference. The invoice number is a business-facing label that must be sequential and human-readable. Treating them as the same field would create problems when Phase 2 introduces multi-device scenarios.

**Consequences:**  
- settings table holds invoice_number_sequence as a string-encoded integer.
- Counter increment is part of the CreateInvoice transaction; a rolled-back transaction does not increment the counter.
- Invoice numbers from Phase 1 are not guaranteed to be globally unique across devices. This is documented and acceptable for single-device MVP.

---

*Add new ADRs here as new architectural decisions are made. Each ADR is permanent; superseded decisions get a new ADR that references the one it replaces.*
