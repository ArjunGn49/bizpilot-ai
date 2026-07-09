# 03 – User Stories

**Document Status:** Draft  
**Last Updated:** 2026-07-09  
**Owner:** Arjun G Nair  
**Depends On:** 01_Project_Overview.md, 02_Requirements.md

---

## Personas

| ID | Persona | Description |
|---|---|---|
| P-01 | Shop Owner | Primary user. Manages all business operations. Has full access. |
| P-02 | Staff | Secondary user (Phase 2). Limited access; can create invoices and add stock. |

All MVP stories are written for **P-01 (Shop Owner)**.

---

## Epic Index

| Epic ID | Name | Stories |
|---|---|---|
| EP-001 | Authentication | US-001 – US-004 |
| EP-002 | Product Management | US-010 – US-017 |
| EP-003 | Inventory Management | US-020 – US-024 |
| EP-004 | Customer Management | US-030 – US-034 |
| EP-005 | Invoice Management | US-040 – US-050 |
| EP-006 | Expense Tracking | US-060 – US-064 |
| EP-007 | Dashboard | US-070 – US-074 |

---

## EP-001 – Authentication

---

### US-001 — Sign In

**As a** Shop Owner,  
**I want to** sign in with my email and password,  
**so that** only I can access my business data.

**Acceptance Criteria:**
- AC-001-1: Given valid credentials, the user is taken to the Dashboard.
- AC-001-2: Given invalid credentials, a clear error message is shown and the user stays on the login screen.
- AC-001-3: The password field masks input by default with a toggle to reveal it.
- AC-001-4: An authenticated session persists after the app is closed and reopened.

**Linked Requirements:** FR-001, FR-004, FR-005  
**Priority:** Must

---

### US-002 — Sign Out

**As a** Shop Owner,  
**I want to** sign out of the app,  
**so that** others using my device cannot access my data.

**Acceptance Criteria:**
- AC-002-1: User can sign out from Settings.
- AC-002-2: After sign-out, the user is redirected to the login screen.
- AC-002-3: Business data is not visible after sign-out without re-authentication.

**Linked Requirements:** FR-002, FR-005  
**Priority:** Must

---

### US-003 — Password Reset

**As a** Shop Owner,  
**I want to** reset my password if I forget it,  
**so that** I can regain access without losing my data.

**Acceptance Criteria:**
- AC-003-1: A "Forgot Password" link is visible on the login screen.
- AC-003-2: Entering a registered email sends a password reset email via Firebase.
- AC-003-3: Entering an unregistered email shows a generic message (no user enumeration).

**Linked Requirements:** FR-003  
**Priority:** Must

---

### US-004 — Offline Session

**As a** Shop Owner,  
**I want to** use the app without internet after signing in once,  
**so that** my shop operations are not blocked by connectivity issues.

**Acceptance Criteria:**
- AC-004-1: After a successful sign-in, all inventory and invoicing features work offline.
- AC-004-2: The app does not crash or show auth errors when the device is offline.
- AC-004-3: The app does not attempt to re-authenticate on every launch when a session is active.

**Linked Requirements:** FR-004, NFR-020, NFR-021, NFR-022  
**Priority:** Must

---

## EP-002 – Product Management

---

### US-010 — Add a Product

**As a** Shop Owner,  
**I want to** add a new product with its details,  
**so that** it appears in my inventory and can be added to invoices.

**Acceptance Criteria:**
- AC-010-1: The form requires: name, SKU, selling price, cost price, and initial stock quantity.
- AC-010-2: Category, barcode, serial number, and IMEI are optional fields.
- AC-010-3: SKU must be unique; the system rejects duplicates with a clear error.
- AC-010-4: After saving, the product appears in the product list immediately.
- AC-010-5: Initial stock quantity creates a stock-in movement record.

**Linked Requirements:** FR-010, FR-016, FR-017  
**Priority:** Must

---

### US-011 — Scan Barcode to Fill Product Details

**As a** Shop Owner,  
**I want to** scan a product barcode when adding or searching for a product,  
**so that** I don't have to type the barcode manually.

**Acceptance Criteria:**
- AC-011-1: A scan button opens the device camera for barcode scanning.
- AC-011-2: A successful scan fills the barcode field automatically.
- AC-011-3: If the scanned barcode matches an existing product, the user is taken to that product.
- AC-011-4: If the barcode is not found, the user can proceed to create a new product with it pre-filled.
- AC-011-5: Supports EAN-13, EAN-8, UPC-A, QR Code formats.

**Linked Requirements:** FR-015  
**Priority:** Must

