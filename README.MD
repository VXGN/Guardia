# Guardia: Community Safety Edge
*A smart, inclusive safety and incident reporting platform.*

---

**PROXO 2026 International Competition Submission**
**Category:** Mobile App Development
**Subtheme:** Smart, Inclusive, and Sustainable Cities

Guardia is a Flutter-based mobile application designed to improve community safety through real-time incident reporting, interactive risk-aware mapping, and emergency SOS features. This repository contains the complete mobile client source code.

## 🛠️ Tools & Technologies

This project is built from the ground up prioritizing type safety, modularity, and smooth cross-platform performance.

- **Frontend Framework:** Flutter (Dart)
- **State Management:** BLoC / Cubit (`flutter_bloc`, `equatable`)
- **Architecture:** Clean Architecture (Domain-Driven Design)
- **Navigation:** `go_router` for declarative, URL-based routing
- **Dependency Injection:** `get_it` for service locating and decoupling
- **Maps & Location:** `flutter_map` (OpenStreetMap integration), `geolocator`, `geocoding`, `latlong2`
- **Networking:** `dio` for structured API requests and interceptors
- **Local Storage:** `flutter_secure_storage` (for auth tokens) and `shared_preferences`
- **Backend Infrastructure:** Firebase Core & Auth (ready for backend integration)

## 📂 Project Structure

We follow a strict Clean Architecture approach. By dividing the app into distinct layers, we ensure that our business rules are isolated from UI configurations and data fetching mechanics, making the codebase highly testable, scalable, and easy to navigate for new developers.

All active application code is located inside the `guardia_app/lib/` directory:

```text
lib/
├── core/              # Global constants, theme definitions, routing, and shared utilities
├── data/              # Concrete implementations of data sources
│   ├── datasources/   # Remote (API) and Local (cache/DB) logic handles
│   ├── models/        # Data models mapping directly to JSON or DB structures
│   └── repositories_impl/ # Concrete implementation of domain interfaces
├── di/                # Service locator registration (Dependency Injection via get_it)
├── domain/            # Pure business logic (No Flutter UI dependencies here)
│   ├── entities/      # Core business objects (e.g., User, IncidentReport)
│   ├── repositories/  # Abstract interfaces defining data contracts
│   └── usecases/      # Actionable business rules (e.g., SubmitReport, GetContacts)
├── presentation/      # UI and State controllers
│   ├── bloc/          # State managers grouped by feature (Auth, Home, Panic, Map)
│   ├── pages/         # Screen layouts (Home, Login, Map, Routing, etc.)
│   └── widgets/       # Reusable, customized UI components
└── main.dart          # Application entry point and initialization
```

## ⚙️ Installation & Setup

Follow these steps to set up the development environment on your local machine.

### Prerequisites
1. **Flutter SDK** (v3.10.x or higher is recommended)
2. **Dart SDK**
3. An IDE like Android Studio, IntelliJ, or VS Code with Flutter plugins installed.
4. An active Android Emulator, iOS Simulator, or connected physical testing device.

### 1. Clone the Repository
Open your terminal and clone the project:
```bash
git clone https://github.com/VXGN/Guardia.git
cd Guardia/guardia_app
```

### 2. Install Dependencies
Run the following command to fetch all required Dart packages and resolve any library setups:
```bash
flutter pub get
```

*Note: If you plan to test full Firebase backend synchronization, you must place your own `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS) into their respective platform directories before compiling.*

## 🚀 How to Run the Application

Once your dependencies are installed and your environment is configured, you can launch Guardia.

### Running in Development Mode
Make sure your emulator is running or your Android/iOS device is connected. 

```bash
# Verify that your device is detected by Flutter
flutter devices

# Compile and run the application
flutter run
```

### Running on a Web Browser (Testing Mode)
If you want to quickly test UI logic without spinning up a heavy mobile emulator, Guardia supports Flutter Web compilation:
```bash
flutter run -d web-server --web-port 8080
```
Simply open your web browser and navigate to `http://localhost:8080`.

### Building for Production (APK)
To generate a release-ready APK for Android deployment or for competition submission:

```bash
flutter build apk --release
```
The compiled APK will be output to the following path: 
`build/app/outputs/flutter-apk/app-release.apk`
