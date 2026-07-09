# 04 – Domain Model

**Document Status:** Draft  
**Last Updated:** 2026-07-09  
**Owner:** Arjun G Nair  
**Depends On:** 02_Requirements.md, 03_User_Stories.md

---

## Purpose

This document defines the business model of BizPilot AI independent of any technology choice. It identifies the core entities, their relationships, and the invariants that must always hold. The database schema, repository interfaces, and domain layer classes in Flutter will all derive from this model.

We apply **DDD Lite**: aggregates, entities, value objects, and invariants — without full event sourcing or CQRS complexity.

---

## Ubiquitous Language

Terms used consistently across code, documentation, and conversations:

| Term | Definition |
|---|---|
| Business | The shop being managed. Single tenant in MVP. |
| Product | A sellable item with a price and stock quantity. |
| SKU | Stock Keeping Unit. A unique internal identifier per product. |
| IMEI | International Mobile Equipment Identity. Unique hardware ID for serialized devices. |
| Inventory | The current stock state of all products. |
| Stock Movement | A single change in stock quantity: in, out, or adjustment. |
| Invoice | A recorded sale linking a customer (or walk-in) to one or more products. |
| Invoice Item | A single line on an invoice: one product, quantity, and price. |
| Walk-in Sale | An invoice created without linking to a named customer. |
| Payment | Money received against an invoice. An invoice may receive multiple payments. |
| Partial Payment | A payment that does not fully settle the invoice balance. |
| Expense | A business cost not related to a sale (rent, salaries, utilities). |
| Stock Adjustment | A manual correction to stock outside the normal sales flow. |
| Low-Stock Alert | A notification triggered when a product's quantity falls at or below its threshold. |
| Category | A label grouping related products (e.g., Phones, Accessories, Spare Parts). |

---

## Aggregates and Entities

### Aggregate 1 — Product

**Aggregate Root:** Product  
**Contains:** Category (reference), StockMovement records (owned)

```
Product
├── id (UUID)
├── name
├── sku (unique)
├── barcode (optional)
├── serialNumber (optional)
├── imei (optional)
├── categoryId (FK → Category)
├── sellingPrice
├── costPrice
├── stockQuantity (derived from movements, cached for performance)
├── lowStockThreshold (optional, default 0)
├── isDeleted (soft delete)
└── createdAt / updatedAt

Category
├── id
├── name
└── color (optional, for UI)

StockMovement
├── id
├── productId (FK → Product)
├── type (IN, OUT, ADJUSTMENT)
├── quantity (positive for IN, negative for OUT and ADJUSTMENT)
├── reason (optional: SALE, PURCHASE, DAMAGE, LOSS, CORRECTION)
├── referenceId (optional: invoice ID for OUT movements)
├── note (optional)
└── createdAt
```

**Invariants:**
- SKU must be unique across all products in the business.
- `stockQuantity` must always equal the sum of all StockMovements for that product.
- `stockQuantity` may go negative (warning only in MVP, hard block in Phase 2).
- Deleting a product is a soft delete; `isDeleted = true`. Historical movements are retained.
- A product must have a name, SKU, selling price, and cost price. All other fields are optional.

---

### Aggregate 2 — Customer

**Aggregate Root:** Customer

```
Customer
├── id (UUID)
├── name
├── phone (unique per business)
├── email (optional)
├── address (optional)
├── totalOutstanding (derived, cached)
└── createdAt / updatedAt
```

**Invariants:**
- Phone number must be unique per business.
- `totalOutstanding` is the sum of `balance_amount` across all non-void invoices for this customer.
- A customer cannot be deleted if they have linked invoices (protect referential integrity).

---

### Aggregate 3 — Invoice

**Aggregate Root:** Invoice  
**Contains:** InvoiceItem (owned), Payment (owned)

