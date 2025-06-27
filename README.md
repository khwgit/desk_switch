# DeskSwitch

> **⚠️ Work in Progress**  
> This project is actively under development. Features are being implemented and the application is not yet ready for production use. Please expect breaking changes and incomplete functionality.

A cross-platform KVM (Keyboard, Video, Mouse) switch application built with Flutter that enables users to control multiple computers from a single set of peripherals. The application supports both client and server modes, with a focus on MacOS and Windows platforms initially.

## 🚧 Development Status

This project is currently in **active development**. Here's what's currently implemented and what's planned:

### ✅ Currently Implemented
- Basic Flutter application structure
- Service discovery using Bonsoir (mDNS)
- WebSocket-based client-server communication
- Basic UI for server discovery and connection
- Cross-platform support for macOS and Windows

### 🔄 In Progress
- Threading fixes for platform channel communication
- Connection management and error handling
- UI/UX improvements

### 📋 Planned Features

#### Client Mode
- Connect to KVM servers
- Manual IP input or auto-detection
- Connection status monitoring
- Configurable connection settings
- Keyboard and mouse control
- Display management

#### Server Mode
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
- **Network Discovery**: Bonsoir (mDNS)
- **Communication**: WebSocket
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
   cd desk_switch
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

### Current Development Focus

The development team is currently focused on:
- Fixing platform-specific threading issues
- Improving network discovery reliability
- Enhancing the user interface
- Implementing core KVM functionality

### Building for Production

> **Note**: The application is not yet ready for production use.

#### MacOS
```bash
flutter build macos
```

#### Windows
```bash
flutter build windows
```

## Contributing

We welcome contributions! Since this is an active development project, please:

1. Check the current development status and planned features
2. Fork the repository
3. Create your feature branch (`git checkout -b feature/amazing-feature`)
4. Commit your changes (`git commit -m 'Add some amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### Development Guidelines

- Follow the existing code style and architecture
- Add tests for new functionality
- Update documentation as needed
- Be aware that breaking changes may occur during active development

## Known Issues

- Platform channel threading issues on Windows (being addressed)
- Network discovery may have intermittent issues
- UI is still being refined

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Riverpod team for the state management solution
- Bonsoir team for the mDNS implementation
- All contributors and users of the application