---

### US-012 — Edit a Product

**As a** Shop Owner,  
**I want to** edit a product's details,  
**so that** I can correct mistakes or update pricing.

**Acceptance Criteria:**
- AC-012-1: All fields from US-010 are editable.
- AC-012-2: Changes are saved immediately and reflected in the product list.
- AC-012-3: Price changes do not retroactively alter existing invoices.

**Linked Requirements:** FR-011  
**Priority:** Must

---

### US-013 — Delete a Product

**As a** Shop Owner,  
**I want to** remove a product I no longer sell,  
**so that** my product list stays clean.

**Acceptance Criteria:**
- AC-013-1: Deletion is a soft delete; the product is hidden from the active list.
- AC-013-2: Deleted products still appear correctly on historical invoices.
- AC-013-3: A confirmation dialog is shown before deletion.

**Linked Requirements:** FR-012  
**Priority:** Must

---

### US-014 — Search and Filter Products

**As a** Shop Owner,  
**I want to** search for a product by name, SKU, or barcode,  
**so that** I can find it quickly during a sale or stock check.

**Acceptance Criteria:**
- AC-014-1: Search results update as the user types (debounced, not on submit).
- AC-014-2: Search matches name, SKU, barcode, and IMEI fields.
- AC-014-3: User can filter the product list by category.
- AC-014-4: Empty state shows a clear message when no results are found.

**Linked Requirements:** FR-014, FR-019  
**Priority:** Must

---

### US-015 — Set Low-Stock Threshold

**As a** Shop Owner,  
**I want to** set a minimum stock level for each product,  
**so that** I get alerted before I run out.

**Acceptance Criteria:**
- AC-015-1: Each product has an optional low-stock threshold field (default: 0, meaning no alert).
- AC-015-2: Products at or below threshold appear in the Dashboard low-stock list.

**Linked Requirements:** FR-018, FR-073  
**Priority:** Should

---

## EP-003 – Inventory Management

---

### US-020 — Stock Deducted on Invoice

**As a** Shop Owner,  
**I want** stock to decrease automatically when I create an invoice,  
**so that** my inventory is always accurate without manual updates.

**Acceptance Criteria:**
- AC-020-1: Each line item on a saved invoice deducts the quantity from the product's stock.
- AC-020-2: A stock-out movement record is created for each line item, linked to the invoice.
- AC-020-3: If a product has insufficient stock, the user sees a warning before saving (not a hard block for MVP).

**Linked Requirements:** FR-020  
**Priority:** Must

---

### US-021 — Add Stock Manually (Stock-In)

**As a** Shop Owner,  
**I want to** add stock to a product after receiving new inventory from a supplier,  
**so that** my stock count stays accurate.

**Acceptance Criteria:**
- AC-021-1: User can select a product and enter a quantity to add.
- AC-021-2: An optional note field captures the reason (e.g., "Received from supplier").
- AC-021-3: A stock-in movement record is created with date and quantity.
- AC-021-4: The product's stock count updates immediately.

**Linked Requirements:** FR-021  
**Priority:** Must

---

### US-022 — View Stock Movement History

**As a** Shop Owner,  
**I want to** see all stock changes for a product,  
**so that** I can trace discrepancies and audit my inventory.

**Acceptance Criteria:**
- AC-022-1: Each product has a stock history screen showing all movements (in/out).
- AC-022-2: Each movement shows: date, type (in/out/adjustment), quantity, and optional note or invoice reference.
- AC-022-3: Movements are sorted newest first.

**Linked Requirements:** FR-022  
**Priority:** Must

---

### US-023 — Record a Stock Adjustment

**As a** Shop Owner,  
**I want to** record a stock correction when items are damaged or lost,  
**so that** my stock count reflects reality.

**Acceptance Criteria:**
- AC-023-1: User can add or subtract stock with a reason: Damage, Loss, Correction, or Other.
- AC-023-2: Adjustment creates a movement record tagged as "adjustment."
- AC-023-3: The product stock count updates immediately.

**Linked Requirements:** FR-024  
**Priority:** Should

---

## EP-004 – Customer Management

---

### US-030 — Add a Customer

**As a** Shop Owner,  
**I want to** save a customer's name and phone number,  
**so that** I can link their purchases and contact them if needed.

**Acceptance Criteria:**
- AC-030-1: Required fields: name and phone number.
- AC-030-2: Phone number must be unique per business.
- AC-030-3: Customer appears in the customer list and can be selected during invoice creation.

**Linked Requirements:** FR-030  
**Priority:** Must

---

