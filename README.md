# Customer Management App (Frontend)

A responsive Flutter application built for managing customer profiles, integrated with a **Next.js 16 + MongoDB Atlas REST API** backend for data persistence and **Firebase Phone Authentication** for login.

---

## 🚀 Tech Stack & Core Libraries

- **Framework**: Flutter (Material 3 UI, custom light/dark themes)
- **State Management**: BLoC / Cubits (`flutter_bloc`)
- **API Backend**: Next.js 16 REST API
- **Database**: MongoDB Atlas via Mongoose
- **Authentication**: Firebase Phone Auth (with graceful offline fallback)
- **Networking**: `http` package for REST API communication
- **State Caching**: SharedPreferences

---

## 📦 Project Structure

The project uses a clean, repository-based architecture to decouple the UI from the database implementation:

```
lib/
 ├── core/
 │    ├── constants/      # App Constants & Demo credentials
 │    ├── theme/          # Material 3 Color Schemes & field styling
 │    └── utils/          # Formatting helpers
 │
 ├── models/              # Customer data models & JSON/Map serialization
 ├── repositories/        # Repository pattern interfaces
 │    ├── customer_api_service.dart  # REST API Service wrapper
 │    └── customer_repository.dart   # Implementation (RestCustomerRepository, LocalCustomerRepository, FirestoreCustomerRepository)
 ├── providers/           # BLoC Cubits (Theme, Authentication, Customers)
 ├── screens/             # UI Presentation Layer
 │    ├── auth/           # Login & PIN verification screens
 │    ├── dashboard/      # Stat counters & Action grids
 │    ├── customer/       # Customer Directory, Add, Detail, & Edit forms
 │    └── profile/        # Admin settings, theme toggle, and sign out
 └── main.dart            # Bootstrap, REST repository injection, and routing
```

---

## 🛠️ Setup & Execution

### 1. Prerequisites
- Flutter SDK (v3.11.0+)
- Android Studio / VS Code
- Next.js Backend running on the local network (see the Backend repository setup instructions)

### 2. Configure Backend Integration
Before running the application, make sure the frontend points to the computer running the Next.js backend:
1. Find your backend computer's local IPv4 address (e.g., `10.252.64.131` on Windows via `ipconfig`, or macOS/Linux via `ifconfig`).
2. Open [`lib/main.dart`](lib/main.dart) and configure the `baseUrl` in the repository injection block:
   ``` dart
   customerRepository = RestCustomerRepository(
     CustomerApiService(baseUrl: 'http://<YOUR-IP-ADDRESS>:3000/api/customers'),
   );
   ```

### 3. Install Dependencies
Run the following command in the root folder of the Flutter project:
```bash
flutter pub get
```

### 4. Run the Application
Start the app on an emulator or a physical test device connected to the same Wi-Fi network:
```bash
flutter run
```

---

## 💡 How to Test the App (Data Options)

The repository pattern allows swapping the data source easily. By default, it is configured to use the REST API:

### **Option A: REST API Backend Mode (Default & Active)**
- All customer operations (List, Add, Update, Search, and Delete) call the Next.js REST API.
- Customer profiles are persisted to MongoDB Atlas.
- **Login Credentials**:
   - **Mobile Number**: `9999999999`
   - **Verification OTP**: `123456` (Uses Firebase test authentication credentials).

### **Option B: Local SharedPreferences Fallback**
- To switch to fully local mode, update `lib/main.dart` to instantiate `LocalCustomerRepository()` instead of `RestCustomerRepository()`.
- Data is saved directly on the client device inside `SharedPreferences` (perfect for offline testing).

### **Option C: Firebase Firestore Mode**
- The original Firebase integration can be restored by instantiating `FirestoreCustomerRepository()` in `lib/main.dart`.
- Requires your own `google-services.json` inside `android/app/` with Firestore enabled.

---

## ✨ Features Checklist
- [x] **Next.js REST API Client**: CRUD endpoints integration via the `http` package.
- [x] **Responsive Dashboards**: Adapts to mobile, tablet, and web viewports, using constraints and dynamic row-grid alignments.
- [x] **Master-Detail Layout**: Dual-pane master-detail list configuration for larger screens (>= 720 dp width).
- [x] **OTP Verification UI**: Verification fields with automatic autofocus for login inputs.
- [x] **Real-time Synchronization**: Pull-to-refresh controllers, detailed state feedback, and instant search.
- [x] **Comprehensive Error Handling**: Dynamic error SnackBars displaying exact API/network exceptions in Red.
- [x] **Universal Dark Mode**: Dynamically switches and caches theme states.

---


## APK Download

APK file is included in the submission package.


## Screenshots

### Login Screen
<img width="717" height="1600" alt="image" src="https://github.com/user-attachments/assets/48e4e965-ff07-4d0f-b1a4-92be53d8b607" />

### Dashboard
<img width="717" height="1600" alt="image" src="https://github.com/user-attachments/assets/c41309f5-d592-4514-b54b-60c99ab27a63" />

### Customer List
<img width="1080" height="2408" alt="image" src="https://github.com/user-attachments/assets/30d369d4-b706-4609-80b8-824f8c4da4a6" />

### Add Customer
<img width="1080" height="2408" alt="image" src="https://github.com/user-attachments/assets/8639a6c8-7a28-4562-b603-9f48b72e21b8" />

## Author

Anjali Agarwal

Flutter Developer

Assignment Submission for GYBL Flutter & Firebase Developer Internship
