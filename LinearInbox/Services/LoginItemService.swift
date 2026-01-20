import Foundation
import ServiceManagement

/// Manages launch-at-login functionality using SMAppService (macOS 13+)
@MainActor
final class LoginItemService {
    static let shared = LoginItemService()
    
    private init() {}
    
    /// Whether the app is currently registered as a login item
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }
    
    /// Enable or disable launch at login
    /// - Parameter enabled: Whether to enable launch at login
    /// - Throws: Error if registration/unregistration fails
    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}
