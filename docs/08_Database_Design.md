# 08 – Database Design

**Document Status:** Draft  
**Last Updated:** 2026-07-09  
**Owner:** Arjun G Nair  
**Depends On:** 04_Domain_Model.md, 07_Architecture.md

---

## Overview

BizPilot AI uses **Drift** with **SQLCipher** as its local database. All tables are defined in Dart as Drift table classes. This document defines the schema, constraints, indexes, and transactional boundaries.

Primary keys are **UUIDs** (String), not auto-increment integers, so records can be created offline without collision.

---

## Audit Columns

Every table includes these columns unless noted otherwise:

| Column | Type | Description |
|---|---|---|
| `created_at` | INTEGER (Unix ms) | Row creation timestamp |
| `updated_at` | INTEGER (Unix ms) | Last modification timestamp |
| `sync_status` | TEXT | SYNCED, PENDING, CONFLICT (Phase 2 use) |

`deleted_at` is added to tables that support soft delete (see per-table notes).

---

## Table Definitions

### `users`

Stores the authenticated user's business profile. Single row in MVP.

| Column | Type | Constraints |
|---|---|---|
| `id` | TEXT | PK (Firebase UID) |
| `email` | TEXT | NOT NULL |
| `business_name` | TEXT | NOT NULL |
| `business_phone` | TEXT | nullable |
| `business_address` | TEXT | nullable |
| `currency_symbol` | TEXT | NOT NULL, default '₹' |
| `tax_label` | TEXT | NOT NULL, default 'GST' |
| `created_at` | INTEGER | NOT NULL |
| `updated_at` | INTEGER | NOT NULL |

No soft delete. No sync_status (auth is Firebase-owned).

---

### `categories`

| Column | Type | Constraints |
|---|---|---|
| `id` | TEXT | PK (UUID) |
| `name` | TEXT | NOT NULL, UNIQUE |
| `color` | TEXT | nullable (hex color) |
| `created_at` | INTEGER | NOT NULL |
| `updated_at` | INTEGER | NOT NULL |
| `sync_status` | TEXT | NOT NULL, default 'PENDING' |

No soft delete. Deleting a category with linked products must be blocked at the repository layer (BI-004 equivalent).

**Seed data:** On first launch, insert default categories: Phones, Accessories, Spare Parts, Cables, Other.

---

### `products`

| Column | Type | Constraints |
|---|---|---|
| `id` | TEXT | PK (UUID) |
| `name` | TEXT | NOT NULL |
| `sku` | TEXT | NOT NULL, UNIQUE |
| `barcode` | TEXT | nullable |
| `serial_number` | TEXT | nullable |
| `imei` | TEXT | nullable |
| `category_id` | TEXT | NOT NULL, FK → categories.id |
| `selling_price` | REAL | NOT NULL |
| `cost_price` | REAL | NOT NULL |
| `stock_quantity` | INTEGER | NOT NULL, default 0 |
| `low_stock_threshold` | INTEGER | NOT NULL, default 0 |
| `is_deleted` | INTEGER | NOT NULL, default 0 (boolean) |
| `deleted_at` | INTEGER | nullable |
| `created_at` | INTEGER | NOT NULL |
| `updated_at` | INTEGER | NOT NULL |
| `sync_status` | TEXT | NOT NULL, default 'PENDING' |

**Indexes:**
- `idx_products_sku` on `sku` (unique lookup)
- `idx_products_barcode` on `barcode` (scan lookup)
- `idx_products_category` on `category_id`
- `idx_products_low_stock` on `stock_quantity`, `low_stock_threshold` (dashboard query)

**Notes:**
- `stock_quantity` is a cached value. Source of truth is the sum of `stock_movements` for this product (BI-007).
- Soft delete: `is_deleted = 1` hides product from active lists but preserves invoice history.
- `barcode`, `serial_number`, and `imei` are all optional and independent.

---

### `stock_movements`

Records every change to a product's stock quantity. Immutable after creation.

| Column | Type | Constraints |
|---|---|---|
| `id` | TEXT | PK (UUID) |
| `product_id` | TEXT | NOT NULL, FK → products.id |
| `type` | TEXT | NOT NULL ('IN', 'OUT', 'ADJUSTMENT') |
| `quantity` | INTEGER | NOT NULL (positive for IN, negative for OUT/ADJUSTMENT) |
| `reason` | TEXT | nullable ('SALE', 'PURCHASE', 'DAMAGE', 'LOSS', 'CORRECTION', 'OTHER') |
| `reference_id` | TEXT | nullable (invoice ID for OUT movements) |
| `note` | TEXT | nullable |
| `created_at` | INTEGER | NOT NULL |
| `sync_status` | TEXT | NOT NULL, default 'PENDING' |

