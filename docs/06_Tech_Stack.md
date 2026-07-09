# 06 – Tech Stack

**Document Status:** Approved  
**Last Updated:** 2026-07-09  
**Owner:** Arjun G Nair  
**Depends On:** 04_Domain_Model.md, 00_Decision_Log.md

---

## Purpose

This document records every technology choice for BizPilot AI, along with the alternatives considered and the reason each was selected or rejected. Every entry here has a corresponding ADR in `00_Decision_Log.md`.

---

## Stack Summary

| Layer | Technology | Version Target |
|---|---|---|
| Language | Dart | 3.x |
| Framework | Flutter | 3.x stable |
| State Management | Riverpod | 2.x |
| Navigation | go_router | latest stable |
| Networking | Dio | latest stable |
| Local Database | Drift + SQLCipher | latest stable |
| Code Generation | freezed + json_serializable | latest stable |
| Dependency Injection | Riverpod (providers) | — |
| Backend | Firebase | — |
| Authentication | Firebase Auth | — |
| Push Notifications | Firebase Cloud Messaging | Phase 2 |
| Cloud Storage | Firebase Storage | Phase 2 |
| PDF Generation | pdf + printing | latest stable |
| Barcode Scanning | mobile_scanner | latest stable |
| Charts | fl_chart | latest stable |
| Logging | logger | latest stable |
| Testing | flutter_test, mocktail | — |

---

## Technology Decisions

### Flutter and Dart

**Purpose:** Cross-platform mobile framework for Android (primary) and iOS (future).

**Why Flutter:**
- Single codebase for Android and iOS reduces maintenance overhead.
- Dart compiles to native ARM, giving performance comparable to native apps.
- Rich widget library makes complex invoice and inventory UIs achievable without native bridging.
- Strong community and enterprise adoption validate it as a production choice.
- Arjun's primary expertise, which means faster implementation and fewer unknown risks.

**Alternatives considered:** React Native, Kotlin Multiplatform  
**Rejected because:** React Native introduces a JS bridge performance overhead for data-heavy list screens. KMP is strong for shared logic but still requires native UI work per platform.

---

### Riverpod (State Management and Dependency Injection)

**Purpose:** Manages application state and provides dependencies throughout the feature layers.

**Why Riverpod:**
- Compile-time safety: providers are declared as top-level constants, so missing dependencies fail at compile time rather than runtime.
- No context dependency for reading state: use cases and repositories can be tested without Flutter widget infrastructure.
- Excellent separation of concerns: a provider wrapping a use case doesn't know about the UI consuming it.
- Scoped invalidation and family providers make paginated and filtered lists straightforward.
- Replaces a separate DI library: Riverpod providers serve as the service locator, so we don't need get_it alongside it.

**Alternatives considered:** GetX, Bloc, Provider  
**GetX rejected because:** Encourages global service locator access (`Get.find()`) which breaks Clean Architecture's dependency rule. Controllers can silently depend on each other without the compiler catching it.  
**Bloc rejected because:** More verbose for the complexity level of this app. Suitable for very large teams where explicit events and states reduce miscommunication; overhead is unnecessary here.  
**Provider rejected because:** Superseded by Riverpod from the same author, with better safety guarantees.

---

### go_router (Navigation)

**Purpose:** Declarative, URL-based navigation for Flutter.

**Why go_router:**
- Official Flutter team recommendation.
- Declarative route definitions make deep linking and nested navigation straightforward.
- Redirect guards enable authentication-aware routing without scattered Navigator calls.
- Shell routes support the bottom navigation bar pattern cleanly.

**Alternatives considered:** auto_route, Navigator 2.0 manually  
**auto_route rejected because:** Adds another code generation step. go_router covers our routing needs without the extra dependency.

---

### Drift with SQLCipher (Local Database)

**Purpose:** Offline-first local relational database with encryption.

**Why Drift:**
- Type-safe SQL queries via Dart code generation. Table schema, DAO methods, and query results are all typed.
- Migration support built in. Schema version upgrades are explicit and testable.
- Supports transactions natively, which is required for invariants like CreateInvoice (BI-001, BI-007).
- Stream-based query results integrate naturally with Riverpod providers for reactive UI updates.

**Why SQLCipher:**
- Encrypts the SQLite database file at rest. Required by NFR-031.
- Retrofit cost is high; enabling it from Sprint 2 avoids a painful migration later.
- Drift has native SQLCipher support via `drift/native.dart` with a custom database opener.

