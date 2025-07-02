#include "input_capture_injection_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>

#include <memory>
#include <sstream>
#include <thread>
#include <atomic>
#include <mutex>

namespace input_capture_injection
{

  namespace
  {
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> keyboard_sink;
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> mouse_sink;

    HHOOK keyboard_hook = nullptr;
    HHOOK mouse_hook = nullptr;
    std::thread hook_thread;
    std::atomic<bool> running{false};
    std::mutex hook_mutex;

    LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam)
    {
      if (nCode == HC_ACTION && keyboard_sink)
      {
        KBDLLHOOKSTRUCT *p = (KBDLLHOOKSTRUCT *)lParam;
        flutter::EncodableMap event;
        event[flutter::EncodableValue("code")] = flutter::EncodableValue((int)p->vkCode);
        event[flutter::EncodableValue("type")] = flutter::EncodableValue(
            wParam == WM_KEYDOWN ? "keyDown" : wParam == WM_KEYUP    ? "keyUp"
                                           : wParam == WM_SYSKEYDOWN ? "keyDown"
                                           : wParam == WM_SYSKEYUP   ? "keyUp"
                                                                     : "unknown");
        // Handle modifiers
        std::vector<flutter::EncodableValue> modifiers;
        if (GetAsyncKeyState(VK_SHIFT) & 0x8000)
          modifiers.emplace_back("shift");
        if (GetAsyncKeyState(VK_CONTROL) & 0x8000)
          modifiers.emplace_back("control");
        if (GetAsyncKeyState(VK_MENU) & 0x8000)
          modifiers.emplace_back("alt");
        if (GetAsyncKeyState(VK_LWIN) & 0x8000 || GetAsyncKeyState(VK_RWIN) & 0x8000)
          modifiers.emplace_back("win");
        event[flutter::EncodableValue("modifiers")] = flutter::EncodableValue(modifiers);
        event[flutter::EncodableValue("character")] = flutter::EncodableValue(); // Not available
        event[flutter::EncodableValue("timestamp")] = flutter::EncodableValue((int)p->time);
        keyboard_sink->Success(flutter::EncodableValue(event));
      }
      return CallNextHookEx(nullptr, nCode, wParam, lParam);
    }

    LRESULT CALLBACK MouseProc(int nCode, WPARAM wParam, LPARAM lParam)
    {
      if (nCode == HC_ACTION && mouse_sink)
      {
        MSLLHOOKSTRUCT *p = (MSLLHOOKSTRUCT *)lParam;
        flutter::EncodableMap event;
        event[flutter::EncodableValue("x")] = flutter::EncodableValue((double)p->pt.x);
        event[flutter::EncodableValue("y")] = flutter::EncodableValue((double)p->pt.y);
        event[flutter::EncodableValue("timestamp")] = flutter::EncodableValue((int)p->time);
        std::string type;
        std::string button = "left";
        int clickCount = 1;
        double deltaX = 0, deltaY = 0, deltaZ = 0;
        switch (wParam)
        {
        case WM_LBUTTONDOWN:
          type = "leftMouseDown";
          break;
        case WM_LBUTTONUP:
          type = "leftMouseUp";
          break;
        case WM_RBUTTONDOWN:
          type = "rightMouseDown";
          button = "right";
          break;
        case WM_RBUTTONUP:
          type = "rightMouseUp";
          button = "right";
          break;
        case WM_MOUSEMOVE:
          type = "mouseMoved";
          break;
        case WM_MOUSEWHEEL:
          type = "scrollWheel";
          deltaY = GET_WHEEL_DELTA_WPARAM(p->mouseData);
          break;
        case WM_MBUTTONDOWN:
          type = "otherMouseDown";
          button = "center";
          break;
        case WM_MBUTTONUP:
          type = "otherMouseUp";
          button = "center";
          break;
        case WM_MBUTTONDBLCLK:
          type = "otherMouseDown";
          button = "center";
          clickCount = 2;
          break;
        case WM_LBUTTONDBLCLK:
          type = "leftMouseDown";
          clickCount = 2;
          break;
        case WM_RBUTTONDBLCLK:
          type = "rightMouseDown";
          button = "right";
          clickCount = 2;
          break;
        default:
          type = "unknown";
          break;
        }
        event[flutter::EncodableValue("type")] = flutter::EncodableValue(type);
        event[flutter::EncodableValue("button")] = flutter::EncodableValue(button);
        event[flutter::EncodableValue("clickCount")] = flutter::EncodableValue(clickCount);
        event[flutter::EncodableValue("deltaX")] = flutter::EncodableValue(deltaX);
        event[flutter::EncodableValue("deltaY")] = flutter::EncodableValue(deltaY);
        event[flutter::EncodableValue("deltaZ")] = flutter::EncodableValue(deltaZ);
        mouse_sink->Success(flutter::EncodableValue(event));
      }
      return CallNextHookEx(nullptr, nCode, wParam, lParam);
    }

