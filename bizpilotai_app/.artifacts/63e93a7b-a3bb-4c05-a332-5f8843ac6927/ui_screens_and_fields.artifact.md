# BizPilot AI - Comprehensive Inventory of UI Screens & Fields

This document provides a complete reference of every field, input control, button, and displayed data component across all 17 UI screens in the BizPilot AI application.

---

## 1. Authentication & Onboarding Screens

### 🔑 1.1 [LoginScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/login_screen.dart)
* **Form / Input Fields**:
  - `Email`: Text input field (`TextInputType.emailAddress`, prefix icon `Icons.email_outlined`, required validation).
  - `Password`: Obscure text input field (prefix icon `Icons.lock_outlined`, required validation).
* **Interactive Actions & Buttons**:
  - `Sign In` Button: Primary elevated submit action (`_submit()`, triggers `authControllerProvider.signIn()`).
  - `Forgot Password?` Link: Text button (navigates to `RoutePaths.passwordReset`).
  - `Continue with Google` Button: Outlined social auth button (triggers `signInWithGoogle()`).
  - `Create Account` Link: Navigates to `RoutePaths.signup`.
* **Data Displays**:
  - App Logo & Title: `BizPilot AI` header badge with Storefront icon.
  - Error Snackbars: Floating alert for authentication failures.

---

### 📝 1.2 [SignupScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/signup_screen.dart)
* **Form / Input Fields**:
  - `Email`: Text input field (`TextInputType.emailAddress`, prefix icon `Icons.email_outlined`, required validation).
  - `Password`: Obscure text input field (prefix icon `Icons.lock_outlined`, required validation).
  - `Confirm Password`: Obscure text input field (prefix icon `Icons.lock_reset_outlined`, password matching validation).
* **Interactive Actions & Buttons**:
  - `Create Account` Button: Primary submit action (`_submit()`, triggers `authControllerProvider.signUp()`).
  - `Sign up with Google` Button: Outlined social auth button (triggers `signInWithGoogle()`).
  - `Sign In` Link: Navigates back to `RoutePaths.login`.
* **Data Displays**:
  - Header Icon & Title: `Create Account` with `Person Add` header icon.

---

### 🔒 1.3 [PasswordResetScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/password_reset_screen.dart)
* **Form / Input Fields**:
  - `Email`: Text input field (`TextInputType.emailAddress`, required validation).
* **Interactive Actions & Buttons**:
  - `Send Reset Email` Button: Primary submit action (`sendPasswordResetEmail()`).
  - `Sign In` Link: Returns to `RoutePaths.login`.
* **Data Displays**:
  - Header Icon & Subtitle: `Reset Password` header banner.

---

## 2. Core & Management Screens

### 📊 2.1 [DashboardScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/dashboard/presentation/screens/dashboard_screen.dart)
* **Interactive Actions & Buttons**:
  - `Analytics & Reports` Header Button: Navigates to `RoutePaths.analytics`.
  - `Settings` Header Button: Navigates to `RoutePaths.settings`.
  - `Cloud Sync` Header Button: Triggers `_manualSync()` with progress spinner indicator.
  - `Sign Out` Header Button: Triggers `signOut()`.
  - `Create Invoice` Quick Shortcut Button: Navigates to `RoutePaths.invoicesCreate`.
  - `Scan Barcode` Quick Shortcut Button: Launches `BarcodeScannerDialog`.
  - `Add Product` Quick Shortcut Button: Navigates to `RoutePaths.productsAdd`.
  - `Add Customer` Quick Shortcut Button: Navigates to `RoutePaths.customersAdd`.
  - Module Cards: `Products`, `Customers`, `Invoices`, `Expenses`.
* **Data Displays & Metrics**:
  - `User Greeting`: `Welcome back, [Email]`.
  - `Total Sales Revenue`: Gross sum formatted in currency (₹).
  - `Collected Revenue`: Total collected payments sum (Green).
  - `Pending Due`: Total balance due sum (Red accent).
  - `Total Invoices`: Count of valid invoices (Blue).
  - `Low Stock Alert Banner`: Alert card showing low stock product names and quantities.

---

### ⚙️ 2.2 [SettingsScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/settings/presentation/screens/settings_screen.dart)
* **Form / Input Fields**:
  - `Store / Business Name`: Text input (`_nameController`).
  - `Business Phone`: Phone input (`_phoneController`).
  - `Store Address`: Multiline text input (`_addressController`).
  - `Tax Label`: Text input (`_taxLabelController`, e.g., GST / VAT / Sales Tax).
  - `Currency Symbol`: Dropdown menu selector (`₹`, `$`, `€`, `£`, `A$`, `R$`).
  - `App Theme Mode`: Segmented button / toggle selector (`Light Mode`, `Dark Mode`, `System Default`).
