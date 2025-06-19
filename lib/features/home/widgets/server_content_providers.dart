import 'package:desk_switch/core/services/server_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:desk_switch/core/services/server_service.dart';

part 'server_content_providers.g.dart';

// Provider for whether the server is running
@riverpod
bool serverRunning(Ref ref) {
  final service = ref.watch(serverServiceProvider.notifier);
  return service.isRunning;
}
