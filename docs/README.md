# BizPilot AI

> Mobile-first inventory and invoicing solution for small retail businesses.

---

## Overview

BizPilot AI is a production-quality Flutter application designed for small retail businesses such as mobile phone and electronics shops.

The application allows business owners to manage inventory, customers, invoices, expenses, and business performance from a single mobile application while remaining fully functional without internet connectivity.

This repository is intentionally developed using an engineering-first approach.

The project prioritizes:

- Clean Architecture
- Offline-first design
- Testability
- Scalability
- Maintainability

---

## MVP Features

- Firebase Authentication
- Dashboard
- Product Management
- Categories
- Inventory Tracking
- Customer Management
- Invoice Generation
- Walk-in Sales
- Partial Payments
- Expense Tracking
- Reports
- PDF Invoice Export
- Local Database
- Offline Support

---

## Technology Stack

| Layer | Technology |
|--------|------------|
| Framework | Flutter |
| Language | Dart |
| Architecture | Clean Architecture |
| State Management | GetX |
| Database | Drift + SQLCipher |
| Authentication | Firebase Auth |
| Backend | Firebase |
| PDF | pdf |
| Dependency Injection | GetX |
| Routing | GetX |
| Testing | flutter_test |

---

## Architecture

```text
Presentation
        │
        ▼
Domain
        │
        ▼
Data
        │
        ▼
Local Database
```

Business logic always flows downward.

Repositories own transactions.

UI never accesses the database directly.

---

## Project Structure

```text
lib/

core/

features/

auth/

dashboard/

inventory/

customers/

invoices/

expenses/

reports/

shared/

main.dart
```

---

## Documentation

| Document | Purpose |
|----------|---------|
| 00_Decision_Log.md | Architecture Decisions |
| 01_Project_Overview.md | Product Vision |
| 02_Requirements.md | Functional Requirements |
| 03_User_Stories.md | User Stories |
| 04_Domain_Model.md | Business Model |
| 05_Features.md | Feature Specifications |
| 06_Tech_Stack.md | Technology Decisions |
| 07_Architecture.md | System Architecture |
| 08_Database_Design.md | Database Schema |
| 09_Coding_Guidelines.md | Coding Standards |

---

## Development Process

Sprint 1

✅ Planning

✅ Requirements

✅ Architecture

✅ Database Design

Sprint 2

Foundation Setup

Authentication

Navigation

Theme

Database

Repositories

Sprint 3

Inventory

Customers

Invoices

Expenses

Sprint 4

Reports

Dashboard

PDF Export

Testing

Sprint 5

Polishing

Performance

Deployment

---

## Project Goals

- Demonstrate senior Flutter engineering practices.
- Build a production-quality offline-first mobile application.
- Provide a strong portfolio project for recruiters.
- Create a foundation for future commercial deployment.

---

## Future Enhancements

- Multi-device synchronization
- Supplier management
- Warranty tracking
- Barcode scanning
- AI assistant
- Push notifications
- Advanced analytics
- Multi-store support

---

## License

This project is intended for educational, portfolio, and future commercial development.