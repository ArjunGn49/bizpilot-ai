# 09 – Coding Guidelines

**Document Status:** Approved  
**Last Updated:** 2026-07-09  
**Owner:** Arjun G Nair  
**Depends On:** 07_Architecture.md

---

## Purpose

This document is the constitution of the BizPilot AI codebase. Every contributor — human or AI — follows these rules without exception. When in doubt, consult this document before writing code.

---

## 1. General Principles

| Principle | Meaning |
|---|---|
| Readability over cleverness | Code is read far more than it is written. Prefer clarity. |
| Business logic belongs in use cases | If a method makes a business decision, it lives in the domain layer. |
| UI contains no business logic | Screens and widgets display state and capture input. Nothing more. |
| One responsibility per class | A class that does two unrelated things should be two classes. |
| Fail loudly in development | Use assertions and logging in debug mode. Never swallow errors silently. |
| Fail gracefully in production | Wrap all user-facing errors in Failure types with readable messages. |
| No magic numbers or strings | Every constant belongs in a constants file. |

---

## 2. Folder Rules

```
lib/
├── core/         Shared infrastructure: database, routing, theme, constants, utils
├── shared/       Reusable UI widgets and extensions used across features
└── features/     One folder per business feature
```

**Cross-feature rules:**
- Feature A may not import from `features/feature_b/data/` or `features/feature_b/domain/`.
- If Feature A needs something from Feature B, it belongs in `core/` or `shared/`.
- Navigation between features uses go_router path constants only. Never import a screen class from another feature.

**Layer rules within a feature:**
- `presentation/` may import from `domain/` of the same feature.
- `data/` may import from `domain/` of the same feature.
- `domain/` imports nothing from `data/` or `presentation/`.
- `presentation/` never imports from `data/`.

---

## 3. Naming Conventions

### Files

| Type | Convention | Example |
|---|---|---|
| Screen | `snake_case_screen.dart` | `product_list_screen.dart` |
| Widget | `snake_case_widget.dart` | `product_card_widget.dart` |
| Provider | `snake_case_provider.dart` | `product_provider.dart` |
| Use Case | `snake_case_use_case.dart` | `create_invoice_use_case.dart` |
| Entity | `snake_case_entity.dart` | `invoice_entity.dart` |
| DTO | `snake_case_dto.dart` | `invoice_dto.dart` |
| Repository interface | `snake_case_repository.dart` | `invoice_repository.dart` |
| Repository impl | `snake_case_repository_impl.dart` | `invoice_repository_impl.dart` |
| Datasource | `snake_case_datasource.dart` | `invoice_local_datasource.dart` |
| Drift table | `snake_case_table.dart` | `invoices_table.dart` |

### Classes

| Type | Convention | Example |
|---|---|---|
| Entity | `PascalCase` | `Invoice`, `Customer`, `Product` |
| DTO | `PascalCaseDto` | `InvoiceDto`, `ProductDto` |
| Repository interface | `PascalCaseRepository` | `InvoiceRepository` |
| Repository impl | `PascalCaseRepositoryImpl` | `InvoiceRepositoryImpl` |
| Datasource | `PascalCaseLocalDatasource` | `InvoiceLocalDatasource` |
| Use Case | `VerbNounUseCase` | `CreateInvoiceUseCase`, `GetProductsUseCase` |
| Notifier | `PascalCaseNotifier` | `InvoiceListNotifier`, `ProductFormNotifier` |
| Screen | `PascalCaseScreen` | `InvoiceListScreen`, `AddProductScreen` |
| Drift table | `PascalCaseTable` | `InvoicesTable`, `ProductsTable` |

### Providers

| Type | Convention | Example |
|---|---|---|
| Repository provider | `camelCaseRepositoryProvider` | `invoiceRepositoryProvider` |
| Use case provider | `camelCaseUseCaseProvider` | `createInvoiceUseCaseProvider` |
| State provider | `camelCaseProvider` | `invoiceListProvider`, `productFormProvider` |

### Variables and Methods

- Use `camelCase` for all variables and methods.
- Boolean variables are prefixed: `isLoading`, `hasError`, `canDelete`.
- Private fields are prefixed with `_`: `_repository`, `_datasource`.
- Avoid abbreviations unless universally understood: `id`, `url`, `pdf` are fine; `inv`, `cust`, `prod` are not.

---

## 4. Entity Rules

