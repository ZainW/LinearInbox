import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let openLinearInbox = Self("openLinearInbox")
}

@main
struct LinearInboxApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Linear Inbox", systemImage: "tray.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set default shortcut if not already set
        if KeyboardShortcuts.getShortcut(for: .openLinearInbox) == nil {
            KeyboardShortcuts.setShortcut(.init(.i, modifiers: [.command, .option]), for: .openLinearInbox)
        }

        // Register global hotkey handler
        KeyboardShortcuts.onKeyUp(for: .openLinearInbox) {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
