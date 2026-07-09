# 07 – Architecture

**Document Status:** Approved  
**Last Updated:** 2026-07-09  
**Owner:** Arjun G Nair  
**Depends On:** 04_Domain_Model.md, 06_Tech_Stack.md

---

## System Overview

BizPilot AI is a local-first mobile application. All business operations run against a local Drift database. Firebase is used only for authentication in MVP. The app is designed so that cloud sync can be added in Phase 2 without restructuring existing code.

```
┌─────────────────────────────────┐
│         Flutter UI              │
│   (Riverpod + go_router)        │
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│       Riverpod Providers        │
│    (AsyncNotifier / Provider)   │
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│          Use Cases              │
│   (Domain Layer, pure Dart)     │
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│        Repository               │
│   (interface in domain,         │
│    impl in data layer)          │
└──────┬──────────────┬───────────┘
       │              │
┌──────▼──────┐ ┌─────▼──────────┐
│    Drift    │ │  Firebase Auth  │
│ (local DB)  │ │  (remote, MVP) │
└─────────────┘ └────────────────┘
```

---

## Clean Architecture

Every feature follows three layers. Dependencies point inward only.

```
Presentation  →  Domain  ←  Data
```

- **Presentation** depends on Domain. Never on Data directly.
- **Data** depends on Domain (implements interfaces defined there).
- **Domain** depends on nothing. Pure Dart. No Flutter imports.

### Layer Responsibilities

| Layer | Contains | May Import |
|---|---|---|
| Domain | Entities, Use Cases, Repository interfaces, failures | Nothing outside dart:core |
| Data | Repository implementations, DAOs, DTOs, data sources | Domain, Drift, Firebase, Dio |
| Presentation | Screens, Widgets, Providers, ViewModels | Domain, Riverpod, Flutter |

---

## Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                  # MaterialApp + ProviderScope
│   └── app_theme.dart
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── asset_paths.dart
│   ├── errors/
│   │   ├── failure.dart          # Base Failure class
│   │   └── exceptions.dart
│   ├── network/
│   │   └── dio_client.dart
│   ├── router/
│   │   └── app_router.dart       # go_router config
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   ├── database/
│   │   ├── app_database.dart     # Drift database definition
│   │   └── database_provider.dart
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   ├── date_formatter.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── empty_state_widget.dart
│       └── loading_widget.dart
│
├── shared/
│   ├── models/
│   └── extensions/
│       ├── context_extensions.dart
│       └── string_extensions.dart
│
└── features/
    ├── auth/
    ├── dashboard/
    ├── products/
    ├── inventory/
    ├── customers/
    ├── invoices/
    ├── expenses/
    └── settings/
```

### Feature Structure

Every feature follows this layout exactly:

```
features/products/
│
├── data/
│   ├── datasources/
│   │   └── product_local_datasource.dart   # Drift DAO wrapper
│   ├── dto/
│   │   └── product_dto.dart                # Drift table row → domain entity
│   └── repositories/
│       └── product_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── product.dart                    # Immutable, freezed
│   ├── repositories/
│   │   └── product_repository.dart         # Abstract interface
│   └── usecases/
│       ├── add_product.dart
│       ├── update_product.dart
│       ├── delete_product.dart
│       ├── get_products.dart
│       └── search_products.dart
│
└── presentation/
    ├── providers/
    │   └── product_provider.dart           # Riverpod AsyncNotifier
    ├── screens/
    │   ├── product_list_screen.dart
    │   ├── product_detail_screen.dart
    │   └── add_edit_product_screen.dart
    └── widgets/
        ├── product_card.dart
        └── product_search_bar.dart
```

**Rules:**
- No screen may import from another feature's `data/` or `domain/` folder directly.
- Cross-feature navigation uses go_router path constants only.
- Shared UI components go in `core/widgets/` or `shared/`.

---

## Dependency Injection

Riverpod providers are the sole DI mechanism. No get_it, no service locator.

```dart
// core/database/database_provider.dart
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// features/products/data/datasources/product_local_datasource.dart
final productLocalDatasourceProvider = Provider<ProductLocalDatasource>((ref) {
  return ProductLocalDatasource(ref.watch(databaseProvider));
});

// features/products/data/repositories/product_repository_impl.dart
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productLocalDatasourceProvider));
});

// features/products/domain/usecases/get_products.dart
final getProductsUseCaseProvider = Provider<GetProducts>((ref) {
  return GetProducts(ref.watch(productRepositoryProvider));
});

