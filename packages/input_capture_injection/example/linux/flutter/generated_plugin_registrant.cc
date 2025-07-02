//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <input_capture_injection/input_capture_injection_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) input_capture_injection_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "InputCaptureInjectionPlugin");
  input_capture_injection_plugin_register_with_registrar(input_capture_injection_registrar);
}
