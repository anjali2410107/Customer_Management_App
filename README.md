# Customer Management App

A Flutter application built for the Flutter & Firebase Developer Internship Assignment at Get Your Businesses Live (GYBL).
---

## 🚀 Tech Stack
- **Framework**: Flutter
- **State Management**: BLoC / Cubits (`flutter_bloc`)
- **Database**: Firebase Firestore (`cloud_firestore`)
- **Authentication**: Firebase Phone Auth / Demo OTP
- **Theme & State Cache**: SharedPreferences
- **Design System**: Material 3 (Custom Light & Dark Mode)

---

## 📦 Project Structure

The project follows a clean, feature-driven structure:

```
lib/
 ├── core/
 │    ├── constants/      # App Constants & Demo credentials
 │    ├── theme/          # Material 3 Color Schemes & Field styling
 │    └── utils/          # Formatting helpers
 │
 ├── models/              # Customer data models & JSON/Map encoders
 ├── repositories/        # Database contracts (Firestore & SharedPreferences fallbacks)
 ├── providers/           # BLoC Cubits (Theme, Authentication, Customers)
 ├── screens/             # UI Presentation Layer
 │    ├── auth/           # Login & Pin Input verification screens
 │    ├── dashboard/      # Stat counters & Action grids
 │    ├── customer/       # Customer Directory, Add, Detail, & Edit forms
 │    └── profile/        # Admin settings, theme toggle, and sign out
 └── main.dart            # Bootstrap, provider injection, and routing
```

---

## 🛠️ Setup & Execution


### Clone Repository

```bash
git clone https://github.com/anjali2410107/Customer_Management_App.git
cd Customer_Management_App
```


### **1. Prerequisites**
- Flutter SDK (v3.11.0+)
- Android Studio / VS Code

### **2. Dependencies Installation**
In the root directory, fetch the required packages:
```bash
flutter pub get
```

### **3. Running the App**
To launch on a connected device/emulator:
```bash
flutter run
```

---

## 💡 How to Test the App (2 Options)

This app contains a **graceful Firebase failure fallback system** that ensures the app runs perfectly under any developer configuration:

### **Option A: Local Demo Mode (Recommended - No Setup Needed)**
To test all database and login operations immediately without configuring Firebase accounts or billing:
1. Ensure there is **no** `google-services.json` file inside the `android/app/` folder (or rename it to `google-services.json.bak`).
2. Run/Restart the app.
3. The app will display an orange **"Local Demo Mode"** badge at the top right.
4. **Log In Credentials**:
   - **Mobile Number**: `9999999999`
   - **Verification OTP**: `123456`
5. *Note*: In this mode, both the login session and all customer CRUD operations (Add, View, Edit, Search, and Delete) run locally and persist on your device.

### **Option B: Real Firebase Mode**
To run with your live Firebase instance:
1. Place your `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`.
2. Enable **Phone Authentication** and **Firestore Database** in the Firebase Console.
3. Add your debug **SHA-256** and **SHA-1** key fingerprints to your Firebase project settings.
4. Allow **India (+91)** (or your region) under **Authentication -> Settings -> SMS region policy**.
5. *Note*: You can register test numbers in the Console (Authentication -> Users -> Add test phone number) to test specific mobile numbers with custom mock OTP codes without consuming SMS pricing quotas.

---

## ✨ Features Checklist
- [x] **OTP Verification**: Auto-focus pin inputs for OTP validation.
- [x] **Customer Directory**: Search customers locally by name with zero-delay indexing.
- [x] **Real-time Synchronization**: Pull-to-refresh controllers and live database streams.
- [x] **Interactive CRUD**: Add, Edit, View Details, and Swipe-to-delete with confirmation alerts.
- [x] **Universal Dark Mode**: Dynamically switches and caches theme states.
- [x] **Robust Widget Testing**: Completed widget tests verify compile integrity.

## Demo Credentials

For evaluation purposes:

Mobile Number: 9999999999

OTP: 123456

Firebase Test Phone Authentication has been configured using Firebase Test Numbers.


## Assignment Requirements Covered

- Firebase Phone Authentication
- OTP Verification
- Dashboard with Customer Count
- Add Customer
- View Customer List
- Search Customer
- Customer Details
- Update Customer
- Delete Customer
- BLoC State Management
- Firebase Firestore Integration
- Dark Mode

## APK Download

APK file is included in the submission package.




## Screenshots

### Login Screen
![img.png](img.png)

### Dashboard
![img_1.png](img_1.png)
### Customer List
![img_2.png](img_2.png)
### Add Customer
![img_3.png](img_3.png)

## Author

Anjali Agarwal

Flutter Developer

Assignment Submission for GYBL Flutter & Firebase Developer Internship
