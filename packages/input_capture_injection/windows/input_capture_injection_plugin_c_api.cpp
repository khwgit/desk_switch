#include "include/input_capture_injection/input_capture_injection_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "input_capture_injection_plugin.h"

void InputCaptureInjectionPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  input_capture_injection::InputCaptureInjectionPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
