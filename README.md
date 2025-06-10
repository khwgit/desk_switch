# DeskSwitch

A cross-platform KVM (Keyboard, Video, Mouse) switch application built with Flutter that enables users to control multiple computers from a single set of peripherals. The application supports both client and server modes, with a focus on MacOS and Windows platforms initially.

## Features

### Client Mode
- Connect to KVM servers
- Manual IP input or auto-detection
- Connection status monitoring
- Configurable connection settings
- Keyboard and mouse control
- Display management

### Server Mode
- Host KVM server
- Profile management
- Network configuration
- Client management
- Connection monitoring
- Security settings

## Technical Stack

- **Framework**: Flutter
- **State Management**: 
  - Hooks Riverpod for global state management
  - Flutter Hooks for widget-level state management
- **Navigation**: Go Router
- **Platform Support**: 
  - Primary: MacOS, Windows
  - Future: Linux, BSD

## Getting Started

### Prerequisites

- Flutter SDK (>=3.32.0)
- Dart SDK (>=3.8.1)
- Platform-specific development tools:
  - MacOS: Xcode
  - Windows: Visual Studio with C++ development tools

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/khwgit/desk_switch.git
   cd kvm
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Development

### Building for Production

#### MacOS
```bash
flutter build macos
```

#### Windows
```bash
flutter build windows
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Riverpod team for the state management solution
- All contributors and users of the application