### US-031 — Edit a Customer

**As a** Shop Owner,  
**I want to** update a customer's contact details,  
**so that** my records stay current.

**Acceptance Criteria:**
- AC-031-1: Name and phone number are editable.
- AC-031-2: Changes do not affect historical invoices linked to the customer.

**Linked Requirements:** FR-031  
**Priority:** Must

---

### US-032 — View Customer Purchase History

**As a** Shop Owner,  
**I want to** see all invoices linked to a customer,  
**so that** I know what they've bought and what they owe.

**Acceptance Criteria:**
- AC-032-1: Customer detail screen lists all invoices with date, invoice number, total, and payment status.
- AC-032-2: Tapping an invoice opens the invoice detail screen.
- AC-032-3: Total outstanding balance is shown at the top of the screen.

**Linked Requirements:** FR-032, FR-035  
**Priority:** Must

---

### US-033 — Search Customers

**As a** Shop Owner,  
**I want to** search for a customer by name or phone number,  
**so that** I can find them quickly during a sale.

**Acceptance Criteria:**
- AC-033-1: Search results update as the user types.
- AC-033-2: Search matches both name and phone number.

**Linked Requirements:** FR-033  
**Priority:** Must

---

## EP-005 – Invoice Management

---

### US-040 — Create an Invoice (Named Customer)

**As a** Shop Owner,  
**I want to** create an invoice for a customer,  
**so that** the sale is recorded and the customer gets a receipt.

**Acceptance Criteria:**
- AC-040-1: User selects a customer (existing or newly created inline).
- AC-040-2: User adds one or more line items (product, quantity, price).
- AC-040-3: Discount and tax fields are optional.
- AC-040-4: Invoice total is calculated automatically.
- AC-040-5: Saving the invoice deducts stock (US-020) and creates a stock-out record.
- AC-040-6: Invoice is assigned a unique auto-incremented number.
- AC-040-7: Payment status defaults to Paid; user can change to Partial or Unpaid.

**Linked Requirements:** FR-040 – FR-046, FR-050  
**Priority:** Must

---

### US-041 — Create a Walk-In Invoice (No Customer)

**As a** Shop Owner,  
**I want to** create an invoice without selecting a customer,  
**so that** quick sales are not slowed down by mandatory data entry.

**Acceptance Criteria:**
- AC-041-1: Customer selection is optional on the invoice form.
- AC-041-2: Walk-in invoices are stored and appear in the invoice list.
- AC-041-3: Walk-in invoices are not linked to any customer record.
- AC-041-4: All other invoice behavior (stock deduction, PDF, numbering) is identical to US-040.

**Linked Requirements:** FR-053  
**Priority:** Must

---

### US-042 — Export Invoice as PDF

**As a** Shop Owner,  
**I want to** export an invoice as a PDF,  
**so that** I can send a professional receipt to the customer.

**Acceptance Criteria:**
- AC-042-1: PDF includes: business name, invoice number, date, customer name (if any), line items, subtotal, discount, tax, grand total, and payment status.
- AC-042-2: PDF can be shared via any installed share target (WhatsApp, Gmail, Drive, etc.).
- AC-042-3: PDF generation completes within 3 seconds.

**Linked Requirements:** FR-048, FR-049, NFR-004  
**Priority:** Must

---

### US-043 — Search and View Invoices

**As a** Shop Owner,  
**I want to** find a past invoice quickly,  
**so that** I can review it or resend the PDF.

**Acceptance Criteria:**
- AC-043-1: Invoice list is sorted by date, newest first.
- AC-043-2: User can search by invoice number or customer name.
- AC-043-3: Each list item shows invoice number, customer name (or "Walk-in"), date, total, and payment status.

**Linked Requirements:** FR-046, FR-047  
**Priority:** Must

---

### US-044 — Record Partial or Unpaid Payment

**As a** Shop Owner,  
**I want to** mark an invoice as partially paid or unpaid,  
**so that** I can track credit sales and outstanding balances.

**Acceptance Criteria:**
- AC-044-1: Payment status options are: Paid, Partial, Unpaid.
- AC-044-2: For Partial, the user enters the amount received; the balance is calculated automatically.
- AC-044-3: Outstanding balance is visible on the invoice detail and the customer's profile.

**Linked Requirements:** FR-050, FR-034, FR-035  
**Priority:** Should

---

### US-045 — Void an Invoice

**As a** Shop Owner,  
**I want to** cancel a mistakenly created invoice,  
**so that** stock and revenue figures are corrected.

