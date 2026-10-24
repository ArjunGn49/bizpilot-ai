# BizPilot AI — Screen-by-Screen Pending Fields & Feature Audit

This document provides a comprehensive audit of all 23 screens in the BizPilot AI application, listing currently implemented fields and outlining potential pending fields or feature enhancements to elevate each screen to enterprise production standards.

---

## 🔑 1. Authentication & Onboarding

### 1.1 [LoginScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/login_screen.dart)
* **Implemented Fields**: Email, Password, Sign In button, Forgot Password link, Continue with Google button.
* **Pending Fields & Features**:
  - `[ ]` Password Visibility Toggle button (eye icon inside password field).
  - `[ ]` "Remember Me" session persistence checkbox.
  - `[ ]` Biometric Authentication (Fingerprint / FaceID) login shortcut button.

### 1.2 [SignupScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/signup_screen.dart)
* **Implemented Fields**: Email, Password, Confirm Password, Create Account button, Sign up with Google button.
* **Pending Fields & Features**:
  - `[ ]` Full Name field.
  - `[ ]` Mandatory Terms of Service & Privacy Policy agreement checkbox.
  - `[ ]` Password Strength Progress Meter indicator.

### 1.3 [PasswordResetScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/auth/presentation/screens/password_reset_screen.dart)
* **Implemented Fields**: Email, Send Reset Email button, Return to Sign In link.
* **Pending Fields & Features**:
  - `[ ]` Resend Email 60-second countdown timer.

### 1.4 [OnboardingScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/onboarding/presentation/screens/onboarding_screen.dart)
* **Implemented Fields**: Store Name, Business Phone, Address, Currency Symbol selector, Tax Label.
* **Pending Fields & Features**:
  - `[ ]` Default Tax Rate Percentage (%) input field.
  - `[ ]` Store Logo image upload button during setup step 1.

---

## 📊 2. Core Dashboard & AI Intelligence

### 2.1 [DashboardScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/dashboard/presentation/screens/dashboard_screen.dart)
* **Implemented Fields**: User Greeting, Total Sales Revenue, Collected Revenue, Pending Due, Invoices Count, Low Stock Warning Banner, AI Assistant Header Action, Quick POS Shortcuts, Module Navigation Cards, Cloud Sync button, Sign Out button.
* **Pending Fields & Features**:
  - `[ ]` Date Range Filter Dropdown (Today, This Week, This Month, All Time) for revenue cards.
  - `[ ]` Offline / Online Network Status Badge Chip in App Bar.

### 2.2 [AiAssistantScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/ai_assistant/presentation/screens/ai_assistant_screen.dart)
* **Implemented Fields**: Chat Message Feed, Query Input, Send Button, Quick Suggestion Chips (*Low Stock*, *Pending Dues*, *Revenue Overview*, *Product Count*), Clear Chat action.
* **Pending Fields & Features**:
  - `[ ]` Voice Input Microphone Button (Speech-to-Text).
  - `[ ]` Export Chat Session as PDF Report action.

### 2.3 [NotificationsScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/notifications/presentation/screens/notifications_screen.dart)
* **Implemented Fields**: Filter Segment (*All Alerts*, *Low Stock*, *Payment Dues*), Low Stock Warning Cards, Overdue Invoice Balance Cards.
* **Pending Fields & Features**:
  - `[ ]` "Mark All Notifications as Read" action button.
  - `[ ]` Push Notifications Toggle switch.

### 2.4 [CreatePostScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/post/presentation/screens/create_post_screen.dart)
* **Implemented Fields**: Announcement Title, Target Audience Dropdown, Post Message Body, Attach Image button, Publish button.
* **Pending Fields & Features**:
  - `[ ]` Promo Post Expiry Date Picker field.
  - `[ ]` Schedule Post Date & Time selector.

### 2.5 [ProfileScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/profile/presentation/screens/profile_screen.dart)
* **Implemented Fields**: Gradient Banner, Avatar, Name, Verified Badge, Subtitle, Bio, Social Links, Interests Chips, Professions Chips, Contact Fields, Rotated Icon Fields, Experience & Education Tile Lists.
* **Pending Fields & Features**:
  - `[ ]` "Edit Profile Form" action button.
  - `[ ]` "Download Bio / CV PDF" export button.

---

## 📦 3. Products & Inventory Management

### 3.1 [ProductListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/product_list_screen.dart)
* **Implemented Fields**: Search Bar (Name/SKU/Barcode), Barcode Camera Scanner Button, Category Filter Chips, Low Stock Filter Chip, Product Cards List.
* **Pending Fields & Features**:
  - `[ ]` Sorting Selector (Price Low to High, High to Low, Name A-Z).
  - `[ ]` Bulk Export Product Inventory Catalog to CSV.

### 3.2 [ProductDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/product_detail_screen.dart)
* **Implemented Fields**: Name, SKU, Barcode, Stock Status Badge, Current Stock, Threshold, Selling Price, Cost Price, Profit Margin (₹), Margin %, Edit/Delete buttons, Manual Stock Adjustment Modal (`+ Restock` / `- Deduct`).
* **Pending Fields & Features**:
  - `[ ]` Product Photo Gallery Carousel.
  - `[ ]` Stock Movement Audit Trail Log List.

### 3.3 [AddEditProductScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/products/presentation/screens/add_edit_product_screen.dart)
* **Implemented Fields**: Product Name, SKU, Barcode (with scanner button), Category Dropdown, Selling Price, Cost Price, Stock Quantity, Low Stock Threshold, Save/Delete buttons.
* **Pending Fields & Features**:
  - `[ ]` Serial Number & IMEI text fields.
  - `[ ]` Multi-image photo picker gallery upload.

