<div align="center">
  <img src="assets/AppIcons/AppIcon.icon/Assets/icon.png" alt="Financials Logo" width="110" height="110" style="border-radius: 24px;" />
  <h1>Financials</h1>
  <p><strong>Smart money, clear vision.</strong></p>
  <p>A modern, multi-currency personal finance & expense tracker built with Flutter, Clean Architecture (MVVM), and AI Agent Skills.</p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-10B981?style=for-the-badge" alt="Clean Architecture + MVVM" />
    <img src="https://img.shields.io/badge/Design-UI%2FUX%20Pro%20Max-6366F1?style=for-the-badge" alt="UI/UX Pro Max" />
    <img src="https://img.shields.io/badge/Workflow-AI%20Agent%20Skills-F59E0B?style=for-the-badge" alt="AI Agent Skills" />
  </p>
</div>

---

## ✨ Features

- **📊 Monthly Financial Dashboard** — Track your net monthly balance, total income, total expenses, and monthly savings rate at a glance.
- **🌍 Multi-Currency Support** — Log transactions in **USD ($)**, **EUR (€)**, **GBP (£)**, **MAD (DH)**, **JPY (¥)**, **CAD (CA$)**, and **AED**, with automatic real-time normalization into your chosen primary display currency.
- **🏷️ Custom & Default Categories** — Organize expenses with built-in categories (Housing, Food & Dining, Transportation, Entertainment, Shopping, etc.) or create your own custom categories with custom icons and colors.
- **📈 Spending Analytics & Breakdown** — Interactive visual breakdown of spending by category, percentage shares, and top spending highlights for any selected month.
- **🌓 System-Adaptive Dark & Light Mode** — Crafted with a modern fintech glassmorphic palette and **IBM Plex Sans** typography (`google_fonts`), automatically adapting to your device's system theme.
- **💾 100% Private Local Persistence** — All transactions and custom categories are stored locally on your device via `shared_preferences`. No cloud account required, and starts completely fresh (`$0.00`).
- **↩️ Swipe-to-Delete with Undo** — Effortlessly remove transactions with an instant snackbar Undo option.
- **📤 Multi-Platform Sharing** — Built-in Settings share sheet integration (`share_plus`) to share the app across WhatsApp, Facebook, X/Twitter, Instagram, Telegram, Email, and SMS.

---

## 🤖 AI-Augmented Engineering & Agent Skills

This project was engineered using an **AI-Augmented Agentic Workflow** powered by specialized **Dart**, **Flutter**, and **UI/UX Pro Max** agent skills to enforce architectural boundaries, design system consistency, and automated verification:

| Skill Category | Agent Skill Used | Engineering Impact |
| :--- | :--- | :--- |
| **🏛️ Clean Architecture** | `flutter-apply-architecture-best-practices` | Enforced strict separation of concerns across **UI (MVVM)**, **Domain (Use Cases & Entities)**, and **Data (DTOs, Repositories, Services)** layers. |
| **🎨 Design Intelligence** | `ui-ux-pro-max` | Designed a fintech glassmorphism aesthetic with accessible contrast ratios, system-adaptive Dark/Light palettes (`#080D1A` / `#F8FAFC`), and **IBM Plex Sans** typography. |
| **🔄 Serialization & Dart 3** | `flutter-implement-json-serialization`<br>`dart-use-pattern-matching` | Implemented type-safe Data Layer DTOs (`TransactionStorageModel`, `CategoryStorageModel`) using Dart 3 switch pattern matching and domain mappers. |
| **🧪 Testing & Verification** | `dart-add-unit-test`<br>`flutter-add-widget-test` | Built unit and widget tests verifying DTO serialization, `SharedPreferences` persistence, multi-currency analytics, ViewModels, and UI flows. |
| **🔍 Static Analysis** | `dart-run-static-analysis` | Verified zero lint warnings or errors via `dart analyze` and tree-shake-safe constant icon resolution. |

---

## 🏗️ Clean Architecture Structure

The codebase strictly follows **Clean Architecture** and **MVVM (Model-View-ViewModel)** principles:

```text
lib/
├── main.dart                                  # App entry point & Dependency Injection
├── data/                                      # DATA LAYER (Grouped by type)
│   ├── models/                                # Storage DTOs (JSON serialization & domain mappers)
│   │   ├── category_storage_model.dart
│   │   └── transaction_storage_model.dart
│   ├── repositories/                          # Concrete repository implementations
│   │   └── transaction_repository_impl.dart
│   └── services/                              # Platform & local storage services
│       ├── share_service.dart
│       └── transaction_local_service.dart
├── domain/                                    # DOMAIN LAYER (Pure business logic & contracts)
│   ├── models/                                # Domain entities (TransactionItem, AppCurrency, MonthlyAnalytics)
│   │   ├── currency.dart
│   │   ├── spending_analytics.dart
│   │   └── transaction_item.dart
│   ├── repositories/                          # Abstract repository interfaces
│   │   └── transaction_repository.dart
│   └── use_cases/                             # Business logic use cases
│       └── calculate_monthly_analytics_use_case.dart
└── ui/                                        # UI LAYER (Grouped by feature, MVVM)
    ├── core/
    │   └── theme/
    │       └── app_theme.dart                 # Dark & Light theme definitions
    └── features/
        ├── splash/
        │   └── views/
        │       └── splash_screen.dart         # Animated launch screen
        ├── tracker/
        │   ├── view_models/
        │   │   └── expense_tracker_view_model.dart
        │   └── views/
        │       ├── home_screen.dart
        │       └── widgets/                   # Modular tracker UI components
        ├── statistics/
        │   └── views/
        │       └── statistics_screen.dart     # Monthly category breakdown & charts
        └── settings/
            ├── view_models/
            │   └── settings_view_model.dart
            └── views/
                └── settings_screen.dart
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.11.0` or compatible Dart 3 SDK)
- Android Studio / Xcode / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yaonekk/financials.git
   cd financials
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

---

## 🧪 Running Tests & Static Analysis

The project includes unit and widget tests covering the Data layer DTOs/repositories, Domain analytics use cases, ViewModels, and UI screens.

```bash
# Run static analyzer
dart analyze

# Run all unit and widget tests
flutter test
```

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Material 3)
- **Language:** [Dart 3](https://dart.dev/) (Pattern matching, strict typing)
- **Architecture:** Clean Architecture + MVVM (`ChangeNotifier` & `ListenableBuilder`)
- **Design System:** `ui-ux-pro-max` Fintech Glassmorphism (System Light & Dark Mode)
- **Local Storage:** [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- **Typography:** [`google_fonts`](https://pub.dev/packages/google_fonts) (`IBM Plex Sans`)
- **Platform Sharing:** [`share_plus`](https://pub.dev/packages/share_plus)

---

<div align="center">
  Made with ❤️ by <strong>BrightLab</strong>
</div>