```
Invoice
├── id (UUID)
├── invoiceNumber (auto-incremented, unique)
├── customerId (FK → Customer, nullable for walk-in)
├── subtotal (sum of line totals)
├── discountAmount
├── discountType (FLAT, PERCENTAGE)
├── taxAmount
├── taxType (FLAT, PERCENTAGE)
├── total (subtotal - discount + tax)
├── paidAmount (sum of Payment records)
├── balanceAmount (total - paidAmount)
├── paymentStatus (PAID, PARTIAL, UNPAID)
├── status (ACTIVE, VOID)
├── note (optional)
└── createdAt / updatedAt

InvoiceItem
├── id
├── invoiceId (FK → Invoice)
├── productId (FK → Product)
├── productName (snapshot at time of sale)
├── productSku (snapshot)
├── unitPrice (snapshot at time of sale)
├── quantity
└── lineTotal (unitPrice × quantity)

Payment
├── id
├── invoiceId (FK → Invoice)
├── amount
├── method (CASH, UPI, CARD, OTHER)
├── note (optional)
└── createdAt
```

**Invariants:**
- An Invoice must have at least one InvoiceItem.
- `total = subtotal - discountAmount + taxAmount`
- `paidAmount = sum of all Payment.amount for this invoice`
- `balanceAmount = total - paidAmount`
- `paymentStatus` is derived: PAID if balance = 0, PARTIAL if 0 < balance < total, UNPAID if paidAmount = 0.
- `paidAmount` must never exceed `total`.
- InvoiceItem snapshots `productName`, `productSku`, and `unitPrice` at creation time. Product edits must not retroactively alter invoices.
- Voiding an invoice sets `status = VOID` and triggers a stock restoration for each InvoiceItem.
- A VOID invoice is excluded from revenue calculations.

---

### Aggregate 4 — Expense

**Aggregate Root:** Expense

```
Expense
├── id (UUID)
├── amount
├── category (RENT, UTILITIES, SALARIES, PURCHASES, OTHER)
├── date
├── note (optional)
└── createdAt
```

**Invariants:**
- Amount must be greater than zero.
- Date defaults to the current date but can be set to any past date.
- Expenses are permanently deleted (no soft delete required for MVP).

---

### Aggregate 5 — User (Authentication)

**Aggregate Root:** User  
**Note:** Identity is managed by Firebase Auth. The local User entity stores only display data and preferences.

```
User
├── id (Firebase UID)
├── email
├── businessName
├── businessPhone (optional)
├── businessAddress (optional)
├── currencySymbol (default: ₹)
├── taxLabel (default: GST)
└── createdAt
```

**Invariants:**
- One User per app installation in MVP.
- `businessName` is used on generated PDF invoices.

---

## Relationships

```
User (1) ──────────── owns everything below

Category (1) ─────────────────── Product (many)

Product (1) ──────── StockMovement (many)
Product (1) ──────── InvoiceItem (many)

Customer (1) ────────── Invoice (many)   [nullable: walk-in invoices have no customer]

Invoice (1) ────────── InvoiceItem (many)
Invoice (1) ────────── Payment (many)
```

### Cardinality Summary

| Relationship | Type | Notes |
|---|---|---|
| Category → Product | 1 to many | Product must have a category |
| Product → StockMovement | 1 to many | All stock changes recorded |
| Product → InvoiceItem | 1 to many | Product appears across many invoices |
| Customer → Invoice | 1 to many | Optional; walk-in invoices have null customerId |
| Invoice → InvoiceItem | 1 to many | Min 1 item required |
| Invoice → Payment | 1 to many | MVP may have 1 payment per invoice; model supports many |

---

## Business Invariants (Cross-Aggregate)

These rules span more than one aggregate and must be enforced at the repository or use case layer:

| ID | Invariant |
|---|---|
| BI-001 | Stock is deducted only when an invoice transitions to ACTIVE status. |
| BI-002 | Voiding an invoice restores all stock quantities for its InvoiceItems. |
| BI-003 | InvoiceItem.unitPrice is a snapshot; changes to Product.sellingPrice do not affect existing invoices. |
| BI-004 | A Customer with linked invoices cannot be deleted. |
| BI-005 | paidAmount on an Invoice must never exceed Invoice.total. |
| BI-006 | paymentStatus is always derived, never set directly. |
| BI-007 | stockQuantity on Product is a cached value; source of truth is the sum of StockMovements. |

---

## What This Model Does Not Cover (Post-MVP)

- Supplier aggregate (linked to Products for purchase orders)
- RepairJob aggregate (for repair shop workflows)
- Employee aggregate and role-based access
- Multi-store (Business becomes a multi-tenant root)
- Firebase Firestore sync layer (Phase 2)

---

*Next document: `05_Glossary.md`*  
*Then: `08_Database_Design.md` (maps directly from this model)*
