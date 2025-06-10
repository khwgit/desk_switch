# Coding Standards

1. Freezed Classes with Factory Constructors
   ```dart
   @freezed
   sealed class MyClass with _$MyClass {  // ✅ Correct
     const factory MyClass() = _MyClass;
     factory MyClass.fromJson() => _$MyClassFromJson();
   }

   @freezed
   class MyClass with _$MyClass {  // ❌ Wrong
     const factory MyClass() = _MyClass;
   }
   ```
   Current sealed classes:
   - `Connection` (`models/connection.dart`)
   - `Profile` (`models/profile.dart`)
   - `AppState` (`providers/app_state.dart`)
   - `NetworkConfig` (`models/network_config.dart`)
   - `AppError` (`errors/app_error.dart`)
   Checklist:
   - Add `sealed` if using factory constructors
   - Update this list
