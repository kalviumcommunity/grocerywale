# StockFlow - Grocery Replenishment & Shared Pipeline System

StockFlow is a Flutter application designed for multi-store grocery chains restocking from a central warehouse. It eliminates replenishment blind spots and prevents daily revenue loss on high-demand, fast-moving items by providing real-time shared visibility across store managers and warehouse operations.

---

## 🎯 Problem Solved

In traditional grocery chains restocking from a central warehouse:
1. **Lack of Shared Pipeline Visibility**: Store managers have no visibility into whether their restock requests are received, approved, packing, or in transit. Central warehouse teams lack a unified, prioritized queue of demands from across all chain stores.
2. **Fast-Moving Stockouts & Lost Revenue**: High-turnover goods (milk, eggs, bread, bananas, beverages) run out before the regular replenishment cycle completes. Without predictive stockout thresholds or emergency priority routes, stores face empty shelves during peak traffic hours.

---

## 🚀 Key Features

### 1. Shared Replenishment Pipeline (`Requested` ➔ `Approved` ➔ `Dispatched` ➔ `Received`)
- **Real-Time Cross-Role Visibility**: Both store managers and warehouse supervisors track every order's stage, timestamp, and audit trail in real time.
- **Visual Pipeline Stepper**: Interactive step tracker displaying exact timestamps, approver names, carrier fleet names, tracking waybill references, and estimated arrival times (ETA).
- **One-Tap Store Restock Receipt**: Store managers confirm receipt with one click upon delivery, automatically reconciling and increasing local store shelf quantities.

### 2. Fast-Moving Items & Stockout Risk Prevention
- **Velocity Classification**: Items are classified by turnover velocity (`Fast-Moving`, `Standard`, `Slow-Moving`).
- **Dynamic Stockout Prediction**: Calculates hours until stockout based on real-time store inventory and daily burn rate (`hours = storeStock / (dailyBurnRate / 24)`).
- **1-Tap Emergency Restock**: Critical stockout alerts with instant emergency replenishment requests routed straight to the top of the central warehouse queue.
- **Priority Badging**: Flashing/distinctive priority badges for emergency high-turnover restocks.

### 3. Central Warehouse Fulfillment Hub
- **Chain-wide Demand Queue**: Aggregates restock requests from all stores (Downtown Metro, Westside Supercenter, Suburban Plaza, etc.).
- **Inventory Allocation**: Checks central warehouse inventory before approval to prevent over-allocation.
- **Dispatch Logistics Assignment**: Assigns carrier fleet, tracking number, and delivery ETA upon dispatch.

### 4. Interactive Role & Store Switcher
- Seamlessly toggle between **Store Manager** (store-specific inventory, creation, receipt) and **Central Warehouse** (chain-wide approvals, allocations, dispatches) to test and operate the entire replenishment workflow.

---

## 📂 Project Architecture

```
stockflow/
├── lib/
│   ├── main.dart                      # App entry point with custom Material 3 theme
│   ├── models/
│   │   ├── grocery_item.dart          # Item model with velocity, burn rate & stockout calculations
│   │   ├── replenishment_request.dart # Request lifecycle, items, status & priority definitions
│   │   └── store_info.dart            # Store metadata & role definitions
│   ├── services/
│   │   └── inventory_service.dart     # Central reactive store & warehouse inventory state manager
│   ├── widgets/
│   │   ├── app_button.dart            # Reusable styled button
│   │   ├── fast_moving_alert_banner.dart # Stockout risk banner with 1-tap emergency restock
│   │   ├── pipeline_stepper.dart      # 4-stage visual progress tracker with audit details
│   │   ├── priority_badge.dart        # Urgency & velocity badges
│   │   ├── status_badge.dart          # Color-coded status chip (Requested, Approved, Dispatched, Received)
│   │   └── stock_indicator.dart       # Store vs warehouse stock progress meter
│   └── screens/
│       ├── login_screen.dart          # Role selection and credentials login
│       ├── home_shell_screen.dart     # Bottom navigation shell
│       ├── dashboard_screen.dart      # Overview KPIs, urgent alerts & pipeline summary
│       ├── pipeline_screen.dart       # Shared status pipeline with tabbed filtering
│       ├── inventory_screen.dart      # Store catalog, velocity monitor & burn rates
│       ├── create_request_screen.dart # Multi-item catalog restock builder with emergency toggle
│       ├── request_detail_screen.dart # Full order details, timeline & contextual actions
│       └── warehouse_console_screen.dart # Central warehouse fulfillment & dispatch console
└── test/
    ├── replenishment_pipeline_test.dart # Unit tests covering full state lifecycle & velocity calculations
    ├── pipeline_screen_test.dart        # Widget tests for pipeline UI, tabs & status filters
    └── widget_test.dart                 # End-to-end login & home shell loading test
```

---

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (v3.13+)
- Dart SDK

### Installation
1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the test suite:
   ```bash
   flutter test
   ```

3. Launch the app:
   ```bash
   flutter run
   ```
