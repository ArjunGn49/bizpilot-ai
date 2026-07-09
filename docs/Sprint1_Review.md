# Sprint 1 – Design Review

**Date:** 2026-07-09  
**Status:** Complete — approved for Sprint 2

---

## Documentation Completeness

| Document | Status | Notes |
|---|---|---|
| 00_Decision_Log.md | Pending | Shell exists; ADRs to be written from decisions made in this sprint |
| 01_Project_Overview.md | Approved | |
| 02_Requirements.md | Approved | FR-053 promoted to Must; US-044 (partial payment) promoted to Must |
| 03_User_Stories.md | Approved | 30 stories across 7 epics; all linked to FR/NFR IDs |
| 04_Domain_Model.md | Approved | 5 aggregates; 7 cross-aggregate invariants defined |
| 05_Glossary.md | Approved | |
| 06_Tech_Stack.md | Approved | All major choices documented with rejected alternatives |
| 07_Architecture.md | Approved | Data flow, DI, state, error handling, navigation all defined |
| 08_Database_Design.md | Approved | All MVP tables; 4 transaction boundaries specified |
| 09_Coding_Guidelines.md | Approved | This sprint |

**ADRs to write before Sprint 2 starts (in 00_Decision_Log.md):**

| ADR | Decision |
|---|---|
| ADR-001 | Flutter + Dart as the application platform |
| ADR-002 | Riverpod over GetX for state management and DI |
| ADR-003 | Drift + SQLCipher for local database |
| ADR-004 | SQLCipher encryption from day one (not retrofitted) |
| ADR-005 | Firebase Auth for authentication (not local PIN) |
| ADR-006 | go_router for navigation |
| ADR-007 | freezed + json_serializable for code generation |
| ADR-008 | Local sequential invoice numbers in Phase 1; server-generated or device-prefixed in Phase 2 |

---

## Requirements Traceability Check

| Epic | User Stories | Requirements Linked | Status |
|---|---|---|---|
| EP-001 Authentication | US-001 – US-004 | FR-001 – FR-005, NFR-020 – NFR-022 | Complete |
| EP-002 Product Management | US-010 – US-015 | FR-010 – FR-019 | Complete |
| EP-003 Inventory | US-020 – US-023 | FR-020 – FR-024 | Complete |
| EP-004 Customer Management | US-030 – US-033 | FR-030 – FR-035 | Complete |
| EP-005 Invoice Management | US-040 – US-045 | FR-040 – FR-053 | Complete |
| EP-006 Expense Tracking | US-060 – US-062 | FR-060 – FR-064 | Complete |
| EP-007 Dashboard | US-070 – US-073 | FR-070 – FR-075, NFR-020 | Complete |

All 75 functional and non-functional requirements have at least one linked user story.

---

## Architecture Decisions — No Unresolved Items

| Area | Decision | Documented In |
|---|---|---|
| State management | Riverpod AsyncNotifier | 06, 07, ADR-002 |
| DI | Riverpod providers (no get_it) | 07 |
| Navigation | go_router with ShellRoute | 07 |
| Local DB | Drift + SQLCipher | 06, 08, ADR-003, ADR-004 |
| Authentication | Firebase Auth, email/password | 06, ADR-005 |
| Offline strategy | Local-first; all writes to Drift | 07, 08 |
| Error handling | Result<T> + Failure hierarchy | 07, 09 |
| Code generation | freezed + json_serializable | 06, ADR-007 |
| Transaction safety | Drift transactions for all multi-table writes | 08, 09 |
| Invoice numbering | Local sequential counter in Phase 1 | 08, ADR-008 |

---

## Open Questions

| ID | Question | Owner | Sprint |
|---|---|---|---|
| OQ-01 | Should serialized products (IMEI) be enforced per product type from day one, or remain optional fields? | Arjun | Sprint 3 |
| OQ-02 | Should barcode scanning be mandatory or optional during stock-in? | Arjun | Sprint 3 |
| OQ-03 | Should the first pilot support multiple staff accounts or owner-only? | Arjun | Sprint 4 |
| OQ-04 | In Phase 2, how should invoice number conflicts across devices be resolved? Prefix with device ID, or switch to server sequence? | Arjun | Phase 2 planning |

No open questions block Sprint 2.

---

## Business Invariants — All Documented

| ID | Invariant | Enforced In |
|---|---|---|
| BI-001 | Stock deducted only when invoice transitions to ACTIVE | InvoiceRepositoryImpl |
| BI-002 | Voiding an invoice restores stock for all line items | InvoiceRepositoryImpl |
| BI-003 | InvoiceItem snapshots product name, SKU, price at creation | InvoiceLocalDatasource |
| BI-004 | Customer with linked invoices cannot be deleted | CustomerRepositoryImpl |
| BI-005 | Paid amount on invoice must never exceed invoice total | InvoiceRepositoryImpl |
| BI-006 | paymentStatus is always derived, never set directly | InvoiceRepositoryImpl |
| BI-007 | stockQuantity is cached; source of truth is stock_movements sum | ProductRepositoryImpl |

---

## Sprint 2 Scope

Sprint 2 begins with generating Flutter project code. Work items in order:

1. Create Flutter project with the folder structure defined in `07_Architecture.md`
2. Configure Drift database and SQLCipher from the schema in `08_Database_Design.md`
3. Configure go_router with authentication guard
4. Configure Riverpod ProviderScope
5. Write the app theme (colors, typography, spacing)
6. Implement Firebase Auth integration
7. Build authentication screens (login, password reset)
8. Write unit tests for auth use cases

Claude Code prompt for item 1:

> Read `07_Architecture.md` and `09_Coding_Guidelines.md`. Create the complete folder structure for BizPilot AI under `lib/` exactly as defined in the Architecture document. Create placeholder Dart files with correct class names and import stubs. Do not implement any business logic. Do not add any packages not listed in `06_Tech_Stack.md`.

---

## Sprint 1 — Definition of Done

- [x] All design documents written and approved
- [x] Tech stack decided with rationale
- [x] Architecture defined with data flow diagrams
- [x] Database schema complete with transaction boundaries
- [x] Coding guidelines written including Claude Code rules
- [x] All requirements linked to user stories
- [x] All business invariants documented
- [x] No unresolved architecture decisions
- [x] Open questions captured with owners and target sprints
- [x] ADR list ready to write

**Sprint 1 is complete. Sprint 2 may begin.**
