Create this file:

```text
C:\Career\BizPilotAI\flutter_app\CLAUDE.md
```

Open:

```powershell
cd C:\Career\BizPilotAI\flutter_app
notepad CLAUDE.md
```

Paste the complete content below and save.

````markdown
# BizPilotAI Flutter Project - Claude Code Instructions

## 1. Project Overview

Project Name:
BizPilotAI

Platform:
- Flutter
- Android
- iOS

Primary Language:
- Dart

Purpose:
- Build a scalable, production-ready Flutter application.
- Follow enterprise-level coding standards.
- Keep the codebase maintainable, testable, and easy for multiple developers to work on.

---

# 2. Core Development Principles

Always prioritize:

- Clean Architecture
- SOLID principles
- Separation of concerns
- Maintainable code
- Reusable components
- Testable business logic
- Performance optimization
- Security best practices

Avoid:

- Large widget files
- Business logic inside UI widgets
- Direct API calls from UI
- Hardcoded strings
- Hardcoded colors
- Duplicate code
- Unnecessary dependencies

---

# 3. Flutter Architecture

Use:

Feature-first Clean Architecture.

Recommended structure:

lib/

├── app/
│   ├── app.dart
│   ├── routes/
│   ├── themes/
│   └── bindings/

├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── utils/
│   ├── extensions/
│   └── widgets/

├── features/

│   └── feature_name/

│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/

│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/

│       └── presentation/
│           ├── controllers/
│           ├── pages/
│           ├── widgets/
│           └── states/

├── injection_container.dart

└── main.dart


Rules:

- Each feature must be independent.
- Do not mix feature code.
- Core contains only shared functionality.
- Domain layer must not depend on Flutter packages.
- Data layer handles external communication.
- Presentation layer handles UI only.

---

# 4. State Management

Preferred:

Riverpod


Rules:

- Use Riverpod providers for dependency injection and state.
- Keep state immutable.
- Prefer StateNotifier / Notifier patterns.
- Avoid unnecessary StatefulWidget usage.
- Do not store business logic inside widgets.

Example responsibility:

UI:
- Display data
- Handle user interaction

Controller / Notifier:
- Manage state
- Call use cases

Use Case:
- Business rules

Repository:
- Data operations

---

# 5. Dependency Injection

Use:

get_it


Rules:

All dependencies must be registered centrally.

Example:

- API clients
- Repositories
- Services
- Use cases
- Controllers


Avoid:

Creating dependencies directly inside widgets.

Bad:

```dart
final api = ApiService();
````

Good:

```dart
final api = getIt<ApiService>();
```

---

# 6. Navigation

Use:

go_router

Rules:

* Define routes centrally.
* Avoid Navigator.push everywhere.
* Support deep linking.
* Keep route names constants.

Structure:

app/routes/

Contains:

* AppRouter
* RouteConstants
* RouteGuards

---

# 7. UI Development Guidelines

Use:

* Material 3
* Responsive layouts
* Reusable widgets

Rules:

Widgets should be:

* Small
* Focused
* Reusable

Avoid:

```dart
Widget build(BuildContext context) {

 // 500 lines of UI

}
```

Prefer:

```text
Screen
 |
 ├── HeaderWidget
 ├── ContentWidget
 └── ActionWidget
```

---

# 8. Theme Management

All colors, typography, and spacing must be centralized.

Use:

app/themes/

Do not:

```dart
Color(0xff123456)
```

inside widgets.

Use:

```dart
AppColors.primary
```

---

# 9. Networking

Use:

Dio

Structure:

core/network/

Include:

* API client
* Interceptors
* Error handling
* Authentication handling

Rules:

Every API call must handle:

* Success
* Loading
* Empty state
* Failure state

---

# 10. Data Models

Use:

json_serializable

Rules:

Models must contain:

* fromJson()
* toJson()

Prefer immutable models.

Example:

```dart
@immutable
class UserModel {
}
```

---

# 11. Error Handling

Never silently ignore errors.

Use:

Custom exceptions:

Example:

```text
ServerException
NetworkException
CacheException
AuthenticationException
```

Convert exceptions into failures in domain layer.

---

# 12. Local Storage

Preferred:

* SharedPreferences
* Hive
* Secure Storage

Rules:

Sensitive data:

* Tokens
* Passwords
* Credentials

must use:

flutter_secure_storage

---

# 13. Authentication

Authentication flow:

UI
↓
Controller
↓
UseCase
↓
Repository
↓
API

Never:

Store tokens directly in UI.

---

# 14. Testing Rules

Every important feature should have:

Unit tests:

* Use cases
* Controllers
* Repositories

Widget tests:

* Important screens
* User flows

Test structure:

test/

├── unit/

├── widget/

└── integration/

---

# 15. Code Style Rules

Follow Dart official style.

Use:

* dart format
* flutter analyze

Naming:

Classes:

PascalCase

Example:

UserRepository

Variables:

camelCase

Example:

userName

Constants:

lowerCamelCase

Example:

maxRetryCount

---

# 16. Git Rules

Commit messages:

Use:

type: description

Examples:

feat: add authentication flow

fix: resolve login validation issue

refactor: improve repository structure

Avoid:

"update"
"changes"
"test"

---

# 17. Performance Rules

Optimize:

* Widget rebuilds
* List rendering
* Image loading
* Network calls

Use:

* const widgets where possible
* pagination for large lists
* caching where appropriate

Avoid:

* unnecessary rebuilds
* expensive operations inside build()

---

# 18. Security Rules

Never commit:

* API keys
* passwords
* tokens
* secrets

Use:

.env files

and secure configuration.

---

# 19. Documentation Rules

For every major feature document:

* Purpose
* Architecture flow
* API dependency
* State management approach
* Testing approach

---

# 20. Claude Code Working Rules

Before modifying code:

1. Understand existing architecture.
2. Inspect related files.
3. Explain proposed changes.
4. Avoid unnecessary refactoring.

When creating code:

Always provide:

* File path
* Complete code
* Explanation
* Required dependency changes

When fixing bugs:

Follow:

1. Identify root cause.
2. Explain issue.
3. Apply minimal fix.
4. Verify impact.

---

# 21. Project Quality Goal

The final application should be:

* Production ready
* Scalable
* Maintainable
* Interview-quality
* Enterprise-level Flutter architecture

All future code changes must follow these rules.

````

