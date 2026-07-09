# 01 – Project Overview

**Document Status:** Approved  
**Last Updated:** 2026-07-09  
**Owner:** Arjun G Nair

---

## 1. Project Name

**BizPilot AI**

---

## 2. Vision

A mobile-first inventory and invoicing solution for small retail businesses. BizPilot AI helps owners track stock, create professional invoices, monitor daily sales, and manage customer records — all from a single application, with offline support built in from the beginning.

---

## 3. Problem Statement

Small retail businesses — particularly mobile phone and electronics shops — typically manage operations across disconnected tools: WhatsApp for orders, paper notebooks for stock, Excel for billing, and separate apps for invoicing. This fragmentation causes:

- Stock discrepancies due to no real-time inventory updates after a sale
- Delayed payment tracking because invoices are created manually and not linked to customer records
- Manual, error-prone invoice creation with no professional output
- No consolidated sales insights or daily performance view
- No centralized customer history or purchase records

There is no single affordable mobile tool that ties inventory, invoicing, and customer management together with offline capability for this market segment.

---

## 4. Target Users

### Primary Archetype — Mobile Phone and Electronics Shop Owner

A small business owner managing a shop with 1–20 employees. They handle sales, inventory, and billing themselves or with one or two staff members.

**Characteristics:**
- Non-technical, comfortable with mobile apps
- Sells products with SKUs and serial numbers (IMEI for devices)
- Deals with accessories, spare parts, and high-value devices
- Issues invoices to walk-in customers and occasional bulk buyers
- Checks stock levels daily
- Occasionally sells on credit and needs to track outstanding payments

**Secondary Archetypes (post-MVP):**
- Hardware and tools shop
- Pharmacy
- General retail / grocery store

---

## 5. Goals

### Primary
Build a production-quality Flutter application that demonstrates senior mobile engineering practices while being suitable for pilot testing with real small businesses.

### Secondary
- Serve as a flagship portfolio project showcasing Clean Architecture, offline-first design, and professional code standards
- Lay the foundation for a commercial product that can expand to multi-device and multi-store support

---

## 6. MVP Scope

### Core Loop

```
Add / Update Product (manual entry or barcode scan)
        ↓
Create Invoice (auto-deducts stock)
        ↓
Update Inventory
        ↓
View Sales Dashboard
```

Customer management is embedded within the invoice flow, not a standalone module.

### Included Features

| Feature | Notes |
|---|---|
| Authentication | Firebase Auth, email/password |
| Product management | Name, SKU, category, price, stock quantity, optional IMEI |
| Barcode scanning | EAN/UPC/QR via camera; search by name, SKU, barcode, IMEI |
| Inventory tracking | Stock-in, stock-out linked to invoices |
| Customer management | Name, phone, purchase history |
| Invoice generation | Line items, totals, tax, discount |
| PDF invoice export | Shareable via WhatsApp or email |
| Expense tracking | Record daily business expenses |
| Dashboard | Daily sales, low stock alerts, revenue summary |
| Local database | Drift — full offline capability |
| Clean Architecture | Per-feature data / domain / presentation layers |

### Excluded from MVP

| Feature | Reason |
|---|---|
| AI assistant | Post-MVP; foundation must be solid first |
| Multi-device sync | Phase 2; repositories are designed to support it |
| Employee / staff accounts | Phase 2; single owner for MVP |
| Supplier portal | Future milestone |
| Advanced analytics | Basic dashboard covers MVP needs |
| Accounting integrations | Post-commercial-launch |
| Multi-store support | Phase 3 |
| Bluetooth barcode scanners | Post-MVP hardware support |
| Bulk stock import | Post-MVP |
| Warranty and repair tracking | Phase 2 |

---

## 7. Phase Plan

### Phase 1 — MVP (This Project)
- Offline-capable for all inventory and invoicing features
- Single business, single device
- Local database (Drift)
- Firebase Auth for authentication

### Phase 2
- Cloud synchronization via Firebase Firestore
- Multi-device support
- Owner and staff role separation
- Warranty and repair tracking
- IMEI serialization workflows

### Phase 3
- Multi-store management
- Advanced reporting
- AI-powered insights (sales forecasting, expense categorization)
- Supplier portal

---

## 8. Success Metrics

| Metric | Target | Status |
|---|---|---|
| Time to create an invoice | ≤ 90 seconds for a first-time user | Target |
| App startup time | < 2 seconds on a mid-range Android device | Target |
| Crash-free sessions | ≥ 99% | Target |
| Offline functionality | All inventory and invoicing features available offline | Required |
| Pilot users | 3–5 local businesses | Planned |
| User satisfaction | Qualitative feedback during pilot | Planned |

---

## 9. Non-Goals

This document will not define UI designs, API contracts, or database schemas. Those are covered in dedicated documents (07 – Project Structure, 08 – Database Design, 09 – API Design).

---

## 10. Open Questions

| ID | Question | Target Sprint |
|---|---|---|
| OQ-01 | Should inventory support serialized products (IMEI) from day one or after MVP? | Sprint 3 |
| OQ-02 | Should barcode scanning be mandatory or optional during stock-in? | Sprint 3 |
| OQ-03 | Should the first pilot support multiple staff accounts or only the owner? | Sprint 4 |

---

*Next document: `02_Requirements.md`*
