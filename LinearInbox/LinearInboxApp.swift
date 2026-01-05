import SwiftUI

@main
struct LinearInboxApp: App {
    var body: some Scene {
        MenuBarExtra("Linear Inbox", systemImage: "tray.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}