No `updated_at` or soft delete. Stock movements are append-only.

**Indexes:**
- `idx_stock_movements_product` on `product_id` (history lookup)
- `idx_stock_movements_reference` on `reference_id` (find movements by invoice)

---

### `customers`

| Column | Type | Constraints |
|---|---|---|
| `id` | TEXT | PK (UUID) |
| `name` | TEXT | NOT NULL |
| `phone` | TEXT | NOT NULL, UNIQUE |
| `email` | TEXT | nullable |
| `address` | TEXT | nullable |
| `total_outstanding` | REAL | NOT NULL, default 0 (cached) |
| `is_deleted` | INTEGER | NOT NULL, default 0 |
| `deleted_at` | INTEGER | nullable |
| `created_at` | INTEGER | NOT NULL |
| `updated_at` | INTEGER | NOT NULL |
| `sync_status` | TEXT | NOT NULL, default 'PENDING' |

**Indexes:**
- `idx_customers_phone` on `phone` (unique lookup, search)
- `idx_customers_name` on `name` (search)

**Notes:**
- `total_outstanding` is cached. Updated whenever a payment is added or an invoice is voided.
- Deletion blocked if the customer has linked invoices (enforced in repository, not DB constraint).

---

### `invoices`

| Column | Type | Constraints |
|---|---|---|
| `id` | TEXT | PK (UUID) |
| `invoice_number` | INTEGER | NOT NULL, UNIQUE, auto-incremented |
| `customer_id` | TEXT | nullable, FK → customers.id (null for walk-in) |
| `subtotal` | REAL | NOT NULL |
| `discount_amount` | REAL | NOT NULL, default 0 |
| `discount_type` | TEXT | NOT NULL, default 'FLAT' ('FLAT', 'PERCENTAGE') |
| `tax_amount` | REAL | NOT NULL, default 0 |
| `tax_type` | TEXT | NOT NULL, default 'FLAT' |
| `total` | REAL | NOT NULL |
| `paid_amount` | REAL | NOT NULL, default 0 (cached sum of payments) |
| `balance_amount` | REAL | NOT NULL (total - paid_amount) |
| `payment_status` | TEXT | NOT NULL ('PAID', 'PARTIAL', 'UNPAID') |
| `status` | TEXT | NOT NULL, default 'ACTIVE' ('ACTIVE', 'VOID') |
| `note` | TEXT | nullable |
| `created_at` | INTEGER | NOT NULL |
| `updated_at` | INTEGER | NOT NULL |
| `sync_status` | TEXT | NOT NULL, default 'PENDING' |

**Indexes:**
- `idx_invoices_customer` on `customer_id`
- `idx_invoices_status` on `status`
- `idx_invoices_payment_status` on `payment_status`
- `idx_invoices_created_at` on `created_at` (dashboard date range queries)

**Notes:**
- `invoice_number` uses a separate sequence counter stored in a `settings` table to ensure offline uniqueness.
- `payment_status` is derived but stored for query performance. Must be kept in sync by the repository.
- `paid_amount` and `balance_amount` are cached. Updated whenever a Payment row is inserted.

---

### `invoice_items`

| Column | Type | Constraints |
|---|---|---|
| `id` | TEXT | PK (UUID) |
| `invoice_id` | TEXT | NOT NULL, FK → invoices.id |
| `product_id` | TEXT | NOT NULL, FK → products.id |
| `product_name` | TEXT | NOT NULL (snapshot) |
| `product_sku` | TEXT | NOT NULL (snapshot) |
| `unit_price` | REAL | NOT NULL (snapshot) |
| `quantity` | INTEGER | NOT NULL |
| `line_total` | REAL | NOT NULL (unit_price × quantity) |
| `created_at` | INTEGER | NOT NULL |
| `sync_status` | TEXT | NOT NULL, default 'PENDING' |

No soft delete. Immutable after invoice is created.

**Indexes:**
- `idx_invoice_items_invoice` on `invoice_id`
- `idx_invoice_items_product` on `product_id` (find all invoices that include a product)

**Notes:**
- `product_name`, `product_sku`, and `unit_price` are snapshots. They are copied from the Product at invoice creation time (BI-003).

---

### `payments`

| Column | Type | Constraints |
|---|---|---|
| `id` | TEXT | PK (UUID) |
| `invoice_id` | TEXT | NOT NULL, FK → invoices.id |
| `amount` | REAL | NOT NULL |
| `method` | TEXT | NOT NULL, default 'CASH' ('CASH', 'UPI', 'CARD', 'OTHER') |
| `note` | TEXT | nullable |
| `created_at` | INTEGER | NOT NULL |
| `sync_status` | TEXT | NOT NULL, default 'PENDING' |

