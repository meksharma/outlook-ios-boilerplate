//
//  ShakeDetector.swift
//  OutlookBoilerplate
//
//  Bridges UIKit's shake motion event into SwiftUI. UIWindow reports
//  `motionEnded(.motionShake)` up the responder chain; we rebroadcast it as a
//  Notification and expose an `.onShake { }` view modifier for the app root.
//

import SwiftUI
import UIKit

extension Notification.Name {
    static let deviceDidShake = Notification.Name("OutlookBoilerplate.deviceDidShake")
    /// Posted by non-shake entry points (e.g. the Designer Tools "Report a
    /// Bug" row) to request the bug-report form. ContentView owns presentation.
    static let requestBugReport = Notification.Name("OutlookBoilerplate.requestBugReport")
}

/// UIWindow subclass would normally be needed, but SwiftUI hosts its own
/// window. Extending UIWindow directly lets us intercept the shake without
/// swapping the window class — the app already relies on the SwiftUI-managed
/// window, and motion events bubble to it.
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShake, object: nil)
        }
    }
}

private struct ShakeDetectorModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content.onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
            action()
        }
    }
}

extension View {
    /// Runs `action` when the device is shaken anywhere in the app.
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeDetectorModifier(action: action))
    }
}