* **Interactive Actions & Buttons**:
  - `Save Store Settings` Button: Submits updated store details to `settingsControllerProvider`.
  - `Sync Cloud Data Now` Button: Triggers cloud sync.
* **Data Displays**:
  - Settings Status Toast/Snackbar confirmations.

---

## 3. Product & Inventory Management

### 📦 3.1 [ProductListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/product_list_screen.dart)
* **Form / Input Fields**:
  - `Search Bar`: Text input (`_searchQuery`, filters by product name, SKU, or barcode).
* **Interactive Actions & Buttons**:
  - `Camera / Scanner Button`: Launches `BarcodeScannerDialog` to search by barcode.
  - `Clear Search` Button: Resets search query.
  - `Add Product` Floating Action Button (FAB): Navigates to `RoutePaths.productsAdd`.
  - `Product Card` Item Tap: Navigates to `ProductDetailScreen`.
* **Data Displays**:
  - Product List Cards: Name, SKU, Barcode, Stock Quantity, Price, Low Stock badge.

---

### 🔍 3.2 [ProductDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/product_detail_screen.dart)
* **Interactive Actions & Buttons**:
  - `Edit Product` Button: Navigates to `AddEditProductScreen(product)`.
  - `Delete Product` Icon Button: Opens confirmation dialog & deletes product.
* **Data Displays & Fields**:
  - `Product Name & SKU`: Headline overview.
  - `Stock Status Badge`: `IN STOCK` (Green) vs `LOW STOCK` (Red).
  - `Barcode`: Scannable barcode value display.
  - `Current Stock`: Total inventory units count.
  - `Alert Threshold`: Low stock alert threshold value.
  - `Selling Price`: Unit sales price (₹).
  - `Cost Price`: Purchase cost price (₹).
  - `Profit Margin`: Unit profit sum (₹).
  - `Margin %`: Calculated profit margin percentage.

---

### ➕ 3.3 [AddEditProductScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/add_edit_product_screen.dart)
* **Form / Input Fields**:
  - `Product Name`: Text field (Required).
  - `SKU`: Stock Keeping Unit text field (Required).
  - `Barcode`: Barcode field with barcode scanner suffix icon button.
  - `Category`: Dropdown button selector (Loaded dynamically from `categoriesProvider`).
  - `Selling Price`: Numeric input field (Required).
  - `Cost Price`: Numeric input field (Required).
  - `Stock Quantity`: Integer input field (Required).
  - `Low Stock Threshold`: Integer input field (Required).
* **Interactive Actions & Buttons**:
  - `Save Product` Button: Submits create or update action.
  - `Delete Product` AppBar Icon: Deletes product when in edit mode.

---

## 4. Customer Management

### 👥 4.1 [CustomerListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/customer_list_screen.dart)
* **Interactive Actions & Buttons**:
  - `Add Customer` Floating Action Button (FAB): Navigates to `RoutePaths.customersAdd`.
  - `Customer Card` Item Tap: Navigates to `CustomerDetailScreen`.
* **Data Displays**:
  - Customer Cards: Customer Name, Initials Avatar, Phone Number, Total Outstanding Balance.

---

### 👤 4.2 [CustomerDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/customer_detail_screen.dart)
* **Interactive Actions & Buttons**:
  - `Edit Profile` Button: Navigates to `AddEditCustomerScreen(customer)`.
  - `Delete Customer` Icon Button: Opens confirmation dialog.
  - `Collect Payment` Button: Opens modal dialog to record payment towards pending invoice balance.
* **Data Displays & Fields**:
  - `Customer Profile Header`: Name, Initials Avatar, Phone Number, Email, Address.
  - `Total Orders`: Total count of customer invoices.
  - `Total Spent`: Lifetime sales total sum (₹).
  - `Outstanding Due`: Total pending balance due (₹).
  - `Purchase History`: Itemized list of customer's invoice transactions.
* **Collect Payment Dialog Fields**:
  - `Payment Amount (₹)`: Numeric input field.
  - `Payment Method`: Dropdown selector (`Cash`, `Card`, `UPI / QR`, `Bank Transfer`).
  - `Note`: Optional text input field.

---

### ✏️ 4.3 [AddEditCustomerScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/add_edit_customer_screen.dart)
* **Form / Input Fields**:
  - `Name`: Text input field (Required).
  - `Phone`: Phone input field (Required).
  - `Email (Optional)`: Email text input field.
  - `Address (Optional)`: Multiline text input field.