**Acceptance Criteria:**
- AC-045-1: A void action is available on the invoice detail screen.
- AC-045-2: Voiding restores the stock quantities for all line items.
- AC-045-3: The invoice is marked as Void and remains visible in history (not deleted).
- AC-045-4: A confirmation dialog is shown before voiding.

**Linked Requirements:** FR-051  
**Priority:** Should

---

## EP-006 – Expense Tracking

---

### US-060 — Record an Expense

**As a** Shop Owner,  
**I want to** log a business expense,  
**so that** I know what the shop is spending.

**Acceptance Criteria:**
- AC-060-1: Required fields: amount, category, date.
- AC-060-2: Optional field: note.
- AC-060-3: Categories: Rent, Utilities, Salaries, Purchases, Other.
- AC-060-4: Date defaults to today but can be changed.

**Linked Requirements:** FR-060, FR-064  
**Priority:** Must

---

### US-061 — View and Filter Expenses

**As a** Shop Owner,  
**I want to** see my expenses filtered by date range,  
**so that** I can understand my monthly costs.

**Acceptance Criteria:**
- AC-061-1: Expense list is sorted by date, newest first.
- AC-061-2: User can filter by a custom date range.
- AC-061-3: Total for the filtered period is shown at the top.

**Linked Requirements:** FR-061, FR-063  
**Priority:** Must

---

### US-062 — Delete an Expense

**As a** Shop Owner,  
**I want to** remove an incorrectly entered expense,  
**so that** my records stay accurate.

**Acceptance Criteria:**
- AC-062-1: A delete option is available on each expense item.
- AC-062-2: A confirmation dialog is shown before deletion.
- AC-062-3: Deletion is permanent (no soft delete required for expenses).

**Linked Requirements:** FR-062  
**Priority:** Must

---

## EP-007 – Dashboard

---

### US-070 — View Daily Summary

**As a** Shop Owner,  
**I want to** see today's sales, expenses, and invoice count at a glance,  
**so that** I know how my shop is performing without opening multiple screens.

**Acceptance Criteria:**
- AC-070-1: Dashboard shows: today's total revenue, total invoices created today, total expenses today.
- AC-070-2: Data refreshes automatically when the screen is opened.
- AC-070-3: Dashboard works fully offline using local data.

**Linked Requirements:** FR-070, FR-071, FR-072, NFR-020  
**Priority:** Must

---

### US-071 — View Low-Stock Alerts

**As a** Shop Owner,  
**I want to** see which products are running low,  
**so that** I can restock before I miss a sale.

**Acceptance Criteria:**
- AC-071-1: Dashboard lists all products at or below their low-stock threshold.
- AC-071-2: Each item shows product name and current stock quantity.
- AC-071-3: Tapping an item opens the product detail screen.
- AC-071-4: If no products are low on stock, a positive empty state is shown.

**Linked Requirements:** FR-073  
**Priority:** Must

---

### US-072 — View Revenue Trend Chart

**As a** Shop Owner,  
**I want to** see a bar chart of revenue for the last 7 days,  
**so that** I can spot trends without exporting data.

**Acceptance Criteria:**
- AC-072-1: Bar chart shows one bar per day for the last 7 days.
- AC-072-2: Each bar shows total revenue from invoices on that day.
- AC-072-3: Tapping a bar shows the exact amount for that day.

**Linked Requirements:** FR-075  
**Priority:** Should

---

### US-073 — View Outstanding Receivables

**As a** Shop Owner,  
**I want to** see my total outstanding receivables on the Dashboard,  
**so that** I know how much money is still owed to me.

**Acceptance Criteria:**
- AC-073-1: Dashboard shows total outstanding balance across all unpaid and partial invoices.
- AC-073-2: Tapping the receivables figure navigates to a filtered invoice list showing only Unpaid and Partial invoices.

**Linked Requirements:** FR-074  
**Priority:** Should

---

## Traceability Matrix (Stub)

| Story ID | Requirement IDs | DB Entities | Test Cases | Status |
|---|---|---|---|---|
| US-001 | FR-001, FR-004, FR-005 | users | TC-001 | Planned |
| US-010 | FR-010, FR-016, FR-017 | products, stock_movements | TC-010 | Planned |
| US-020 | FR-020 | stock_movements, invoice_items | TC-020 | Planned |
| US-040 | FR-040 – FR-046, FR-050 | invoices, invoice_items | TC-040 | Planned |
| US-041 | FR-053 | invoices, invoice_items | TC-041 | Planned |
| *(expands as implementation progresses)* | | | | |

---

*Next document: `04_Domain_Model.md`*
