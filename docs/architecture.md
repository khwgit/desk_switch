# DeskSwitch Architecture

## Overview
This document defines the architecture, coding standards, and structural rules for the DeskSwitch application. Following these guidelines ensures consistency, maintainability, and scalability of the codebase.

## Project Structure

```
lib/
├── core/                       # Core functionality and constants
│   └── constants/              # Application-wide constants
│   ├── errors/                 # Custom error types and handlers
│   └── utils/                  # General utility functions
├── features/                   # Feature modules
│   ├── app/                    # Application-wide features
│   │   ├── providers/          # App-level providers (app state, etc.)
│   │   ├── screens/            # App-level screens (scaffold, etc.)
│   │   └── widgets/            # App-level widgets (navigation, status bar)
│   └── exmaple_feature/        # Example feature (template for all features)
│       ├── models/             # Feature-specific models
│       ├── providers/          # Feature-specific providers
│       ├── screens/            # Feature screens
│       ├── themes/             # Feature-specific themes
│       └── widgets/            # Feature widgets
├── l10n/                       # Localization
├── modules/                    # Reusable modules
│   └── go_router_maker/        # GoRouter code generation
├── models/                     # Shared models
├── router/                     # Navigation configuration
│   ├── app_router.dart         # Main router configuration
│   ├── routes.dart             # Route tree and path configuration
│   └── transitions.dart        # Custom page transitions
├── theme/                      # App theme and styling
│   ├── app_theme.dart          # Theme data and configuration
│   ├── color_schemes.dart      # Color palette definitions
│   └── text_themes.dart        # Typography styles
├── services/                   # Shared services
├── widgets/                    # Shared widgets
└── main.dart                   # Application entry point
```

## Architecture Overview

### Core Principles
- Feature-first architecture
- Clear separation of concerns
- Dependency injection using Riverpod
- Code generation for boilerplate reduction

### Feature Modules
Each feature module is self-contained and follows a consistent structure:
- `models/`: Data models specific to the feature
- `providers/`: State management using Riverpod
- `screens/`: Full screens/pages
- `widgets/`: Reusable UI components

### Shared Resources
The `shared/` directory contains resources used across multiple features:
- `models/`: Shared data models
- `providers/`: Global state management
- `router/`: Navigation configuration and route definitions
- `theme/`: Application theming and styling
  - `app_theme.dart`: Theme data and configuration
  - `color_schemes.dart`: Color palette definitions
  - `text_themes.dart`: Typography styles
  - `component_themes.dart`: Widget-specific themes
- `services/`: Common services (network, storage, etc.)

### Core Module
The `core/` directory contains application-wide constants and utilities:
- `constants/`: Application-wide constants and configurations

### Modules
The `modules/` directory contains reusable code that can be used across features:
- `go_router_maker/`: Custom code generation for GoRouter

## State Management

### Global State
- Uses Riverpod for state management
- Global state providers in `shared/providers/`
- Feature-specific state in feature's `providers/` directory

### State Organization
1. **App State** (`shared/providers/app_state_provider.dart`)
   - Application-wide state
   - Connection status
   - Mode selection

2. **Feature State** (e.g., `features/home/providers/`)
   - Feature-specific state
   - Server discovery
   - Connection management

## Navigation

### Router Configuration
- Uses GoRouter for navigation with a custom `go_router_maker` package
- Routes defined in `shared/router/routes.dart`
- Provides type-safe route construction and navigation
- Enables static syntax checking for available routes

### Route Structure
Routes are defined using a declarative approach in `AppRoute` class:
```dart
class AppRoute {
  List<RouteBase> get routes => [
    $app.$route(
      branches: [
        StatefulShellBranch(
          routes: [
            home.$route(
              path: '/',
              location: (data) => '/',
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            settings.$route(
              path: '/settings',
              location: (data) => '/settings',
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            user.$route(
              path: '/user/:userId',
              location: (data) => GoRouteData.$location(
                '/user/${data.id}',
              ),
            ),
          ],
        ),
      ],
    ),
  ];

  final $app = StatefulShellRouteMaker.indexedStack(
    builder: (context, state, data, shell) => AppScaffold(
      shell: shell,
    ),
  );

  final home = RouteMaker(
    builder: (context, state, data) => const HomeScreen(),
  );

  final settings = RouteMaker(
    builder: (context, state, data) => const SettingsScreen(),
  );

  final user = DataRouteMaker(
    data: (state) => UserRoute(state.pathParameters['userId']),
    builder: (context, state, data) => UserScreen(data.id),
  );
}
```