* **Interactive Actions & Buttons**:
  - `Save Customer` Button: Submits add/update action.
  - `Delete Customer` AppBar Icon: Deletes customer when editing.

---

## 5. Invoicing & Billing

### 🧾 5.1 [InvoiceListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/invoice_list_screen.dart)
* **Interactive Actions & Buttons**:
  - `Create Invoice` Floating Action Button (FAB): Navigates to `RoutePaths.invoicesCreate`.
  - `Invoice Card` Item Tap: Navigates to `InvoiceDetailScreen`.
* **Data Displays**:
  - Invoice Cards: Invoice Number, Creation Date, Customer Name/ID, Status Badge (`PAID`, `PARTIAL`, `UNPAID`, `VOID`), Total Amount.

---

### ➕ 5.2 [CreateInvoiceScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/create_invoice_screen.dart)
* **Form / Input Fields**:
  - `Scanned Barcode Bar`: Barcode display tile with camera scan button.
  - `Customer Name / Phone`: Optional text input field.
  - `Subtotal Amount (₹)`: Numeric input field (Required).
  - `Tax Amount (₹)`: Numeric input field (Optional).
* **Interactive Actions & Buttons**:
  - `Scan Barcode` Header/Card Button: Launches `BarcodeScannerDialog`.
  - `Save & Complete Invoice` Button: Generates and records invoice.
  - `Thermal Receipt` Action Button: Generates 80mm thermal receipt preview via `InvoicePdfService`.
  - `Print PDF` Action Button: Generates A4 printable invoice document.

---

### 📄 5.3 [InvoiceDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/invoice_detail_screen.dart)
* **Interactive Actions & Buttons**:
  - `Thermal Receipt` Button: Generates receipt PDF via `printing` package.
  - `A4 PDF Invoice` Button: Generates standard PDF invoice.
  - `Collect Payment` Button: Launches payment dialog for outstanding balance.
  - `Void Transaction` Button: Voids invoice and restores product inventory stock.
* **Data Displays & Fields**:
  - `Invoice Header`: Invoice Number, Creation Date, Status Badge (`PAID`, `PARTIAL`, `UNPAID`, `VOID`), Customer ID/Name.
  - `Financial Summary`: Total Amount, Paid Amount, Balance Due Amount.
  - `Itemized Line Items Table`: Product Name, SKU, Quantity, Unit Price, Line Total.
* **Collect Payment Modal Dialog**:
  - `Payment Amount`: Numeric input field.
  - `Payment Method`: Dropdown selector (`CASH`, `CARD`, `UPI`, `BANK_TRANSFER`).
  - `Note`: Optional description text field.

---

## 6. Expenses & Analytics

### 💸 6.1 [ExpenseListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/expenses/presentation/screens/expense_list_screen.dart)
* **Interactive Actions & Buttons**:
  - `Category Filter Chips`: Horizontal scroll chip bar (`All`, `Rent`, `Utilities`, `Inventory Purchases`, `Transport`, `Salaries`, `Other`).
  - `Delete Expense` Icon Button: Opens deletion confirmation modal.
  - `Add Expense` Extended FAB: Navigates to `AddExpenseScreen`.
* **Data Displays**:
  - `Total Business Expenses Card`: Filtered total expense sum (₹).
  - `Expense Cards List`: Category title, Expense Date, Note, Amount formatted in currency (₹).

---

### ➕ 6.2 [AddExpenseScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/expenses/presentation/screens/add_expense_screen.dart)
* **Form / Input Fields**:
  - `Expense Category`: Dropdown menu selector (`Rent`, `Utilities`, `Inventory Purchases`, `Transport`, `Salaries`, `Other`).
  - `Amount (₹)`: Numeric input field (Required).
  - `Date Tile`: Date picker input tile (`_pickDate()` launches `showDatePicker`).
  - `Notes / Description`: Optional multiline text input field.
* **Interactive Actions & Buttons**:
  - `Save Expense` Button: Submits expense entry to `expenseControllerProvider`.

---

### 📈 6.3 [AnalyticsScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/analytics/presentation/screens/analytics_screen.dart)
* **Interactive Actions & Buttons**:
  - `Time Horizon Segmented Button`: Time range switcher (`Today`, `7 Days`, `Month`, `All Time`).
* **Data Displays & Metrics**:
  - `Gross Sales Revenue`: Formatted sales total (₹).
  - `Total Expenses`: Formatted expense total (₹).
  - `Net Profit / Loss`: Revenue minus expenses with Profit Margin %.
  - `Payment Methods Breakdown`: Total payments grouped by payment method (`CASH`, `UPI`, `CARD`, `BANK_TRANSFER`).
  - `Category Breakdown`: Expenses grouped by category with visual progress bars.
