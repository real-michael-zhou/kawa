import Cocoa

class ShortcutCellView: NSTableCellView {
  @IBOutlet weak var shortcutView: MASShortcutView!

  var inputSource: InputSource?
  private var recordingObservation: NSKeyValueObservation?

  func setInputSource(_ inputSource: InputSource) {
    self.inputSource = inputSource
    shortcutView.associatedUserDefaultsKey = ShortcutManager.defaultsKey(for: inputSource)
    shortcutView.shortcutValueChange = self.shortcutValueDidChange
    // Picks up input sources enabled after launch; no-op if already bound.
    ShortcutManager.shared.bind(inputSource)

    // Global hotkeys would swallow a combination that is already in use, so
    // pause them while this view is recording.
    recordingObservation = shortcutView.observe(\.isRecording, options: [.new]) { view, _ in
      if view.isRecording {
        ShortcutManager.shared.suspend()
      } else {
        ShortcutManager.shared.resume()
      }
    }
  }

  func shortcutValueDidChange(_ sender: MASShortcutView?) {
    if sender?.shortcutValue == nil, let inputSource = inputSource {
      ShortcutManager.shared.rebind(inputSource)
    }
  }
}
