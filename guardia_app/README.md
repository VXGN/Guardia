# Guardia - Personal Safety & Community Security

Guardia is a mobile application designed to enhance personal safety through real-time risk assessment, community-driven reports, and emergency assistance. It leverages advanced routing to suggest safe paths and provides a visual heatmap of security zones.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.19.0 or higher recommended)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Firebase account for authentication and backend services

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd guardia_app
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   - Create a new Project in [Firebase Console](https://console.firebase.google.com/).
   - Add Android/iOS applications to your project.
   - Download and place `google-services.json` (Android) in `android/app/` and `GoogleService-Info.plist` (iOS) in `ios/Runner/`.
   - Enable **Email/Password** and **Google** authentication in the Firebase Auth settings.

4. **Run the Application:**
   ```bash
   flutter run
   ```

## 🛠 Technologies Used

- **Core Framework**: [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (BLoC pattern)
- **Dependency Injection**: [get_it](https://pub.dev/packages/get_it)
- **Maps & Location**: 
  - [flutter_map](https://pub.dev/packages/flutter_map) (OpenStreetMap)
  - [geolocator](https://pub.dev/packages/geolocator)
  - [latlong2](https://pub.dev/packages/latlong2)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Authentication**: [firebase_auth](https://pub.dev/packages/firebase_auth)
- **Storage**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- **Routing**: [OSRM API](http://project-osrm.org/) (Fallback for safe route calculations)

## 📁 Project Structure

The project follows a **Feature-First Clean Architecture** pattern:

```text
lib/
├── core/           # Common utilities, constants, theme, and base network clients
├── di/             # Dependency Injection setup (injection_container.dart)
├── data/           # Global repositories and models (primarily Risk/Data)
├── domain/         # Global entities and repository interfaces
├── presentation/   # Shared widgets and global BLoC implementations
└── features/       # Feature-specific modules
    ├── auth/       # Authentication logic, pages, and BLoCs
    ├── companion/  # Trusted contacts and journey tracking
    ├── panic/      # SOS and Emergency Alert system
    ├── profile/    # User settings and profile management
    ├── reports/    # Community reporting and global feed
    ├── risk/       # Heatmap and security score analytics
    └── routing/    # Safe route calculation and navigation
```

## 🛤 Key Features

- **Safe Routing**: Calculates paths that avoid high-risk zones using OSRM with detour logic.
- **Security Heatmap**: Visualizes reported incidents as intensity circles on the map.
- **SOS Panic Button**: Quick emergency trigger that notifies trusted contacts and provides real-time location.
- **Community Feed**: Report and view security incidents in your area to maintain community awareness.
- **Secure Persistence**: Local caching of profile data for offline access and improved performance.

## 🏃 How to Run

1. Connect your device or start an emulator.
2. Execute `flutter run` in the terminal or use the Debug button in your IDE.
3. Ensure location permissions are granted for full map and routing functionality.

---
Developed with ❤️ for safe communities.