Entities are immutable value objects defined in the domain layer using `freezed`.

```dart
@freezed
class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    String? customerId,
    required double subtotal,
    required double total,
    required double paidAmount,
    required double balanceAmount,
    required PaymentStatus paymentStatus,
    required InvoiceStatus status,
    required List<InvoiceItem> items,
    required DateTime createdAt,
  }) = _Invoice;
}
```

**Rules:**
- No methods that write to the database.
- No Flutter imports.
- No business logic beyond simple derived getters (e.g., `bool get isFullyPaid => balanceAmount == 0`).
- All fields either required or explicitly nullable.

---

## 5. DTO Rules

DTOs convert between Drift table rows and domain entities. They live in `data/dto/`.

```dart
extension ProductDtoMapper on ProductTableData {
  Product toDomain() => Product(
    id: id,
    name: name,
    sku: sku,
    sellingPrice: sellingPrice,
    stockQuantity: stockQuantity,
    // ...
  );
}
```

**Rules:**
- DTOs never appear outside the `data/` layer.
- One mapper extension per table.
- Named `toDomain()` for table-to-entity conversion.
- Named `toTableCompanion()` for entity-to-table-insert conversion.

---

## 6. Repository Rules

Repository interfaces live in `domain/repositories/`. Implementations live in `data/repositories/`.

**Rules:**
- Return `Result<T>` or `Stream<T>` only. Never raw database types.
- Catch all database exceptions inside the repository implementation. Never let them propagate to use cases or UI.
- Implementations are the only layer that knows about Drift, DAOs, or Firebase.
- Business invariants (BI-001 through BI-007) are enforced inside repository implementations.
- Any operation involving multiple table writes must use a Drift transaction.
- Never expose DAO classes or Drift-specific types outside the `data/` layer.

---

## 7. Use Case Rules

Use cases live in `domain/usecases/`. One class per operation.

```dart
class CreateInvoiceUseCase {
  final InvoiceRepository _repository;

  CreateInvoiceUseCase(this._repository);

  Future<Result<Invoice>> call(CreateInvoiceParams params) {
    return _repository.createInvoice(params);
  }
}
```

**Rules:**
- One public method: `call()`.
- No Flutter imports.
- No direct database or Firebase access.
- Validates business rules that span multiple entities before delegating to the repository.
- May call multiple repositories if the operation genuinely requires it.

---

## 8. Riverpod Rules

- Providers are defined at the top level of their file. Never inside classes or functions.
- `AsyncNotifierProvider` is used for any state that loads from the database or performs async mutations.
- `NotifierProvider` is used for synchronous UI state (form values, filter state, toggle state).
- `StreamProvider` is used for Drift watch queries that should update reactively.
- No provider calls `ref.read()` inside `build()`. Use `ref.watch()` for reactive dependencies.
- `ref.read()` is only used inside event handlers (button taps, form submissions).
- Avoid passing `BuildContext` into providers or use cases.
- State mutation methods on notifiers handle their own error states; they do not throw.

```dart
// Correct
Future<void> createInvoice(CreateInvoiceParams params) async {
  state = const AsyncValue.loading();
  final result = await ref.read(createInvoiceUseCaseProvider).call(params);
  result.when(
    success: (invoice) => state = AsyncValue.data(invoice),
    failure: (failure) => state = AsyncValue.error(failure, StackTrace.current),
  );
}
```

---

## 9. Transaction Rules

These rules enforce the business invariants defined in `04_Domain_Model.md` and `08_Database_Design.md`.

| Operation | Must be atomic | Tables touched |
|---|---|---|
| Create Invoice | Yes | invoices, invoice_items, payments, stock_movements, products, settings |
| Void Invoice | Yes | invoices, stock_movements, products, customers |
| Add Payment | Yes | payments, invoices, customers |
| Stock-In | Yes | stock_movements, products |
| Stock Adjustment | Yes | stock_movements, products |

**Rules:**
- No caller may split a transaction into multiple separate repository calls.
- If a transaction touches `stock_movements`, it must also update `products.stock_quantity` in the same transaction (BI-007).
- If a transaction touches `payments`, it must update `invoices.paid_amount`, `invoices.balance_amount`, and `invoices.payment_status` in the same transaction (BI-005, BI-006).
- If a transaction changes invoice payment status and a customer is linked, it must update `customers.total_outstanding` in the same transaction.

---

## 10. Error Handling

