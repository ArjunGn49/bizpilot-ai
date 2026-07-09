# BizPilot AI

A mobile-first inventory and invoicing solution for small retail businesses. BizPilot AI helps owners track stock, create professional invoices, monitor daily sales, and manage customer records — all from a single application, with offline support built in from day one.

---

## The Problem

Small retail shops — particularly mobile phone and electronics stores — typically manage operations across disconnected tools: WhatsApp for orders, notebooks for stock, Excel for billing. This causes stock discrepancies, missed payments, and no visibility into daily performance.

BizPilot AI replaces all of that with one offline-capable mobile app.

---

## Target Users

Small retail businesses with 1–20 employees. Primary archetype: mobile phone and electronics shop owners who need inventory tracking, invoicing, and customer management in a single tool they can use from their phone.

---

## Project Status

| Sprint | Goal | Status |
|---|---|---|
| Sprint 1 | Product and Technical Design | Complete |
| Sprint 2 | Flutter Foundation | In Progress |
| Sprint 3 | Authentication | Planned |
| Sprint 4 | Inventory and Products | Planned |
| Sprint 5 | Customers and Invoicing | Planned |
| Sprint 6 | Payments and Expenses | Planned |
| Sprint 7 | Reports and Dashboard | Planned |
| Sprint 8 | Offline Sync | Planned |
| Sprint 9 | Polish, Testing, and Release | Planned |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x |
| Navigation | go_router |
| Local Database | Drift + SQLCipher |
| Authentication | Firebase Auth |
| PDF Generation | pdf + printing |
| Barcode Scanning | mobile_scanner |
| Code Generation | freezed + json_serializable |

Full rationale for every choice is in docs/06_Tech_Stack.md.

---

## Repository Structure

```
BizPilotAI/
├── docs/                     Project documentation
│   ├── 00_Decision_Log.md    Architecture Decision Records (ADRs)
│   ├── 01_Project_Overview.md
│   ├── 02_Requirements.md
│   ├── 03_User_Stories.md
│   ├── 04_Domain_Model.md
│   ├── 05_Glossary.md
│   ├── 06_Tech_Stack.md
│   ├── 07_Architecture.md
│   ├── 08_Database_Design.md
│   └── 09_Coding_Guidelines.md
├── flutter_app/              Flutter source code
│   └── lib/
│       ├── core/
│       ├── shared/
│       ├── features/
│       └── main.dart
├── design/                   Wireframes and design system
└── .github/                  CI/CD workflows
```

---

## Where to Start Reading

If you are new to this project, read in this order:

1. docs/01_Project_Overview.md — what the product is and why it exists
2. docs/00_Decision_Log.md — every major technical decision and the reasoning behind it
3. docs/07_Architecture.md — how the Flutter app is structured
4. docs/09_Coding_Guidelines.md — rules every contributor follows

If you want to understand the business model before the code:

1. docs/04_Domain_Model.md — aggregates, entities, and business invariants
2. docs/08_Database_Design.md — tables, constraints, and transactions

---

## Building and Running

Sprint 2 in progress. Setup instructions will be added once the Flutter foundation is complete.

Expected setup steps:

```bash
# Clone the repository
git clone https://github.com/your-username/bizpilot-ai.git
cd bizpilot-ai/flutter_app

# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

Firebase configuration (google-services.json for Android, GoogleService-Info.plist for iOS) is required and not committed to the repository.

---

## Architecture Overview

```
Presentation  (Flutter widgets, Riverpod providers)
      |
Domain        (Use cases, entities, repository interfaces — pure Dart)
      |
Data          (Drift DAOs, Firebase datasources, repository implementations)
```

Every feature lives in lib/features/<feature_name>/ with this three-layer structure. No feature imports from another feature's internal layers. Cross-feature navigation uses go_router path constants only.

Full architecture documentation: docs/07_Architecture.md

---

## Contributing

All contributions follow the rules in docs/09_Coding_Guidelines.md.

Key rules:
- Business logic lives in use cases, not in widgets or providers
- All multi-table writes use Drift transactions
- All repository methods return Result<T> or Stream<T>
- No new packages without a corresponding ADR
- No cross-feature imports

---

## License

Private. All rights reserved.

---

Built with Flutter. Designed for real businesses.