// features/products/presentation/providers/product_provider.dart
final productListProvider = AsyncNotifierProvider<ProductListNotifier, List<Product>>(
  ProductListNotifier.new,
);
```

The dependency chain is explicit, linear, and testable at every layer.

---

## State Management

### Provider Types

| Type | Use Case |
|---|---|
| `Provider` | Synchronous, non-reactive dependencies (repositories, use cases) |
| `AsyncNotifierProvider` | Async state that can be loaded, refreshed, or mutated (product list, invoice list) |
| `NotifierProvider` | Synchronous mutable state (form state, filter state) |
| `StreamProvider` | Reactive Drift queries that update automatically on DB changes |
| `FutureProvider` | One-shot async reads (dashboard summary) |

### State Pattern for Lists

```dart
class ProductListNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return ref.watch(getProductsUseCaseProvider).call();
  }

  Future<void> addProduct(Product product) async {
    await ref.read(addProductUseCaseProvider).call(product);
    ref.invalidateSelf(); // triggers rebuild
  }
}
```

---

## Repository Pattern

### Interface (Domain Layer)

```dart
abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts();
  Future<Result<Product>> getProductById(String id);
  Future<Result<void>> addProduct(Product product);
  Future<Result<void>> updateProduct(Product product);
  Future<Result<void>> deleteProduct(String id);
  Stream<List<Product>> watchProducts();
  Stream<List<Product>> watchLowStockProducts();
}
```

### Result Type

```dart
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Failure<T>;
}
```

All repository methods return `Result<T>`. Use cases unwrap and handle failures. Presentation never sees raw exceptions.

### Implementation (Data Layer)

```dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDatasource _local;

  ProductRepositoryImpl(this._local);

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      final dtos = await _local.getAllProducts();
      return Result.success(dtos.map((d) => d.toDomain()).toList());
    } on Exception catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }
}
```

---

## Data Flow: Create Invoice

This is the most complex operation in the app. It illustrates the full architectural flow.

```
User taps "Save Invoice"
        │
InvoiceFormNotifier.saveInvoice(invoiceData)
        │
CreateInvoiceUseCase.call(invoiceData)
        │
InvoiceRepository.createInvoice(invoice, items, payment)
        │
InvoiceLocalDatasource.createInvoiceTx(...)
        │
Drift Transaction:
  1. Insert Invoice row
  2. Insert InvoiceItem rows
  3. Insert Payment row (if payment provided)
  4. Insert StockMovement rows (one per item, type: OUT)
  5. Update Product.stockQuantity for each item
  6. COMMIT
        │
Result<Invoice> returned up the chain
        │
Provider invalidated → UI rebuilds with new invoice in list
```

If any step in the transaction throws, Drift rolls back all changes. No partial state is written.

---

## Error Handling

### Failure Hierarchy

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class NetworkFailure extends Failure { ... }
class ValidationFailure extends Failure { ... }
```

### In Presentation

```dart
final state = ref.watch(productListProvider);

state.when(
  data: (products) => ProductListView(products: products),
  loading: () => const LoadingWidget(),
  error: (error, _) => ErrorWidget(message: error.toString()),
);
```

Errors never propagate as raw exceptions to the UI. They are always wrapped in `Failure` types and surfaced through `AsyncValue.error`.

---

## Navigation

go_router is configured in `core/router/app_router.dart`.

```dart
final appRouter = GoRouter(
  redirect: (context, state) {
    final isAuthenticated = ...;
    if (!isAuthenticated) return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: ...),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: ...),
        GoRoute(path: '/products', builder: ...),
        GoRoute(path: '/products/add', builder: ...),
        GoRoute(path: '/products/:id', builder: ...),
        GoRoute(path: '/invoices', builder: ...),
        GoRoute(path: '/invoices/create', builder: ...),
        GoRoute(path: '/customers', builder: ...),
        GoRoute(path: '/expenses', builder: ...),
      ],
    ),
  ],
);
```

Route paths are defined as constants to prevent magic strings across the codebase.

---

## Offline Strategy

The app is local-first. All reads and writes go to Drift. Firebase is not consulted for any business operation in MVP.

```
Every feature write:
  → Drift (primary, always)

Every feature read:
  → Drift (primary, always)

Firebase Auth:
  → Required on first sign-in
  → Session token cached locally
  → Offline after first authentication
```

Phase 2 will introduce a sync layer between Drift and Firestore. Repositories are designed for this: the `InvoiceRepository` interface does not care whether the implementation reads from Drift, Firestore, or both.

### Sync Readiness in Schema

Every Drift table will include:
- `syncStatus` (SYNCED, PENDING, CONFLICT) — for Phase 2
- `updatedAt` — for conflict resolution
- `id` as UUID — not auto-increment integer, so IDs are safe to generate offline

---

## Testing Strategy

| Layer | Tool | What Is Tested |
|---|---|---|
| Domain (use cases) | flutter_test + mocktail | Business logic, invariants, failure paths |
| Data (repositories) | flutter_test + in-memory Drift | SQL correctness, transaction atomicity |
| Presentation (providers) | flutter_test + ProviderContainer | State transitions, loading/error/data states |
| Widgets | flutter_test | Key user interactions, empty states |
| Integration | integration_test | Full feature flows on device |

Target: ≥ 70% coverage on domain and data layers (NFR-040).

### Unit Test Pattern

```dart
void main() {
  late MockProductRepository mockRepository;
  late GetProducts useCase;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProducts(mockRepository);
  });

  test('returns product list on success', () async {
    when(() => mockRepository.getProducts())
        .thenAnswer((_) async => Result.success([testProduct]));

    final result = await useCase.call();

    expect(result, isA<Success<List<Product>>>());
  });
}
```

---

## What This Architecture Prevents

| Problem | How Architecture Prevents It |
|---|---|
| Feature A breaking Feature B | No direct cross-feature imports; only shared core |
| UI logic leaking into business logic | Use cases in domain layer have no Flutter dependency |
| Untestable code | Every layer can be tested with mocks; no singletons |
| Broken offline behavior | All writes go to Drift first; Firebase not on the write path |
| Schema migration pain | Drift manages migrations explicitly per version |
| Partial invoice writes | Single Drift transaction for all CreateInvoice writes |

---
