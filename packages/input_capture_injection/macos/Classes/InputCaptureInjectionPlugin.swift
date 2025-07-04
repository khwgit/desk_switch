import Cocoa
import FlutterMacOS
import CoreGraphics
import ApplicationServices

enum InputType: String, CaseIterable {
  case keyboard = "keyboard"
  case mouse = "mouse"
}

public class InputCaptureInjectionPlugin: NSObject, FlutterPlugin {
  private var eventTap: CFMachPort?
  private var runLoopSource: CFRunLoopSource?
  private var blockedInputTypes: Set<InputType> = []
  private var inputSink: FlutterEventSink?
  private var originalCursor: NSCursor?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "input_capture_injection", binaryMessenger: registrar.messenger)
    let instance = InputCaptureInjectionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let inputEventChannel = FlutterEventChannel(name: "input_capture_injection/inputs", binaryMessenger: registrar.messenger)
    inputEventChannel.setStreamHandler(InputStreamHandler(
      onListen: { [weak instance] arguments, events in
        instance?.inputSink = events
        instance?.startEventTap()
        return nil
      },
      onCancel: { [weak instance] arguments in
        instance?.inputSink = nil
        instance?.stopEventTap()
        return nil
      }
    ))
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestPermission":
      requestPermission(call: call, result: result)
    case "isPermissionGranted":
      isPermissionGranted(call: call, result: result)
    case "injectMouseInput":
      injectMouseInput(call: call, result: result)
    case "injectKeyboardInput":
      injectKeyboardInput(call: call, result: result)
    case "setInputBlocked":
      setInputBlocked(call: call, result: result)
    case "getBlockedInputs":
      getBlockedInputs(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestPermission(call: FlutterMethodCall, result: @escaping FlutterResult) {
    // let args = call.arguments as? [String: Any]
    // let typesList = args?["types"] as? [String]
    
    if !AXIsProcessTrusted() {
      // Open System Preferences to Accessibility
      let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
      NSWorkspace.shared.open(url)
      result(false)
    } else {
      result(true)
    }
  }

  private func isPermissionGranted(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    let typesList = args?["types"] as? [String]
    
    // For macOS, all permissions (capture and injection) are the same - they require Accessibility permission
    let hasPermission = AXIsProcessTrusted()
    
    if typesList == nil {
      // When types is null, return false if any permission is not granted
      result(hasPermission)
    } else {
      // For specific types, return the same permission status
      result(hasPermission)
    }
  }

  private func startEventTap() {
    guard eventTap == nil else { return }
    
    // Only start if we have permission
    guard AXIsProcessTrusted() else { return }
    
    // Break up the complex event mask expression
    let keyDownMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
    let keyUpMask = CGEventMask(1 << CGEventType.keyUp.rawValue)
    let flagsChangedMask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
    let leftMouseDownMask = CGEventMask(1 << CGEventType.leftMouseDown.rawValue)
    let leftMouseUpMask = CGEventMask(1 << CGEventType.leftMouseUp.rawValue)
    let rightMouseDownMask = CGEventMask(1 << CGEventType.rightMouseDown.rawValue)
    let rightMouseUpMask = CGEventMask(1 << CGEventType.rightMouseUp.rawValue)
    let mouseMovedMask = CGEventMask(1 << CGEventType.mouseMoved.rawValue)
    let leftMouseDraggedMask = CGEventMask(1 << CGEventType.leftMouseDragged.rawValue)
    let rightMouseDraggedMask = CGEventMask(1 << CGEventType.rightMouseDragged.rawValue)
    let scrollWheelMask = CGEventMask(1 << CGEventType.scrollWheel.rawValue)
    let otherMouseDownMask = CGEventMask(1 << CGEventType.otherMouseDown.rawValue)
    let otherMouseUpMask = CGEventMask(1 << CGEventType.otherMouseUp.rawValue)
    let otherMouseDraggedMask = CGEventMask(1 << CGEventType.otherMouseDragged.rawValue)
    
    let eventMask = keyDownMask | keyUpMask | flagsChangedMask | leftMouseDownMask | leftMouseUpMask | rightMouseDownMask | rightMouseUpMask | mouseMovedMask | leftMouseDraggedMask | rightMouseDraggedMask | scrollWheelMask | otherMouseDownMask | otherMouseUpMask | otherMouseDraggedMask
    
    eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                place: .headInsertEventTap,
                                options: .defaultTap,
                                eventsOfInterest: eventMask,
                                callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
      let plugin = Unmanaged<InputCaptureInjectionPlugin>.fromOpaque(refcon!).takeUnretainedValue()
      
      // Check if this event type should be blocked
      let shouldBlock = plugin.shouldBlockEvent(type: type)
      
      plugin.handleEvent(type: type, event: event)
      
      // Return nil to block the event, or the event to allow it through
      return shouldBlock ? nil : Unmanaged.passUnretained(event)
    }, userInfo: Unmanaged.passUnretained(self).toOpaque())
    
    if let tap = eventTap {
      runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
      if let source = runLoopSource {
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
      }
    }
  }

  private func stopEventTap() {
    if let tap = eventTap {
      CGEvent.tapEnable(tap: tap, enable: false)
      eventTap = nil
    }
    if let source = runLoopSource {
      CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
      runLoopSource = nil
    }
  }

  private func handleEvent(type: CGEventType, event: CGEvent) {
    DispatchQueue.main.async { [weak self] in
      switch type {
      case .keyDown, .keyUp, .flagsChanged:
        self?.handleKeyboardEvent(type: type, event: event)
      case .leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp,
           .mouseMoved, .leftMouseDragged, .rightMouseDragged, .scrollWheel,
           .otherMouseDown, .otherMouseUp, .otherMouseDragged:
        self?.handleMouseEvent(type: type, event: event)
      default:
        break
      }
    }
  }

  private func handleKeyboardEvent(type: CGEventType, event: CGEvent) {
    let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
    let flags = event.flags
    let timestamp = Int(event.timestamp)
    
    var eventType: String
    switch type {
    case .keyDown:
      eventType = "keyDown"
    case .keyUp:
      eventType = "keyUp"
    case .flagsChanged:
      eventType = "flagsChanged"
    default:
      return
    }
    
    var modifiers: [String] = []
    if flags.contains(.maskShift) { modifiers.append("shift") }
    if flags.contains(.maskControl) { modifiers.append("control") }
    if flags.contains(.maskAlternate) { modifiers.append("option") }
    if flags.contains(.maskCommand) { modifiers.append("command") }
    if flags.contains(.maskAlphaShift) { modifiers.append("capsLock") }
    if flags.contains(.maskSecondaryFn) { modifiers.append("function") }
    if flags.contains(.maskNumericPad) { modifiers.append("numericPad") }
    if flags.contains(.maskHelp) { modifiers.append("help") }
    
    let eventData: [String: Any] = [
      "kind": "keyboard",
      "code": keyCode,
      "type": eventType,
      "modifiers": modifiers,
      "character": NSNull(),
      "timestamp": timestamp
    ]
    
    inputSink?(eventData)
  }

  private func handleMouseEvent(type: CGEventType, event: CGEvent) {
    let location = event.location
    let timestamp = Int(event.timestamp)
    
    var eventType: String
    var button: String = "left"
    var clickCount = 1
    var deltaX: Double = 0
    var deltaY: Double = 0
    var deltaZ: Double = 0
    
    switch type {
    case .leftMouseDown:
      eventType = "leftMouseDown"
      clickCount = Int(event.getIntegerValueField(.mouseEventClickState))
    case .leftMouseUp:
      eventType = "leftMouseUp"
    case .rightMouseDown:
      eventType = "rightMouseDown"
      button = "right"
      clickCount = Int(event.getIntegerValueField(.mouseEventClickState))
    case .rightMouseUp:
      eventType = "rightMouseUp"
      button = "right"
    case .mouseMoved:
      eventType = "mouseMoved"
    case .leftMouseDragged:
      eventType = "leftMouseDragged"
    case .rightMouseDragged:
      eventType = "rightMouseDragged"
      button = "right"
    case .scrollWheel:
      eventType = "scrollWheel"
      deltaX = event.getDoubleValueField(.scrollWheelEventDeltaAxis1)
      deltaY = event.getDoubleValueField(.scrollWheelEventDeltaAxis2)
      deltaZ = event.getDoubleValueField(.scrollWheelEventDeltaAxis3)
    case .otherMouseDown:
      eventType = "otherMouseDown"
      button = "center"
      clickCount = Int(event.getIntegerValueField(.mouseEventClickState))
    case .otherMouseUp:
      eventType = "otherMouseUp"
      button = "center"
    case .otherMouseDragged:
      eventType = "otherMouseDragged"
      button = "center"
    default:
      return
    }
    
    let eventData: [String: Any] = [
      "kind": "mouse",
      "x": location.x,
      "y": location.y,
      "type": eventType,
      "button": button,
      "clickCount": clickCount,
      "deltaX": deltaX,
      "deltaY": deltaY,
      "deltaZ": deltaZ,
      "timestamp": timestamp
    ]
    
    inputSink?(eventData)
  }

  private func injectMouseInput(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let x = args["x"] as? Double,
          let y = args["y"] as? Double,
          let typeString = args["type"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid mouse event arguments", details: nil))
      return
    }
    
    var eventType: CGEventType
    switch typeString {
    case "leftMouseDown": eventType = .leftMouseDown
    case "leftMouseUp": eventType = .leftMouseUp
    case "rightMouseDown": eventType = .rightMouseDown
    case "rightMouseUp": eventType = .rightMouseUp
    case "mouseMoved": eventType = .mouseMoved
    case "leftMouseDragged": eventType = .leftMouseDragged
    case "rightMouseDragged": eventType = .rightMouseDragged
    case "scrollWheel": eventType = .scrollWheel
    case "otherMouseDown": eventType = .otherMouseDown
    case "otherMouseUp": eventType = .otherMouseUp
    case "otherMouseDragged": eventType = .otherMouseDragged
    default:
      result(FlutterError(code: "INVALID_EVENT_TYPE", message: "Invalid mouse event type", details: nil))
      return
    }
    
    let event = CGEvent(mouseEventSource: nil, mouseType: eventType, mouseCursorPosition: CGPoint(x: x, y: y), mouseButton: .left)
    if let mouseEvent = event {
      mouseEvent.post(tap: .cghidEventTap)
    }
    
    result(nil)
  }

  private func injectKeyboardInput(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let keyCode = args["code"] as? Int,
          let typeString = args["type"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid keyboard event arguments", details: nil))
      return
    }
    
    var eventType: CGEventType
    switch typeString {
    case "keyDown": eventType = .keyDown
    case "keyUp": eventType = .keyUp
    case "flagsChanged": eventType = .flagsChanged
    default:
      result(FlutterError(code: "INVALID_EVENT_TYPE", message: "Invalid keyboard event type", details: nil))
      return
    }
    
    // Handle modifiers
    var flags: CGEventFlags = []
    if let modifiers = args["modifiers"] as? [String] {
      for modifier in modifiers {
        switch modifier {
        case "shift": flags.insert(.maskShift)
        case "control": flags.insert(.maskControl)
        case "option": flags.insert(.maskAlternate)
        case "command": flags.insert(.maskCommand)
        case "capsLock": flags.insert(.maskAlphaShift)
        case "function": flags.insert(.maskSecondaryFn)
        case "numericPad": flags.insert(.maskNumericPad)
        case "help": flags.insert(.maskHelp)
        default: break
        }
      }
    }
    
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: eventType == .keyDown)
    if let keyboardEvent = event {
      keyboardEvent.flags = flags
      keyboardEvent.post(tap: .cghidEventTap)
    }
    
    result(nil)
  }

  private func setInputBlocked(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let blocked = args["blocked"] as? Bool else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      return
    }
    
    let typesList = args["types"] as? [String]
    
    if let typesList = typesList {
      // Block specific input types
      for typeString in typesList {
        if let inputType = InputType(rawValue: typeString) {
          if blocked {
            blockedInputTypes.insert(inputType)
          } else {
            blockedInputTypes.remove(inputType)
          }
        } else {
          result(FlutterError(code: "INVALID_INPUT_TYPE", message: "Invalid input type: \(typeString)", details: nil))
          return
        }
      }
    } else {
      // Block all inputs or unblock all inputs
      if blocked {
        blockedInputTypes = Set(InputType.allCases)
      } else {
        blockedInputTypes.removeAll()
      }
    }
    
    // Update cursor visibility based on current blockedInputTypes state
    if blockedInputTypes.contains(.mouse) {
      hideCursor()
    } else {
      showCursor()
    }
    
    result(true)
  }

  private func getBlockedInputs(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let blockedTypesList = blockedInputTypes.map { $0.rawValue }
    result(blockedTypesList)
  }

  private func shouldBlockEvent(type: CGEventType) -> Bool {
    switch type {
    case .keyDown, .keyUp, .flagsChanged:
      return blockedInputTypes.contains(.keyboard)
    case .leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp,
         .mouseMoved, .leftMouseDragged, .rightMouseDragged, .scrollWheel,
         .otherMouseDown, .otherMouseUp, .otherMouseDragged:
      return blockedInputTypes.contains(.mouse)
    default:
      return false
    }
  }

  private func hideCursor() {
    if originalCursor != nil {
      return
    }
    
    DispatchQueue.main.async {
      if self.originalCursor == nil {
        self.originalCursor = NSCursor.current
      }
      NSCursor.hide()
    }
  }

  private func showCursor() {
    if originalCursor == nil {
      return
    }
    
    DispatchQueue.main.async {
      NSCursor.unhide()
      if let originalCursor = self.originalCursor {
        originalCursor.set()
        self.originalCursor = nil
      }
    }
  }

  deinit {
    stopEventTap()
    showCursor()
  }
}

private class InputStreamHandler: NSObject, FlutterStreamHandler {
  private let onListen: (Any?, @escaping FlutterEventSink) -> FlutterError?
  private let onCancel: (Any?) -> FlutterError?
  
  init(onListen: @escaping (Any?, @escaping FlutterEventSink) -> FlutterError?, 
       onCancel: @escaping (Any?) -> FlutterError?) {
    self.onListen = onListen
    self.onCancel = onCancel
  }
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    return onListen(arguments, events)
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return onCancel(arguments)
  }
}
