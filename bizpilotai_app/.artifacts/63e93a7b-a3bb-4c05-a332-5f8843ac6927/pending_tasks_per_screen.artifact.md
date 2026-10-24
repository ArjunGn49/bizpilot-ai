# BizPilot AI - Pending Features & Tasks Per Screen

This document outlines all completed functionality as well as the remaining/pending feature enhancements for every screen in the BizPilot AI application.

---

## 1. Authentication & Onboarding Screens

### 🔑 [LoginScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/login_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Add Google Sign-In button UI and wire OAuth provider method.
  - [ ] Add "Remember Me" checkbox for persistent session preference.
  - [ ] Integrate Biometric (Fingerprint/FaceID) authentication option.

### 📝 [SignupScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/signup_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Add Google Sign-In / OAuth single-tap registration button.
  - [ ] Add Terms of Service & Privacy Policy agreement checkbox.
  - [ ] Add optional Business Name field during registration step.

### 🔒 [PasswordResetScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/password_reset_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Add resend email countdown timer (60s cooldown).
  - [ ] Add return to login confirmation dialog on success.

---

## 2. Core & Management Screens

### 📊 [DashboardScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/dashboard/presentation/screens/dashboard_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Add custom date range filter for revenue summary cards.
  - [ ] Add quick mini chart preview for daily sales trends.
  - [ ] Add offline/online network status badge banner.

### ⚙️ [SettingsScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/settings/presentation/screens/settings_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Store logo image picker and receipt header customization.
  - [ ] Custom invoice footer message field.
  - [ ] Export/Backup local database to JSON/CSV option.

---

## 3. Product & Inventory Management

### 📦 [ProductListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/product_list_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Add Category filter chips bar at the top.
  - [ ] Add Stock Status filter dropdown (In Stock, Low Stock, Out of Stock).
  - [ ] Bulk import/export products via CSV.

### 🔍 [ProductDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/product_detail_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Add product image upload/display preview.
  - [ ] Add stock movement log (track manual stock adjustments & sales history).
  - [ ] Printable barcode/QR label generator button.

### ➕ [AddEditProductScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/add_edit_product_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Multi-image gallery picker.
  - [ ] Dynamic profit margin calculation indicator based on Cost Price vs Selling Price.

---

## 4. Customer Management

### 👥 [CustomerListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/customer_list_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Add Search bar (by name or phone number).
  - [ ] Add sorting options (Alphabetical, Total Spent, Outstanding Balance).
  - [ ] Import customer contacts from phone contact book.

### 👤 [CustomerDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/customer_detail_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] WhatsApp / SMS payment reminder button for outstanding dues.
  - [ ] "Collect Payment" quick action button directly from customer profile.

### ✏️ [AddEditCustomerScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/add_edit_customer_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] "Pick from Phone Contacts" button to autofill name, phone, and email.
  - [ ] Customer group / tier tag assignment (e.g., Wholesale, VIP, Retail).

---

## 5. Invoicing & Billing

### 🧾 [InvoiceListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/invoice_list_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Status filter tabs (All, Paid, Pending, Overdue, Void).
  - [ ] Invoice search bar by invoice number or customer name.
  - [ ] Date range filter (This Week, This Month, Custom).

### ➕ [CreateInvoiceScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/create_invoice_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Direct barcode scanning shortcut to quickly add items into invoice line items.
  - [ ] Payment terms / due date picker (e.g., Net 15, Net 30, Due on Receipt).
  - [ ] "Save as Draft" invoice status support.

### 📄 [InvoiceDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/invoice_detail_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Direct "Share PDF via WhatsApp / Email" action button.
  - [ ] Convert to recurring invoice option.

---

## 6. Expenses & Analytics

### 💸 [ExpenseListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/expenses/presentation/screens/expense_list_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Date range filter picker.
  - [ ] Expense notes / payee search bar.
  - [ ] Export expenses report to CSV / PDF.

### ➕ [AddExpenseScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/expenses/presentation/screens/add_expense_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Receipt photo attachment (camera / gallery upload).
  - [ ] Recurring expense toggle (Monthly rent, subscriptions).

### 📈 [AnalyticsScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/analytics/presentation/screens/analytics_screen.dart)
- **Status**: Implemented
- **Pending Tasks**:
  - [ ] Visual charts & graphs (e.g., monthly revenue vs expense line chart, sales by category pie chart).
  - [ ] Export Profit & Loss statement to PDF/CSV.