    void HookThreadProc()
    {
      keyboard_hook = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc, nullptr, 0);
      mouse_hook = SetWindowsHookEx(WH_MOUSE_LL, MouseProc, nullptr, 0);
      MSG msg;
      running = true;
      while (running && GetMessage(&msg, nullptr, 0, 0))
      {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
      }
      if (keyboard_hook)
        UnhookWindowsHookEx(keyboard_hook);
      if (mouse_hook)
        UnhookWindowsHookEx(mouse_hook);
    }

    void StartHooks()
    {
      std::lock_guard<std::mutex> lock(hook_mutex);
      if (!running)
      {
        running = true;
        hook_thread = std::thread(HookThreadProc);
      }
    }

    void StopHooks()
    {
      std::lock_guard<std::mutex> lock(hook_mutex);
      if (running)
      {
        running = false;
        PostThreadMessage(GetThreadId(hook_thread.native_handle()), WM_QUIT, 0, 0);
        if (hook_thread.joinable())
          hook_thread.join();
      }
    }

  } // namespace

  // static
  void InputCaptureInjectionPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "input_capture_injection",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<InputCaptureInjectionPlugin>();

    // Keyboard event channel
    auto keyboard_channel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
        registrar->messenger(), "input_capture_injection/keyboardInputs",
        &flutter::StandardMethodCodec::GetInstance());
    auto keyboard_handler = std::make_unique<flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
        [](const flutter::EncodableValue *arguments,
           std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events)
            -> std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
        {
          keyboard_sink = std::move(events);
          StartHooks();
          return nullptr;
        },
        [](const flutter::EncodableValue *arguments)
            -> std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
        {
          keyboard_sink.reset();
          StopHooks();
          return nullptr;
        });
    keyboard_channel->SetStreamHandler(std::move(keyboard_handler));

    // Mouse event channel
    auto mouse_channel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
        registrar->messenger(), "input_capture_injection/mouseInputs",
        &flutter::StandardMethodCodec::GetInstance());
    auto mouse_handler = std::make_unique<flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
        [](const flutter::EncodableValue *arguments,
           std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events)
            -> std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
        {
          mouse_sink = std::move(events);
          StartHooks();
          return nullptr;
        },
        [](const flutter::EncodableValue *arguments)
            -> std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
        {
          mouse_sink.reset();
          StopHooks();
          return nullptr;
        });
    mouse_channel->SetStreamHandler(std::move(mouse_handler));

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result)
        {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  InputCaptureInjectionPlugin::InputCaptureInjectionPlugin() {}

  InputCaptureInjectionPlugin::~InputCaptureInjectionPlugin()
  {
    StopHooks();
  }

  void InputCaptureInjectionPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (method_call.method_name().compare("getPlatformVersion") == 0)
    {
      std::ostringstream version_stream;
      version_stream << "Windows ";
      if (IsWindows10OrGreater())
      {
        version_stream << "10+";
      }
      else if (IsWindows8OrGreater())
      {
        version_stream << "8";
      }
      else if (IsWindows7OrGreater())
      {
        version_stream << "7";
      }
      result->Success(flutter::EncodableValue(version_stream.str()));
    }
    else if (method_call.method_name().compare("initialize") == 0)
    {
      result->Success();
    }
    else if (method_call.method_name().compare("requestInputCapture") == 0)
    {
      StartHooks();
      result->Success(true);
    }
    else if (method_call.method_name().compare("isInputCaptureRequested") == 0)
    {
      result->Success(true); // Always true for Windows
    }
    else if (method_call.method_name().compare("requestInputInjection") == 0)
    {
      result->Success(true); // Always true for Windows
    }
    else if (method_call.method_name().compare("isInputInjectionRequested") == 0)
    {
      result->Success(true); // Always true for Windows
    }
    else if (method_call.method_name().compare("injectMouseInput") == 0)
    {
      // Improved mouse injection logic
      if (method_call.arguments() && std::holds_alternative<flutter::EncodableMap>(*method_call.arguments()))
      {
        const auto &args = std::get<flutter::EncodableMap>(*method_call.arguments());
        double x = 0, y = 0;
        std::string type;
        if (args.count(flutter::EncodableValue("x")))
          x = std::get<double>(args.at(flutter::EncodableValue("x")));
        if (args.count(flutter::EncodableValue("y")))
          y = std::get<double>(args.at(flutter::EncodableValue("y")));
        if (args.count(flutter::EncodableValue("type")))
          type = std::get<std::string>(args.at(flutter::EncodableValue("type")));

        INPUT input = {0};
        input.type = INPUT_MOUSE;

        // Convert to absolute coordinates
        LONG absX = static_cast<LONG>(x * 65535.0 / (GetSystemMetrics(SM_CXSCREEN) - 1));
        LONG absY = static_cast<LONG>(y * 65535.0 / (GetSystemMetrics(SM_CYSCREEN) - 1));

        if (type == "leftMouseDown" || type == "leftMouseUp" ||
            type == "rightMouseDown" || type == "rightMouseUp" ||
            type == "mouseMoved")
        {
          input.mi.dx = absX;
          input.mi.dy = absY;
          input.mi.dwFlags = MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE;
          if (type == "leftMouseDown")
            input.mi.dwFlags |= MOUSEEVENTF_LEFTDOWN;
          if (type == "leftMouseUp")
            input.mi.dwFlags |= MOUSEEVENTF_LEFTUP;
          if (type == "rightMouseDown")
            input.mi.dwFlags |= MOUSEEVENTF_RIGHTDOWN;
          if (type == "rightMouseUp")
            input.mi.dwFlags |= MOUSEEVENTF_RIGHTUP;
          SendInput(1, &input, sizeof(INPUT));
        }
        else if (type == "scrollWheel")
        {
          input.mi.dwFlags = MOUSEEVENTF_WHEEL;
          if (args.count(flutter::EncodableValue("deltaY")))
            input.mi.mouseData = static_cast<DWORD>(std::get<double>(args.at(flutter::EncodableValue("deltaY"))));
          SendInput(1, &input, sizeof(INPUT));
        }
        // Add more cases as needed
        result->Success();
      }
      else
      {
        result->Error("INVALID_ARGUMENTS", "Invalid mouse event arguments");
      }
    }
    else if (method_call.method_name().compare("injectKeyboardInput") == 0)
    {
      // Parse arguments and call SendInput for keyboard
      if (method_call.arguments() && std::holds_alternative<flutter::EncodableMap>(*method_call.arguments()))
      {
        const auto &args = std::get<flutter::EncodableMap>(*method_call.arguments());
        int code = 0;
        std::string type;
        std::vector<std::string> modifiers;
        if (args.count(flutter::EncodableValue("code")))
          code = std::get<int>(args.at(flutter::EncodableValue("code")));
        if (args.count(flutter::EncodableValue("type")))
          type = std::get<std::string>(args.at(flutter::EncodableValue("type")));
        if (args.count(flutter::EncodableValue("modifiers")))
        {
          const auto &mods = std::get<std::vector<flutter::EncodableValue>>(args.at(flutter::EncodableValue("modifiers")));
          for (const auto &mod : mods)
          {
            if (std::holds_alternative<std::string>(mod))
              modifiers.push_back(std::get<std::string>(mod));
          }
        }
        // Press modifier keys down if needed
        std::vector<INPUT> inputs;
        auto add_modifier = [&](WORD vk)
        {
          INPUT mod_input = {0};
          mod_input.type = INPUT_KEYBOARD;
          mod_input.ki.wVk = vk;
          mod_input.ki.dwFlags = 0;
          inputs.push_back(mod_input);
        };
        for (const auto &mod : modifiers)
        {
          if (mod == "shift")
            add_modifier(VK_SHIFT);
          else if (mod == "control")
            add_modifier(VK_CONTROL);
          else if (mod == "alt")
            add_modifier(VK_MENU);
          else if (mod == "win")
            add_modifier(VK_LWIN); // Only left win for simplicity
        }
        // Main key event
        INPUT input = {0};
        input.type = INPUT_KEYBOARD;
        input.ki.wVk = static_cast<WORD>(code);
        if (type == "keyUp")
          input.ki.dwFlags = KEYEVENTF_KEYUP;
        inputs.push_back(input);
        // Release modifier keys if needed
        auto add_modifier_up = [&](WORD vk)
        {
          INPUT mod_input = {0};
          mod_input.type = INPUT_KEYBOARD;
          mod_input.ki.wVk = vk;
          mod_input.ki.dwFlags = KEYEVENTF_KEYUP;
          inputs.push_back(mod_input);
        };
        for (const auto &mod : modifiers)
        {
          if (mod == "shift")
            add_modifier_up(VK_SHIFT);
          else if (mod == "control")
            add_modifier_up(VK_CONTROL);
          else if (mod == "alt")
            add_modifier_up(VK_MENU);
          else if (mod == "win")
            add_modifier_up(VK_LWIN);
        }
        SendInput(static_cast<UINT>(inputs.size()), inputs.data(), sizeof(INPUT));
        result->Success();
      }
      else
      {
        result->Error("INVALID_ARGUMENTS", "Invalid keyboard event arguments");
      }
    }
    else
    {
      result->NotImplemented();
    }
  }

} // namespace input_capture_injection
