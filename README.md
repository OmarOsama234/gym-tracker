# 🏋️‍♂️ Gym Tracker - Professional Flutter App

A professional, production-ready gym workout tracking application built with Flutter and modern architecture patterns.

## ✨ Features

### 🎯 Core Functionality
- **Add Workouts**: Track exercises with sets, reps, weight, and notes
- **Workout History**: View all past workouts with beautiful cards
- **Edit & Delete**: Modify or remove workouts with confirmation dialogs
- **Statistics Dashboard**: Progress tracking and workout analytics
- **Search & Filter**: Find workouts by exercise, category, or date range

### 🎨 Modern UI/UX
- **Material 3 Design**: Beautiful, consistent interface following Google's latest design system
- **Dark/Light Themes**: Toggle between professional light and dark modes
- **Loading States**: Visual feedback during all operations
- **Error Handling**: User-friendly error messages and recovery
- **Empty States**: Engaging designs when no data is available
- **Responsive Design**: Works perfectly on all screen sizes

### 🏗️ Professional Architecture
- **Clean Architecture**: Separation of concerns with core, models, services, and UI layers
- **Result Pattern**: Functional error handling for safe operations
- **State Management**: Provider pattern with ChangeNotifier
- **Custom Exceptions**: Structured error hierarchy
- **Comprehensive Validation**: Input validation with helpful messages
- **Local Database**: Hive for fast, offline-first data storage

## 📱 Screenshots

_Add your app screenshots here once you have them_

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (2.19 or higher)
- Android Studio / VS Code with Flutter extension

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/gym-tracker-flutter.git
   cd gym-tracker-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (if needed)**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (on macOS)
flutter build ios --release
```

## 🏗️ Architecture

```
lib/
├── core/                   # Foundation layer
│   ├── constants.dart      # App constants and configuration
│   ├── exceptions.dart     # Custom exception classes
│   ├── result.dart         # Result pattern for error handling
│   ├── validators.dart     # Input validation utilities
│   ├── utils.dart          # Common utility functions
│   ├── theme.dart          # Material 3 theme system
│   └── hive_setup.dart     # Database initialization
├── models/                 # Data models
│   ├── workout.dart        # Enhanced workout model
│   └── workout.g.dart      # Generated Hive adapter
├── services/               # Business logic layer
│   └── workout_service.dart # Workout operations service
├── widgets/                # Reusable UI components
│   ├── custom_text_field.dart
│   ├── loading_overlay.dart
│   └── workout_card.dart
├── screens/                # Application screens
│   ├── home_page.dart      # Add workout screen
│   └── history_page.dart   # Workout history screen
└── main.dart               # App entry point
```

## 📊 Key Technologies

- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **Hive**: Fast, lightweight NoSQL database
- **Provider**: State management solution
- **Material 3**: Google's latest design system

## 🎯 Professional Features

### Enhanced Data Model
- **Comprehensive Fields**: Exercise, sets, reps, weight, notes, duration, category
- **Data Validation**: Built-in validation with error messages
- **Utility Methods**: Volume calculation, formatting, search functionality
- **JSON Support**: Import/export capabilities

### Robust Service Layer
- **Result Pattern**: Safe error handling for all operations
- **Statistics**: Advanced analytics and progress tracking
- **Search & Filter**: Multiple ways to find workouts
- **Data Integrity**: Validation before database operations

### Professional UI Components
- **Custom Text Fields**: Consistent styling and validation
- **Workout Cards**: Beautiful display with statistics
- **Loading Overlays**: Professional loading states
- **Confirmation Dialogs**: Safety for destructive actions

## 🔧 Configuration

### Customizing the App

**Colors & Theme** (in `lib/core/theme.dart`):
```dart
static const Color primaryColor = Color(0xFF6366F1);
static const Color secondaryColor = Color(0xFF06B6D4);
```

**Validation Limits** (in `lib/core/constants.dart`):
```dart
static const int maxSets = 50;
static const int maxReps = 1000;
static const double maxWeight = 1000.0;
```

**App Information** (in `lib/core/constants.dart`):
```dart
static const String appName = 'Gym Tracker';
static const String appVersion = '1.0.0';
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## 📝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎉 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the beautiful design system
- Hive team for the fast local database
- Provider team for state management solution

## 📞 Support

If you have any questions or need help with the app:

- Open an issue on GitHub
- Check the [documentation](docs/)
- Review the comprehensive code comments

---

**Built with ❤️ using Flutter**

## 🔄 Version History

### v1.0.0 (Current)
- ✅ Professional architecture with clean separation of concerns
- ✅ Material 3 design system implementation
- ✅ Comprehensive error handling with Result pattern
- ✅ Enhanced workout model with notes and categories
- ✅ Statistics dashboard and progress tracking
- ✅ Search and filter functionality
- ✅ Dark/light theme support
- ✅ Input validation system
- ✅ Professional UI components
- ✅ Offline-first data storage with Hive

### Planned Features
- 🔄 Cloud synchronization
- 🔄 Workout plans and templates
- 🔄 Progress charts and analytics
- 🔄 Exercise library with instructions
- 🔄 Social features and sharing
- 🔄 Nutrition tracking integration
