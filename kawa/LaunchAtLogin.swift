import Cocoa
import ServiceManagement

/// Registers Kawa as a login item via `SMAppService` (macOS 13+).
///
/// Legacy login items added manually in System Settings are launched by
/// loginwindow and are not reliable on recent macOS versions; registering the
/// main app with `SMAppService` lets launchd start it at login.
enum LaunchAtLogin {
  static var isSupported: Bool {
    if #available(macOS 13.0, *) {
      return true
    }
    return false
  }

  static var isEnabled: Bool {
    guard #available(macOS 13.0, *) else { return false }
    return SMAppService.mainApp.status == .enabled
  }

  static var requiresApproval: Bool {
    guard #available(macOS 13.0, *) else { return false }
    return SMAppService.mainApp.status == .requiresApproval
  }

  /// Returns the error message if the operation failed.
  @discardableResult
  static func setEnabled(_ enabled: Bool) -> String? {
    guard #available(macOS 13.0, *) else {
      return "Launch at login requires macOS 13 or later."
    }

    let service = SMAppService.mainApp
    do {
      if enabled {
        if service.status != .enabled {
          try service.register()
        }
      } else if service.status == .enabled || service.status == .requiresApproval {
        try service.unregister()
      }
    } catch {
      NSLog("Kawa: failed to \(enabled ? "register" : "unregister") login item: \(error)")
      return error.localizedDescription
    }

    if enabled && service.status == .requiresApproval {
      SMAppService.openSystemSettingsLoginItems()
    }
    return nil
  }
}