**Alternatives considered:** Hive, Isar, sqflite  
**Hive/Isar rejected because:** NoSQL. Our domain model has relational structure (Invoice → InvoiceItem → Product). Enforcing relational invariants in a document store requires application-level joins, which are error-prone.  
**sqflite rejected because:** No type safety, no code generation, no migration helpers. Drift is sqflite with everything we'd build manually added in.

---

### freezed and json_serializable (Code Generation)

**Purpose:** Immutable data classes, sealed unions for error handling, and JSON serialization.

**Why freezed:**
- Generates immutable value objects with `copyWith`, `==`, `hashCode`, and `toString`.
- Sealed classes (`@freezed` with multiple constructors) are used for Result types in repositories: `Success<T>` and `Failure`.
- Eliminates entire categories of bugs caused by mutable state in domain entities.

**Why json_serializable:**
- Generates `fromJson` and `toJson` for DTOs used in Firebase and future API responses.
- Keeps serialization logic out of domain models.

**Alternatives considered:** Hand-written data classes  
**Rejected because:** Boilerplate is significant and error-prone for a project with 10+ entities. Code generation pays for itself within the first feature.

---

### Dio (Networking)

**Purpose:** HTTP client for future REST API calls and Firebase REST endpoints.

**Why Dio:**
- Interceptor support for auth token injection, logging, and retry logic.
- Request cancellation support.
- Clean error handling with `DioException`.

**Alternatives considered:** http (dart:io), Chopper  
**http rejected because:** No interceptors. Auth headers and error handling must be manually threaded into every call.  
**Note:** Networking is not used in MVP (Firebase SDK handles Firestore and Auth). Dio is included for readiness and for any direct REST calls needed later.

---

### Firebase (Backend)

**Purpose:** Authentication and future cloud sync.

**Why Firebase:**
- Firebase Auth is the fastest path to secure email/password authentication with password reset.
- Firestore's offline SDK aligns with our offline-first design for Phase 2 sync.
- Managed infrastructure removes backend operations overhead for an MVP.

**Alternatives considered:** Supabase, custom backend  
**Supabase considered:** Strong alternative, especially for relational data. Rejected for MVP because Firestore offline sync is more mature and better documented for Flutter.  
**Custom backend rejected:** Over-engineered for MVP. Adding a backend now would double the scope.

**MVP usage:** Firebase Auth only. Firestore is deferred to Phase 2.

---

### pdf + printing (PDF Generation)

**Purpose:** Generate shareable invoice PDFs on-device.

**Why pdf + printing:**
- Pure Dart PDF generation with no native dependencies.
- `printing` package handles share sheet integration (WhatsApp, Gmail, Drive).
- Works fully offline, which is a hard requirement.

**Alternatives considered:** flutter_html_to_pdf  
**Rejected because:** Requires a WebView render step, adding latency and a native dependency.

---

### mobile_scanner (Barcode Scanning)

**Purpose:** Camera-based barcode and QR code scanning for product lookup.

**Why mobile_scanner:**
- Actively maintained, backed by Google's MLKit.
- Supports EAN-13, EAN-8, UPC-A, QR Code out of the box.
- Simpler API than its predecessor `qr_code_scanner`.

**Alternatives considered:** flutter_barcode_scanner, qr_code_scanner  
**Both rejected:** Less actively maintained.

---

### fl_chart (Charts)

**Purpose:** Revenue trend visualization on the Dashboard.

**Why fl_chart:**
- Flexible bar and line chart support.
- Fully customizable to match app theme.
- No native dependencies; pure Flutter.

---

### logger (Logging)

**Purpose:** Structured debug and error logging during development.

**Why logger:**
- Color-coded output by level (verbose, debug, info, warning, error).
- Can be stripped from release builds.
- Lightweight with no configuration overhead.

---

### mocktail (Testing)

**Purpose:** Mocking dependencies in unit tests.

**Why mocktail:**
- No code generation required (unlike `mockito` with build_runner).
- Clean, readable mock definitions.
- Works well with Riverpod's `ProviderContainer` for isolated unit tests.

---

## What Is Deliberately Excluded

| Technology | Reason |
|---|---|
| GetX | Breaks Clean Architecture dependency rules |
| Hive / Isar | NoSQL; unsuitable for relational domain model |
| auto_route | Redundant alongside go_router |
| get_it | Riverpod replaces it |
| Redux | Over-engineered for this app's complexity |
| GraphQL | No API layer in MVP |

---