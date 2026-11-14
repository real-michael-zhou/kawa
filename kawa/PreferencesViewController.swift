import Cocoa

class PreferencesViewController: NSViewController {
  @IBOutlet weak var showNotificationCheckbox: NSButton!
  @IBOutlet weak var launchAtLoginCheckbox: NSButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    showNotificationCheckbox.state = PermanentStorage.showsNotification.stateValue
    launchAtLoginCheckbox.isEnabled = LaunchAtLogin.isSupported
  }

  override func viewWillAppear() {
    super.viewWillAppear()

    // The user may change login items in System Settings, so refresh each time.
    launchAtLoginCheckbox.state = LaunchAtLogin.isEnabled.stateValue
  }

  @IBAction func quitApp(_ sender: NSButton) {
    NSApplication.shared.terminate(nil)
  }

  @IBAction func launchAtLogin(_ sender: NSButton) {
    if let error = LaunchAtLogin.setEnabled(sender.state.boolValue) {
      let alert = NSAlert()
      alert.messageText = "Failed to change the login item"
      alert.informativeText = error
      alert.runModal()
    }
    sender.state = LaunchAtLogin.isEnabled.stateValue
  }

  @IBAction func showNotification(_ sender: NSButton) {
    PermanentStorage.showsNotification = sender.state.boolValue
  }
}

private extension Bool {
  var stateValue: NSControl.StateValue {
    return self ? .on : .off;
  }
}

private extension NSControl.StateValue {
  var boolValue: Bool {
    return self == .on;
  }
}
