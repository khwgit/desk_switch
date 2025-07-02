#ifndef FLUTTER_PLUGIN_INPUT_CAPTURE_INJECTION_PLUGIN_H_
#define FLUTTER_PLUGIN_INPUT_CAPTURE_INJECTION_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace input_capture_injection {

class InputCaptureInjectionPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  InputCaptureInjectionPlugin();

  virtual ~InputCaptureInjectionPlugin();

  // Disallow copy and assign.
  InputCaptureInjectionPlugin(const InputCaptureInjectionPlugin&) = delete;
  InputCaptureInjectionPlugin& operator=(const InputCaptureInjectionPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace input_capture_injection

#endif  // FLUTTER_PLUGIN_INPUT_CAPTURE_INJECTION_PLUGIN_H_
