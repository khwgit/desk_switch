# DeskSwitch Test Server

This is a test server for the DeskSwitch application that sends signals to be discovered by clients. The server actively broadcasts/multicasts its presence so the main application can discover it in client mode.

## Architecture

- **Server-Initiated Discovery**: Servers send signals, clients listen for them
- **Signal-Based**: Uses structured JSON messages for server discovery
- **Multiple Protocols**: Supports both broadcast and multicast for different network scenarios
- **Cross-Platform**: Works on macOS, Windows, and Linux

## Features

- **Active Signal Broadcasting**: Servers continuously send presence signals every 2 seconds
- **Cross-Router Support**: Multiple signal methods for different network scenarios
- **JSON Format**: Uses structured JSON messages for better data handling
- **Reusable Service**: Clean `ServerSignalService` for easy server implementation

## Server Options

### 1. Simple Server (Fallback)
```bash
dart run bin/simple_server.dart
```
- Uses basic UDP broadcast signals only
- No multicast - avoids multicast issues
- Works within the same subnet
- Good fallback when multicast fails

### 2. Enhanced Broadcast Server
```bash
dart run bin/test_server.dart
```
- Uses UDP broadcast signals to all network interfaces
- Smart broadcast address calculation
- Works within the same subnet
- May not work across routers (router-dependent)

### 3. Multicast Server (Recommended for Cross-Router)
```bash
dart run bin/multicast_server.dart
```
- Uses UDP multicast signals (239.255.255.250)
- Better cross-router compatibility
- More reliable in complex network setups
- Graceful fallback if multicast fails

## Usage

### Running the Test Server

```bash
# Simple server (fallback)
dart run bin/simple_server.dart

# Enhanced broadcast server (same subnet)
dart run bin/test_server.dart

# Multicast server (cross-router)
dart run bin/multicast_server.dart

# Or compile to executable first
dart compile exe bin/simple_server.dart -o simple_server
dart compile exe bin/test_server.dart -o test_server
dart compile exe bin/multicast_server.dart -o multicast_server
./simple_server
./test_server
./multicast_server
```

### Testing with Test Client

```bash
# Test broadcast servers
dart run bin/test_client.dart

# Test multicast server
dart run bin/multicast_client.dart
```

### Testing with Main Application

1. Start the test server (choose based on your network):
   ```bash
   # For fallback (if multicast fails)
   dart run bin/simple_server.dart
   
   # For same subnet
   dart run bin/test_server.dart
   
   # For cross-router
   dart run bin/multicast_server.dart
   ```

2. Run the main DeskSwitch application in client mode
3. The application should automatically discover the test server

## Signal Formats

### Server Broadcast Signal
```json
{
  "type": "DESK_SWITCH_SERVER_BROADCAST",
  "server": {
    "id": "uuid",
    "name": "Test Server",
    "ipAddress": "127.0.0.1",
    "port": 8080,
    "isOnline": true,
    "lastSeen": "2024-01-01T12:00:00.000Z",
    "metadata": {}
  },
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

### Server Multicast Signal
```json
{
  "type": "DESK_SWITCH_SERVER_MULTICAST",
  "server": {
    "id": "uuid",
    "name": "Test Server (Multicast)",
    "ipAddress": "127.0.0.1",
    "port": 8080,
    "isOnline": true,
    "lastSeen": "2024-01-01T12:00:00.000Z",
    "metadata": {}
  },
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## Configuration

The server uses the same constants as the main application:
- **Port**: 8080 (configurable in `app_constants.dart`)
- **Signal Interval**: 2 seconds
- **Multicast Group**: 239.255.255.250 (more reliable than 224.0.0.1)
- **Server Name**: "Test Server" (configurable in code)

## Cross-Router Solutions

### Why Broadcast Doesn't Work Across Routers

UDP broadcasts are typically blocked by routers because:
1. Routers don't forward broadcast traffic by default
2. Broadcasts are limited to the local subnet
3. Security policies often block broadcast traffic

### Solutions

1. **Multicast (Recommended)**: Uses multicast group 239.255.255.250 which is more likely to be forwarded by routers
2. **Simple Broadcast (Fallback)**: Basic broadcast when multicast fails
3. **Manual IP Configuration**: Configure the client with the server's IP address
4. **Port Forwarding**: Forward UDP port 8080 on the router
5. **VPN**: Use a VPN to create a virtual local network

### Testing Cross-Router Discovery

1. **Same Network**: Use simple or enhanced broadcast server
2. **Different Networks**: Use multicast server
3. **Multicast Fails**: Use simple server as fallback
4. **Still Not Working**: Try manual IP configuration or port forwarding

## Troubleshooting

### Multicast Issues
If you get "unreachable host" errors with multicast:
1. **Use Simple Server**: `dart run bin/simple_server.dart`
2. **Check Network**: Some networks block multicast traffic
3. **Router Settings**: Enable multicast forwarding on router
4. **Firewall**: Allow UDP port 8080

### General Issues
1. **Firewall Issues**: Make sure port 8080 is not blocked by firewall
2. **Network Interface**: The server broadcasts on all available network interfaces
3. **Multiple Instances**: Only one test server should run at a time to avoid conflicts
4. **Cross-Router**: Use multicast server instead of broadcast server
5. **Router Configuration**: Some routers may block multicast traffic - check router settings

## Development

### ServerSignalService
The `ServerSignalService` class provides a clean interface for sending server signals:

```dart
final signalService = createServerSignalService(
  name: 'My Server',
  useMulticast: true,
  useBroadcast: true,
);

await signalService.start();
// Server will automatically send signals every 2 seconds
```

### Customization
To modify the server behavior:
- Edit `bin/server_signal_service.dart` for the core signal service
- Edit `bin/simple_server.dart` for basic broadcast server
- Edit `bin/test_server.dart` for enhanced broadcast server
- Edit `bin/multicast_server.dart` for multicast server
- Edit `bin/app_constants.dart` for configuration
- Edit `bin/server_info.dart` for server information model 