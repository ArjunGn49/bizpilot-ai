# 02 – Requirements

**Document Status:** Draft  
**Last Updated:** 2026-07-09  
**Owner:** Arjun G Nair  
**Depends On:** 01_Project_Overview.md

---

## How to Read This Document

Each requirement has a unique ID that will be referenced across user stories, database design, test cases, and ADRs.

- `FR-XXX` — Functional Requirement (what the system must do)
- `NFR-XXX` — Non-Functional Requirement (quality, performance, constraints)
- Priority: **Must** (MVP blocker), **Should** (MVP desirable), **Could** (post-MVP)

---

## Functional Requirements

### Authentication

| ID | Requirement | Priority |
|---|---|---|
| FR-001 | User can sign in with email and password via Firebase Auth | Must |
| FR-002 | User can sign out | Must |
| FR-003 | User can request a password reset via email | Must |
| FR-004 | Authenticated session persists across app restarts | Must |
| FR-005 | Unauthenticated users are redirected to the login screen | Must |

---

### Product Management

| ID | Requirement | Priority |
|---|---|---|
| FR-010 | User can add a new product with name, SKU, category, selling price, cost price, and stock quantity | Must |
| FR-011 | User can edit an existing product's details | Must |
| FR-012 | User can delete a product (soft delete; retain in historical invoices) | Must |
| FR-013 | User can view a paginated list of all products | Must |
| FR-014 | User can search products by name, SKU, or barcode | Must |
| FR-015 | User can scan a product barcode using the device camera | Must |
| FR-016 | User can assign a product to a category | Must |
| FR-017 | User can add an optional IMEI or serial number to a product unit | Should |
| FR-018 | User can set a low-stock threshold per product | Should |
| FR-019 | User can view products filtered by category | Should |

---

### Inventory Management

| ID | Requirement | Priority |
|---|---|---|
| FR-020 | Stock quantity decreases automatically when an invoice is created | Must |
| FR-021 | User can manually add stock (stock-in) for a product | Must |
| FR-022 | User can view stock movement history per product (in/out with date and reason) | Must |
| FR-023 | Dashboard displays a list of products below their low-stock threshold | Must |
| FR-024 | User can record a stock adjustment with a reason (damage, loss, correction) | Should |

---

### Customer Management

| ID | Requirement | Priority |
|---|---|---|
| FR-030 | User can add a new customer with name and phone number | Must |
| FR-031 | User can edit an existing customer's details | Must |
| FR-032 | User can view a customer's full invoice history | Must |
| FR-033 | User can search customers by name or phone number | Must |
| FR-034 | User can mark an invoice as partially paid or credit (outstanding balance) | Should |
| FR-035 | User can view total outstanding balance per customer | Should |

---

### Invoice Management

| ID | Requirement | Priority |
|---|---|---|
| FR-040 | User can create an invoice by selecting a customer and adding line items | Must |
| FR-041 | Each line item includes product, quantity, unit price, and line total | Must |
| FR-042 | Invoice supports a discount field (flat amount or percentage) | Must |
| FR-043 | Invoice supports a tax field (flat amount or percentage) | Must |
| FR-044 | Invoice displays subtotal, discount, tax, and grand total | Must |
| FR-045 | Invoice is assigned a unique auto-incremented invoice number | Must |
| FR-046 | User can view a list of all invoices sorted by date | Must |
| FR-047 | User can search invoices by invoice number or customer name | Must |
| FR-048 | User can export an invoice as a PDF | Must |
| FR-049 | User can share the PDF invoice via WhatsApp or any share target | Must |
| FR-050 | User can record payment status: Paid, Partial, Unpaid | Must |
| FR-051 | User can void or cancel an invoice (restores stock) | Should |
| FR-052 | User can add a note to an invoice | Should |
| FR-053 | Invoice creation without selecting a customer (walk-in sale) | Should |

---

### Expense Tracking

| ID | Requirement | Priority |
|---|---|---|
| FR-060 | User can record a business expense with amount, category, date, and optional note | Must |
| FR-061 | User can view a list of all expenses sorted by date | Must |
| FR-062 | User can delete an expense | Must |
| FR-063 | User can filter expenses by date range | Should |
| FR-064 | User can categorize expenses (Rent, Utilities, Salaries, Purchases, Other) | Should |

---

### Dashboard

| ID | Requirement | Priority |
|---|---|---|
| FR-070 | Dashboard displays today's total sales revenue | Must |
| FR-071 | Dashboard displays total invoices created today | Must |
| FR-072 | Dashboard displays total expenses recorded today | Must |
| FR-073 | Dashboard displays a list of low-stock products | Must |
| FR-074 | Dashboard displays total outstanding receivables | Should |
| FR-075 | Dashboard displays a revenue chart for the last 7 days | Should |

---

## Non-Functional Requirements

### Performance

| ID | Requirement | Priority |
|---|---|---|
| NFR-001 | App must launch to the home screen within 2 seconds on a mid-range Android device (2 GB RAM) | Must |
| NFR-002 | Invoice creation flow must complete within 90 seconds for a first-time user | Target |
| NFR-003 | Product list must load within 1 second for up to 1,000 products | Must |
| NFR-004 | PDF export must complete within 3 seconds | Must |

---

### Reliability

| ID | Requirement | Priority |
|---|---|---|
| NFR-010 | Crash-free session rate must be ≥ 99% | Must |
| NFR-011 | No data loss must occur during an unexpected app termination | Must |
| NFR-012 | All database writes must be atomic; partial writes must be rolled back | Must |

---

### Offline Capability

| ID | Requirement | Priority |
|---|---|---|
| NFR-020 | All inventory and invoicing features must function without an internet connection | Must |
| NFR-021 | Authentication requires an internet connection only on first sign-in; subsequent sessions must work offline | Must |
| NFR-022 | The app must not crash or show errors when the device is offline | Must |

---

### Security

| ID | Requirement | Priority |
|---|---|---|
| NFR-030 | User passwords must be managed exclusively by Firebase Auth; the app must never store raw passwords | Must |
| NFR-031 | Sensitive local data (customer PII, financial records) must be stored in an encrypted local database | Must |
| NFR-032 | The app must enforce authentication before displaying any business data | Must |

---

### Code Quality

| ID | Requirement | Priority |
|---|---|---|
| NFR-040 | Unit test coverage must be ≥ 70% for domain and data layers | Must |
| NFR-041 | All features must follow Clean Architecture (data / domain / presentation separation) | Must |
| NFR-042 | No feature may directly access another feature's internal classes | Must |
| NFR-043 | All public classes and methods must have documentation comments | Should |

---

### Compatibility

| ID | Requirement | Priority |
|---|---|---|
| NFR-050 | The app must support Android API level 23 (Android 6.0) and above | Must |
| NFR-051 | The app must be designed for portrait orientation (landscape optional) | Must |
| NFR-052 | The app must function on screen sizes from 5 to 6.7 inches | Must |

---

## Requirements Traceability Index

This index will be updated as user stories, database tables, and test cases are written.

| Requirement ID | User Story | DB Table | Test Case |
|---|---|---|---|
| FR-001 | US-001 | users | TC-001 |
| FR-010 | US-010 | products | TC-010 |
| FR-020 | US-020 | stock_movements, invoices | TC-020 |
| FR-040 | US-030 | invoices, invoice_items | TC-030 |
| *(to be expanded)* | | | |

---

*Next document: `03_User_Stories.md`*
