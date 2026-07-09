# 05 – Glossary

**Document Status:** Draft  
**Last Updated:** 2026-07-09  
**Owner:** Arjun G Nair

---

## Purpose

This glossary defines terms used across all BizPilot AI documentation and codebase. When a term appears in a requirement, user story, domain model, or variable name, it should match the definition here exactly.

---

## Business Terms

| Term | Definition |
|---|---|
| Business | The shop being managed. Single tenant in MVP. Represented by the User's business profile. |
| Walk-in Sale | An invoice created without linking to a named customer record. Common for accessories and one-time buyers. |
| SKU | Stock Keeping Unit. A unique internal code assigned to each product by the shop owner. |
| IMEI | International Mobile Equipment Identity. A 15-digit hardware identifier unique to each mobile device unit. Used to track serialized stock. |
| Serial Number | A manufacturer-assigned identifier for a specific unit of a product. Broader than IMEI; applies to laptops, tablets, and other electronics. |
| Barcode | A scannable product code (EAN-13, EAN-8, UPC-A, or QR) printed on the product or packaging. Used for fast product lookup. |
| Category | A label grouping related products. Examples: Phones, Accessories, Spare Parts, Cables. |
| Stock | The quantity of a product currently available for sale. |
| Stock-In | A stock movement that increases a product's quantity. Triggered by manual entry or supplier purchase. |
| Stock-Out | A stock movement that decreases a product's quantity. Triggered automatically when an invoice is finalized. |
| Stock Adjustment | A manual correction to stock outside the normal sales flow. Used to record damage, loss, theft, or data corrections. |
| Stock Movement | A single recorded change in product stock quantity. Every change to stock must produce a movement record. |
| Low-Stock Alert | A flag shown on the Dashboard when a product's quantity is at or below its defined threshold. |
| Invoice | A document recording a sale. Contains one or more Invoice Items, payment information, and optionally a Customer reference. |
| Invoice Item | A single line on an Invoice representing one product at a given quantity and price. |
| Subtotal | The sum of all Invoice Item line totals before discount and tax. |
| Discount | A reduction applied to the invoice subtotal. Can be a flat amount or a percentage. |
| Tax | An addition applied to the discounted subtotal. Labeled as GST by default. Can be a flat amount or a percentage. |
| Total | The final payable amount on an invoice: Subtotal minus Discount plus Tax. |
| Paid Amount | The sum of all payments received against an invoice. |
| Balance Amount | The amount still owed on an invoice: Total minus Paid Amount. |
| Payment Status | A derived status on an invoice: PAID (balance = 0), PARTIAL (0 < balance < total), UNPAID (paid amount = 0). |
| Partial Payment | A payment received that does not fully settle the invoice balance. |
| Void | A cancelled invoice. Stock is restored. The invoice remains in history but is excluded from revenue figures. |
| Expense | A business cost unrelated to a sale. Examples: shop rent, staff salary, electricity bill. |
| Cost Price | The price at which the shop purchased a product from a supplier. Used for profit calculations. |
| Selling Price | The default price at which a product is sold to customers. Can be overridden per Invoice Item. |
| Profit | Selling Price minus Cost Price for a given Invoice Item. Aggregate profit is reported in dashboards. |
| Outstanding | An amount owed to the business by a customer across one or more unpaid or partially paid invoices. |
| Receivables | Total outstanding amounts across all customers. |

---

## Technical Terms

| Term | Definition |
|---|---|
| Aggregate | A cluster of domain objects treated as a single unit. Changes to an aggregate are atomic. |
| Aggregate Root | The entry point into an aggregate. External objects reference the aggregate only through its root. |
| Soft Delete | Marking a record as deleted without removing it from the database. Preserves historical references. |
| Snapshot | A copy of data captured at a point in time. Invoice Items snapshot product name and price so future product edits don't alter past invoices. |
| Invariant | A business rule that must always hold true, regardless of user action. |
| Repository | A class that abstracts data access. The rest of the app talks to repositories, not directly to the database or API. |
| Use Case | A single business operation (e.g., CreateInvoice, AddStock). Lives in the domain layer. |
| Drift | The local SQLite ORM used for offline data storage in Flutter. |
| Firebase Auth | Firebase's authentication service. Manages user identity and password reset. |
| Clean Architecture | The architectural pattern used in this project. Separates data, domain, and presentation layers per feature. |
| DDD Lite | A lightweight application of Domain-Driven Design concepts: aggregates, entities, value objects, and invariants, without full event sourcing. |

---

*This glossary grows as new concepts are introduced. Add an entry here whenever a new term appears in the codebase or documentation.*
