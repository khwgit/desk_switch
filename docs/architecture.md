# DeskSwitch Architecture

## Overview
This document defines the architecture, coding standards, and structural rules for the KVM Switch application. Following these guidelines ensures consistency, maintainability, and scalability of the codebase.

## Project Structure

```
lib/
├── core/                      # Core functionality and utilities
│   ├── constants/            # Application-wide constants
│   ├── errors/              # Custom error types and handlers
│   ├── network/             # Network-related utilities
│   └── utils/               # General utility functions
│
├── features/                 # Feature-based modules
│   ├── example_feature/     # Example feature (template for all features)
│   │   ├── data/           # Data layer
│   │   │   ├── datasources/    # Data sources (remote/local)
│   │   │   │   ├── remote/     # Remote data sources (API, WebSocket, etc.)
│   │   │   │   └── local/      # Local data sources (SharedPreferences, SQLite, etc.)
│   │   │   ├── models/         # Data models (DTOs)
│   │   │   │   ├── example_model.dart
│   │   │   │   └── example_model_mapper.dart
│   │   │   └── repositories/   # Repository implementations
│   │   │       └── example_repository_impl.dart
│   │   │
│   │   ├── domain/         # Domain layer
│   │   │   ├── entities/       # Business objects
│   │   │   │   └── example_entity.dart
│   │   │   ├── repositories/   # Repository interfaces
│   │   │   │   └── example_repository.dart
│   │   │   └── usecases/       # Business logic
│   │   │       ├── get_example.dart
│   │   │       └── update_example.dart
│   │   │
│   │   └── presentation/   # Presentation layer
│   │       ├── screens/        # Screen widgets
│   │       │   └── example_screen.dart
│   │       ├── widgets/        # Feature-specific widgets
│   │       │   ├── example_list_widget.dart
│   │       │   └── example_form_widget.dart
│   │       └── providers/      # Feature-specific providers
│   │           ├── example_provider.dart
│   │           └── example_state.dart
│   │
│   └── [other_features]/   # Other features follow the same structure
│
└── shared/                  # Shared resources
    ├── models/             # Shared data models
    ├── providers/          # Global providers
    ├── router/             # Navigation configuration
    ├── theme/              # App theme and styling
    └── widgets/            # Shared widgets
```

### Feature Module Template
Each feature should follow the structure of the example feature above. This ensures consistency across the application and makes it easier to:
- Understand the codebase
- Add new features
- Maintain existing features
- Test components
- Share code between features

The example feature demonstrates:
1. **Clear Separation of Concerns**
   - Data layer for external communication
   - Domain layer for business logic
   - Presentation layer for UI

2. **Proper File Organization**
   - Each file has a single responsibility
   - Related files are grouped together
   - Clear naming conventions

3. **State Management**
   - Feature-specific providers
   - Clear state definitions
   - Proper dependency injection

4. **Testing Structure**
   - Each layer can be tested independently
   - Clear boundaries for unit tests
   - Easy to mock dependencies

## Architectural Principles

### 1. Clean Architecture
- **Separation of Concerns**: Each layer has a specific responsibility
- **Dependency Rule**: Dependencies point inward (presentation → domain ← data)
- **Independence**: Domain layer is independent of frameworks and external concerns

### 2. Feature-First Organization
- Features are self-contained modules
- Each feature follows the same internal structure
- Features can be developed and tested independently

### 3. State Management
- **Global State**: Use Riverpod for application-wide state
- **Local State**: Use Flutter Hooks for widget-level state
- **State Providers**: Follow naming convention: `*Provider`, `*Notifier`, `*State`

### 4. Navigation
- Use GoRouter for navigation
- Define routes in `shared/router/app_router.dart`
- Keep route names consistent with feature names

## Coding Standards

### 1. File Naming
- Use snake_case for file names
- Suffix files with their type:
  - `*_screen.dart` for screen widgets
  - `*_widget.dart` for reusable widgets
  - `*_provider.dart` for providers
  - `*_model.dart` for data models
  - `*_repository.dart` for repositories

### 2. Class Naming
- Use PascalCase for class names
- Suffix classes with their type:
  - `*Screen` for screen widgets
  - `*Widget` for reusable widgets
  - `*Provider` for providers
  - `*Model` for data models
  - `*Repository` for repositories
  - `*UseCase` for use cases
  - `*Entity` for domain entities