### Route Navigation
Routes are accessed through a provider and used for navigation:

1. **Access Routes**
```dart
final appRoute = ref.watch(appRouteProvider);
```

2. **Navigate to Routes**
```dart
// Navigate to settings
appRoute.settings().go(context);

// Navigate to home
appRoute.home().go(context);
```

### Route Parameters and Data Passing
Routes can be defined to accept parameters and pass data:

1. **Define a Route with Parameters**
```dart
// Define the route data class
class UserRoute extends GoRouteData {
  UserRoute(this.id);
  final String? id;
}

// Define the route in AppRoute
class AppRoute {
  List<RouteBase> get routes => [
    $app.$route(
      branches: [
        // ... other branches ...
        StatefulShellBranch(
          routes: [
            user.$route(
              path: '/user/:userId',
              location: (data) => GoRouteData.$location(
                '/user/${data.id}',
              ),
            ),
          ],
        ),
      ],
    ),
  ];

  // ... other routes ...

  final user = DataRouteMaker(
    data: (state) => UserRoute(state.pathParameters['userId']),
    builder: (context, state, data) => UserScreen(data.id),
  );
}
```

2. **Navigate with Parameters**
```dart
// Navigate to user route with parameter
appRoute.user(UserRoute('123')).go(context);

// The URL will be: /user/123
```

3. **Access Parameters in Screen**
```dart
class UserScreen extends StatelessWidget {
  const UserScreen(this.id);
  final String? id;
  
  @override
  Widget build(BuildContext context) {
    return Text('User ID: $id');
  }
}
```

The key points to remember when defining a route with parameters:
1. Define a `GoRouteData` class to hold the route parameters
2. Add the route to the route tree using `$route` with the appropriate path pattern
3. Define the route using `DataRouteMaker` to handle parameter parsing
4. Use the route data class when navigating

### Benefits of go_router_maker
- **Type Safety**: Routes are defined as class members, enabling static type checking
- **Code Organization**: Route definitions are centralized and structured
- **IDE Support**: Better autocomplete and navigation support
- **Maintainability**: Easier to manage and modify route structure
- **Consistency**: Enforces consistent route naming and structure

## Localization

- Uses Flutter's built-in localization
- Translation files in `l10n/`
- Generated code for type-safe access

## Dependencies

### State Management
- `hooks_riverpod`: State management
- `flutter_hooks`: Widget-level state management

### Navigation
- `go_router`: Routing
- Custom code generation for type safety

### Code Generation
- `freezed`: Immutable models
- `json_serializable`: JSON serialization
- `build_runner`: Code generation

### UI
- `gap`: Spacing utilities
- `window_manager`: Desktop window management

## Development Guidelines

### Code Organization
1. Keep feature-specific code within the feature module
2. Use shared resources for common functionality
3. Follow consistent naming conventions
4. Document public APIs

### State Management
1. Use appropriate provider types:
   - `Provider` for dependencies
   - `StateProvider` for simple state
   - `StateNotifierProvider` for complex state
   - `StreamProvider` for streams
2. Keep state as local as possible
3. Use auto-dispose when appropriate

### Widget Structure
1. Separate business logic from UI
2. Use composition over inheritance
3. Keep widgets focused and reusable
4. Use appropriate widget types:
   - `StatelessWidget` for static UI
   - `HookConsumerWidget` for stateful UI with Riverpod
   - `HookWidget` for stateful UI without Riverpod

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
This architecture document serves as a guide for maintaining consistency and quality in the DeskSwitch application. All team members should follow these guidelines to ensure the project remains maintainable and scalable. 