---

## 👥 4. Customer Management

### 4.1 [CustomerListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/customer_list_screen.dart)
* **Implemented Fields**: Live Search Bar (Name/Phone), Customer Cards with Outstanding Balance, Add Customer FAB.
* **Pending Fields & Features**:
  - `[ ]` Customer Sorting Selector (Name A-Z, Total Spent, Highest Due).
  - `[ ]` "Import Contacts from Phone Address Book" button.

### 4.2 [CustomerDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/customer_detail_screen.dart)
* **Implemented Fields**: Contact Info, Total Orders Count, Lifetime Spent, Outstanding Due, Itemized Purchase History Invoice List, Collect Payment Modal Dialog, Edit/Delete Profile buttons.
* **Pending Fields & Features**:
  - `[ ]` WhatsApp / SMS Balance Reminder Share Button (`url_launcher`).

### 4.3 [AddEditCustomerScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/customers/presentation/screens/add_edit_customer_screen.dart)
* **Implemented Fields**: Name, Phone, Email, Address, Save/Delete buttons.
* **Pending Fields & Features**:
  - `[ ]` Customer Group / Tier Tag selector (*Retail*, *Wholesale*, *VIP*).
  - `[ ]` "Pick Contact from Phone" auto-fill button.

---

## 🧾 5. Invoicing & Point-of-Sale (POS)

### 5.1 [InvoiceListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/invoice_list_screen.dart)
* **Implemented Fields**: Live Search Bar (Invoice # / Customer ID), Status Filter Chips (`All`, `Paid`, `Pending`, `Void`), Invoice Cards List.
* **Pending Fields & Features**:
  - `[ ]` Date Range Filter Picker (This Week, This Month, Custom Date Range).
  - `[ ]` Bulk Export Invoices Report to CSV.

### 5.2 [CreateInvoiceScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/create_invoice_screen.dart)
* **Implemented Fields**: Customer Selection Dropdown, Barcode Scanner launcher, Itemized Cart (Product name, SKU, Unit price, Quantity controls `-`/`+`, Line Total, Delete button), Empty Cart State, Subtotal, Discount (₹), Tax (₹), Grand Total, Payment Received, Payment Method, Note, Save & Complete Invoice button, 80mm Thermal Receipt button, A4 PDF Invoice button.
* **Pending Fields & Features**:
  - `[ ]` Payment Terms / Due Date Picker (*Due on Receipt*, *Net 15*, *Net 30*).
  - `[ ]` "Save as Draft Invoice" action button.

### 5.3 [InvoiceDetailScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/invoices/presentation/screens/invoice_detail_screen.dart)
* **Implemented Fields**: Invoice Number, Date, Customer Name/ID, Payment Status Badge, Total Amount, Paid Amount, Balance Due Amount, Itemized Line Items Table, Thermal Receipt button, A4 PDF Invoice button, Collect Payment modal, Void Invoice action.
* **Pending Fields & Features**:
  - `[ ]` Direct "Share PDF via WhatsApp / Email" Share Sheet action (`share_plus`).

---

## 💸 6. Expenses & Financial Analytics

### 6.1 [ExpenseListScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/expenses/presentation/screens/expense_list_screen.dart)
* **Implemented Fields**: Total Expense Summary Card, Category Filter Chips (`All`, `Rent`, `Utilities`, `Inventory Purchases`, `Transport`, `Salaries`, `Other`), Expense Cards List, Delete Expense modal.
* **Pending Fields & Features**:
  - `[ ]` Date Range Filter Picker.
  - `[ ]` Search Bar (filter by Payee or Note).
  - `[ ]` Export Expenses Report to CSV / PDF.

### 6.2 [AddExpenseScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/expenses/presentation/screens/add_expense_screen.dart)
* **Implemented Fields**: Category Dropdown, Amount (₹), Date Picker Tile, Notes field, Save Expense button.
* **Pending Fields & Features**:
  - `[ ]` Receipt Photo Camera Upload Attachment button.
  - `[ ]` Recurring Expense Switch (*Monthly Rent*, *Subscriptions*).

### 6.3 [AnalyticsScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/analytics/presentation/screens/analytics_screen.dart)
* **Implemented Fields**: Time Horizon Segmented Button (*Today*, *7 Days*, *Month*, *All Time*), Net Profit Summary Card, Profit Margin %, Gross Sales Metric, Total Expenses Metric, Invoices Count Metric, Sales vs Expense Financial Bar Chart, Category Expense Breakdown.
* **Pending Fields & Features**:
  - `[ ]` Export Profit & Loss Statement as PDF Report.
  - `[ ]` Top Selling Products Ranking Table.

### 6.4 [SettingsScreen](file:///D:/BizPilotAI/bizpilotai_app/lib/features/settings/presentation/screens/settings_screen.dart)
* **Implemented Fields**: Theme Mode Selector (`System`, `Light`, `Dark`), Store Name, Business Phone, Store Address, Currency Symbol Selector (`₹`, `$`, `€`, `£`, `A$`, `R$`), Tax Label (`GST`/`VAT`), Receipt Footer Message, Upload Store Logo button, Cloud Sync button, App Version.
* **Pending Fields & Features**:
  - `[ ]` Default Tax Rate Percentage (%) input field.
  - `[ ]` Local Database Backup & Restore button.