No soft delete.

**Indexes:**
- `idx_payments_invoice` on `invoice_id`

**Notes:**
- Inserting a payment must trigger an update to `invoices.paid_amount`, `invoices.balance_amount`, and `invoices.payment_status` in the same transaction.
- `amount` must not cause `paid_amount` to exceed `invoice.total` (BI-005). Enforced at repository layer.

---

### `expenses`

| Column | Type | Constraints |
|---|---|---|
| `id` | TEXT | PK (UUID) |
| `amount` | REAL | NOT NULL |
| `category` | TEXT | NOT NULL ('RENT', 'UTILITIES', 'SALARIES', 'PURCHASES', 'OTHER') |
| `date` | INTEGER | NOT NULL (Unix ms, date only) |
| `note` | TEXT | nullable |
| `created_at` | INTEGER | NOT NULL |
| `updated_at` | INTEGER | NOT NULL |
| `sync_status` | TEXT | NOT NULL, default 'PENDING' |

No soft delete (permanent deletion allowed per FR-062).

**Indexes:**
- `idx_expenses_date` on `date` (date range filter queries)

---

### `settings`

Key-value store for app-level configuration. Single row per key.

| Column | Type | Constraints |
|---|---|---|
| `key` | TEXT | PK |
| `value` | TEXT | NOT NULL |
| `updated_at` | INTEGER | NOT NULL |

**Default rows at first launch:**

| key | value |
|---|---|
| `invoice_number_sequence` | `1000` |
| `app_version` | `1.0.0` |
| `last_sync_at` | `0` |

`invoice_number_sequence` is incremented inside the CreateInvoice transaction to ensure offline-safe sequential invoice numbers.

---

## Transactional Boundaries

### Create Invoice (BI-001, BI-007)

```sql
BEGIN TRANSACTION;

  INSERT INTO invoices (...) VALUES (...);

  INSERT INTO invoice_items (...) VALUES (...);  -- one row per line item
  INSERT INTO invoice_items (...) VALUES (...);

  INSERT INTO payments (...) VALUES (...);        -- if payment provided at creation

  UPDATE invoices
    SET paid_amount = ?, balance_amount = ?, payment_status = ?
    WHERE id = ?;

  INSERT INTO stock_movements (...) VALUES (...); -- one row per invoice item (type: OUT)
  INSERT INTO stock_movements (...) VALUES (...);

  UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?;  -- per item
  UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?;

  UPDATE settings SET value = value + 1 WHERE key = 'invoice_number_sequence';

COMMIT;
```

On any failure: `ROLLBACK`. No partial invoice, no partial stock deduction.

---

### Void Invoice (BI-002)

```sql
BEGIN TRANSACTION;

  UPDATE invoices SET status = 'VOID', updated_at = ? WHERE id = ?;

  INSERT INTO stock_movements (...) VALUES (...); -- one row per item (type: IN, reason: CORRECTION)

  UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ?;  -- per item

COMMIT;
```

---

### Add Payment to Existing Invoice

```sql
BEGIN TRANSACTION;

  INSERT INTO payments (...) VALUES (...);

  UPDATE invoices
    SET paid_amount = paid_amount + ?,
        balance_amount = total - (paid_amount + ?),
        payment_status = CASE
          WHEN (paid_amount + ?) >= total THEN 'PAID'
          WHEN (paid_amount + ?) > 0 THEN 'PARTIAL'
          ELSE 'UNPAID'
        END,
        updated_at = ?
    WHERE id = ?;

  UPDATE customers SET total_outstanding = ?, updated_at = ? WHERE id = ?;

COMMIT;
```

---

### Add Stock (Stock-In)

```sql
BEGIN TRANSACTION;

  INSERT INTO stock_movements (type: 'IN', ...) VALUES (...);

  UPDATE products SET stock_quantity = stock_quantity + ?, updated_at = ? WHERE id = ?;

COMMIT;
```

---

## Schema Version

| Version | Description |
|---|---|
| 1 | Initial schema: all MVP tables |

Drift schema migrations will be added as numbered `MigrationStep` entries in `app_database.dart` when columns or tables change.

---

## Entity Relationship Summary

```
users (1)
  │
  └── [owns all data below via business context]

categories (1) ──────────────────── products (many)
                                         │
                                    stock_movements (many)
                                         │
                               invoice_items (many)
                                         │
customers (1, nullable) ─── invoices (many) ── payments (many)
                                         │
                               invoice_items (many)

expenses (standalone)

settings (key-value)
```

---

*Next document: `09_Coding_Guidelines.md`*