### 3. Widget Structure
```dart
class FeatureScreen extends HookConsumerWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. State declarations (hooks)
    // 2. Provider watches
    // 3. Computed values
    // 4. Event handlers
    // 5. UI build
  }
}
```

### 4. Provider Structure
```dart
// State definition
final featureStateProvider = StateProvider<FeatureState>((ref) => FeatureState.initial());

// Notifier definition
final featureNotifierProvider = StateNotifierProvider<FeatureNotifier, FeatureState>((ref) {
  return FeatureNotifier(ref);
});

// Repository definition
final featureRepositoryProvider = Provider<FeatureRepository>((ref) {
  return FeatureRepositoryImpl(ref);
});
```

### 5. Error Handling
- Use custom error types in `core/errors/`
- Handle errors at appropriate levels
- Provide user-friendly error messages
- Log errors for debugging

### 6. Testing
- Unit tests for domain and data layers
- Widget tests for presentation layer
- Integration tests for features
- Test file naming: `*_test.dart`

## Feature Module Structure

### 1. Data Layer
- **Models**: Data transfer objects (DTOs)
- **DataSources**: Remote and local data sources
- **Repositories**: Implementation of repository interfaces

### 2. Domain Layer
- **Entities**: Business objects
- **Repositories**: Repository interfaces
- **UseCases**: Business logic implementation

### 3. Presentation Layer
- **Screens**: Main screen widgets
- **Widgets**: Reusable UI components
- **Providers**: Feature-specific state management

## State Management Rules

### 1. Provider Usage
- Use `StateProvider` for simple state
- Use `StateNotifierProvider` for complex state
- Use `Provider` for dependencies
- Use `FutureProvider` for async data
- Use `StreamProvider` for streams

### 2. State Organization
- Keep state close to where it's used
- Use feature-specific providers
- Share state through global providers when necessary

## UI/UX Guidelines

### 1. Screen Layout
- Use `Scaffold` as the base widget
- Implement responsive layouts
- Follow Material Design guidelines
- Support both light and dark themes

### 2. Widget Organization
- Break down complex widgets into smaller components
- Use composition over inheritance
- Keep widgets focused and reusable
- Document widget parameters

### 3. Theme Usage
- Use theme colors and styles consistently
- Define custom themes in `shared/theme/`
- Support platform-specific styling

## Platform-Specific Code

### 1. Platform Detection
- Use `AppConstants` for platform checks
- Implement platform-specific code in separate files
- Use conditional imports when necessary

### 2. Platform Features
- Handle platform permissions properly
- Implement platform-specific UI adjustments
- Use platform channels for native functionality

## Documentation

### 1. Code Documentation
- Document public APIs
- Use meaningful variable and function names
- Add comments for complex logic
- Keep documentation up to date

### 2. Architecture Documentation
- Update this document when architecture changes
- Document design decisions
- Keep README.md up to date

## Version Control

### 1. Branching Strategy
- `main`: Production-ready code
- `develop`: Development branch
- `feature/*`: Feature branches
- `bugfix/*`: Bug fix branches

### 2. Commit Messages
- Use conventional commits
- Reference issues in commit messages
- Keep commits focused and atomic

## Dependencies

### 1. Package Management
- Keep dependencies up to date
- Document dependency purposes
- Use specific version constraints
- Regular security audits

### 2. Core Dependencies
- `hooks_riverpod`: State management
- `flutter_hooks`: Widget-level state
- `go_router`: Navigation
- `window_manager`: Desktop window management
- Platform-specific packages as needed

## Performance Guidelines

### 1. Code Optimization
- Minimize widget rebuilds
- Use const constructors
- Implement proper caching
- Optimize asset loading

### 2. Memory Management
- Dispose resources properly
- Handle large data sets efficiently
- Implement proper cleanup in widgets

## Security Guidelines

### 1. Data Security
- Secure storage of sensitive data
- Proper handling of credentials
- Network security best practices
- Input validation

### 2. Platform Security
- Follow platform security guidelines
- Implement proper permissions handling
- Secure platform-specific features

## Future Considerations

### 1. Scalability
- Design for feature additions
- Plan for increased complexity
- Consider performance at scale

### 2. Maintenance
- Regular code reviews
- Technical debt management
- Documentation updates
- Dependency updates

## Conclusion
This architecture document serves as a guide for maintaining consistency and quality in the KVM Switch application. All team members should follow these guidelines to ensure the project remains maintainable and scalable. 