### Failure Types

All errors are represented as domain `Failure` subclasses:

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure { const DatabaseFailure(super.message); }
class AuthFailure extends Failure { const AuthFailure(super.message); }
class ValidationFailure extends Failure { const ValidationFailure(super.message); }
class NetworkFailure extends Failure { const NetworkFailure(super.message); }
```

**Rules:**
- Repository implementations catch raw exceptions and return `Result.failure(...)`.
- Use cases never catch exceptions; they receive `Result<T>` from repositories.
- Providers convert `Failure` to `AsyncValue.error(...)`.
- UI reads `AsyncValue` and shows appropriate error messages.
- Error messages shown to users are human-readable. Never expose stack traces or SQL errors.

---

## 11. Logging

Use the `logger` package. One global logger instance in `core/utils/app_logger.dart`.

**Log these:**
- App startup and database initialization
- Firebase Auth events (sign-in, sign-out, token refresh)
- Database migrations
- Invoice creation, void, and payment events
- Any `Result.failure(...)` returned from a repository
- Sync operations (Phase 2)

**Never log these:**
- Passwords or auth tokens
- Customer PII (name, phone, email)
- Full invoice contents
- Any field from the `users` table

**Log levels:**
- `logger.d(...)` — debug, development only
- `logger.i(...)` — info, significant events
- `logger.w(...)` — warning, unexpected but handled
- `logger.e(...)` — error, with exception and stack trace

---

## 12. Git Conventions

### Branch Naming

```
feature/auth
feature/products
feature/invoices
bugfix/invoice-stock-deduction
refactor/product-repository
docs/domain-model
chore/update-dependencies
test/invoice-use-cases
```

### Commit Format (Conventional Commits)

```
feat: add invoice PDF export
fix: correct stock deduction on void invoice
docs: update domain model with payment aggregate
refactor: extract invoice total calculation to use case
test: add unit tests for CreateInvoiceUseCase
chore: upgrade drift to latest stable
```

**Rules:**
- Subject line under 72 characters.
- Use imperative mood: "add", "fix", "update", not "added", "fixed", "updated".
- Reference requirement IDs in body when relevant: `Implements FR-048, FR-049`.
- One logical change per commit. Do not bundle unrelated changes.

---

## 13. Pull Request Checklist

Before marking a PR as ready for review, confirm:

- [ ] Flutter build succeeds with no errors or warnings
- [ ] All existing tests pass
- [ ] New tests written for added domain or data logic
- [ ] No business logic in screens or widgets
- [ ] Repository invariants preserved (BI-001 through BI-007)
- [ ] All multi-table writes use Drift transactions
- [ ] No raw exceptions propagated to the UI
- [ ] No new packages added without a corresponding ADR
- [ ] No cross-feature imports (only through `core/` or `shared/`)
- [ ] Requirement IDs referenced in PR description
- [ ] Documentation updated if a design decision changed

---

## 14. Claude Code Contribution Rules

When Claude Code is asked to generate or modify code for this project, it must follow this protocol before writing a single line.

### Before Writing Code

1. Read the relevant documentation for the feature being implemented:
   - `02_Requirements.md` — identify the FR/NFR IDs in scope
   - `04_Domain_Model.md` — understand the entities and invariants
   - `07_Architecture.md` — follow the layer structure and provider patterns
   - `09_Coding_Guidelines.md` (this document) — apply naming and rules
2. Confirm the feature's folder structure matches `07_Architecture.md` before creating files.
3. Identify which database transactions are involved and confirm they match `08_Database_Design.md`.

### While Writing Code

4. Implement only the scope specified in the task. No speculative features.
5. Follow naming conventions exactly as defined in Section 3.
6. Do not introduce new packages without flagging them for human approval.
7. Write entities as `@freezed` classes.
8. Write repository methods that return `Result<T>` or `Stream<T>`.
9. Enforce all relevant business invariants (BI-001 through BI-007) in the repository implementation.
10. Use Drift transactions for every multi-table operation.

### After Writing Code

11. Add unit tests for every use case and repository method.
12. Document any assumption made that was not resolvable from the specification.
13. List the requirement IDs implemented (e.g., "Implements FR-040, FR-041, FR-042").
14. Flag any open question raised during implementation that requires a human decision.
15. Do not refactor unrelated code in the same task.

---

*This document is the final design artifact before implementation begins. All subsequent work is implementation against this specification.*
