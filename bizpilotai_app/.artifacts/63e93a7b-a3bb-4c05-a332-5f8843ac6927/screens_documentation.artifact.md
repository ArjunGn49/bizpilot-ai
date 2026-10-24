# BizPilot AI - Screen Documentation

This document provides a comprehensive overview of every screen in the BizPilot AI application, detailing its purpose, state management, key features, and user interaction flows.

---

## 1. Authentication & Onboarding Screens

### [LoginScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/login_screen.dart)
- **Purpose**: Allows registered business owners/users to securely authenticate into the application using their email and password.
- **Key Features**:
  - Email and password text fields with validation.
  - Sign-in button with loading state indicator via Riverpod (`authControllerProvider`).
  - Navigation links to [SignupScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/signup_screen.dart) and [PasswordResetScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/password_reset_screen.dart).
  - Floating Snackbar error notifications for authentication failures.

### [SignupScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/signup_screen.dart)
- **Purpose**: Enables new users to create a BizPilot AI account by providing an email and secure password with confirmation.
- **Key Features**:
  - Form validation for email format, password strength, and password matching.
  - Riverpod state integration for asynchronous sign-up handling.
  - Clean Material 3 card layout with branding.

### [PasswordResetScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/password_reset_screen.dart)
- **Purpose**: Facilitates password recovery for users who forgot their credentials.
- **Key Features**:
  - Email input field for receiving a Firebase password reset link.
  - Success feedback and error handling via Snackbars.

---

## 2. Core & Management Screens

### [DashboardScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/dashboard/presentation/screens/dashboard_screen.dart)
- **Purpose**: Serves as the central command center for the business owner upon logging in.
- **Key Features**:
  - Quick overview metrics (total sales, revenue, low stock alerts, recent transactions).
  - Quick action buttons to create invoices, add products, add expenses, or manage customers.
  - Real-time synchronization indicators and navigation shortcuts.

### [SettingsScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/settings/presentation/screens/settings_screen.dart)
- **Purpose**: Allows users to configure application preferences, business profile details, theme settings, and sign out.
- **Key Features**:
  - Business profile editing and data persistence.
  - Dark/Light theme toggle.
  - Secure sign-out action tied to [AuthRepository](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/domain/repositories/auth_repository.dart).

---

## 3. Product & Inventory Management

### [ProductListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/product_list_screen.dart)
- **Purpose**: Displays the complete catalog of inventory items and products.
- **Key Features**:
  - Search and filter products by category or stock status.
  - Low stock warning highlights.
  - Floating action button to add a new product.

### [ProductDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/product_detail_screen.dart)
- **Purpose**: Shows detailed information about a specific product.
- **Key Features**:
  - Product price, stock quantity, SKU, category, and description.
  - Edit and delete actions.

### [AddEditProductScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/add_edit_product_screen.dart)
- **Purpose**: Form interface for creating a new product or updating an existing one.
- **Key Features**:
  - Input fields for product name, price, stock, category selection, and barcode scanning support.

---

## 4. Customer Management

### [CustomerListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/customer_list_screen.dart)
- **Purpose**: Lists all business customers/clients.
- **Key Features**:
  - Search customers by name, phone, or email.
  - Quick access to customer detail view.

### [CustomerDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/customer_detail_screen.dart)
- **Purpose**: Displays comprehensive details for a selected customer, including their purchase history and outstanding balances.
- **Key Features**:
  - Customer contact details, invoice history, and payment tracking.
  - Edit and delete options.

### [AddEditCustomerScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/add_edit_customer_screen.dart)
- **Purpose**: Form interface to add a new customer or edit existing customer info.

---

## 5. Invoicing & Billing

### [InvoiceListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/invoice_list_screen.dart)
- **Purpose**: Lists all generated invoices with status filters (Paid, Pending, Overdue, Void).

### [InvoiceDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/invoice_detail_screen.dart)
- **Purpose**: Views full invoice breakdown, line items, customer info, and payment status.
- **Key Features**:
  - PDF generation and sharing using `printing` and `pdf` packages.
  - Record payment actions.
  - Void invoice capability.

### [CreateInvoiceScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/create_invoice_screen.dart)
- **Purpose**: Multi-step or form-based interface to build and issue a new invoice.
- **Key Features**:
  - Customer selection, line item addition with products, tax/discount calculation, and invoice issuance.

---

## 6. Expenses & Financial Analytics

### [ExpenseListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/expenses/presentation/screens/expense_list_screen.dart)
- **Purpose**: Tracks and lists business expenses categorized by type.

### [AddExpenseScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/expenses/presentation/screens/add_expense_screen.dart)
- **Purpose**: Form to record a new business expense with amount, category, date, and notes.

### [AnalyticsScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/analytics/presentation/screens/analytics_screen.dart)
- **Purpose**: Provides financial charts, revenue vs expense summaries, and sales analytics to empower business decisions.
