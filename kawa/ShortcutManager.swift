import Cocoa

/// Owns the global hotkey bindings for every input source.
///
/// Bindings are registered at launch so shortcuts work without opening the
/// preferences window (e.g. when Kawa is started at login).
final class ShortcutManager {
  static let shared = ShortcutManager()

  /// Input sources keyed by their user defaults key.
  private var sources: [String: InputSource] = [:]

  private init() {}

  static func defaultsKey(for inputSource: InputSource) -> String {
    return inputSource.id.replacingOccurrences(of: ".", with: "-")
  }

  /// Binds shortcuts for all currently enabled input sources.
  func bindAll() {
    InputSource.sources.forEach { bind($0) }
  }

  /// Binds the shortcut stored for `inputSource`. Safe to call repeatedly.
  func bind(_ inputSource: InputSource) {
    let key = ShortcutManager.defaultsKey(for: inputSource)
    let alreadyBound = sources[key] != nil
    sources[key] = inputSource

    // While suspended, resume() will bind everything in `sources`.
    if !alreadyBound && !isSuspended {
      MASShortcutBinder.shared().bindShortcut(withDefaultsKey: key) { [weak self] in
        self?.select(key)
      }
    }
  }

  /// Rebinds the shortcut for `key`, used after a shortcut is cleared.
  func rebind(_ inputSource: InputSource) {
    let key = ShortcutManager.defaultsKey(for: inputSource)
    if sources[key] != nil && !isSuspended {
      MASShortcutBinder.shared().breakBinding(withDefaultsKey: key)
      sources[key] = nil
    }
    bind(inputSource)
  }

  private var isSuspended = false

  /// Unregisters all global hotkeys so a shortcut view can record a key
  /// combination that is already in use (otherwise the hotkey swallows it).
  func suspend() {
    guard !isSuspended else { return }
    isSuspended = true
    sources.keys.forEach { MASShortcutBinder.shared().breakBinding(withDefaultsKey: $0) }
  }

  /// Re-registers all hotkeys from user defaults after recording ends.
  func resume() {
    guard isSuspended else { return }
    isSuspended = false
    let current = Array(sources.values)
    sources.removeAll()
    current.forEach { bind($0) }
  }

  private func select(_ key: String) {
    guard let inputSource = sources[key] else { return }

    inputSource.select()

    if PermanentStorage.showsNotification {
      showNotification(inputSource.name, icon: inputSource.icon)
    }
  }

  private func showNotification(_ message: String, icon: NSImage?) {
    NSUserNotificationCenter.default.removeAllDeliveredNotifications()
    let notification = NSUserNotification()
    notification.informativeText = message
    notification.contentImage = icon
    NSUserNotificationCenter.default.deliver(notification)
  }
}
