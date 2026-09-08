//
//  OutlookBoilerplateApp.swift
//  OutlookBoilerplate
//

import OutlookBackdrop
import SwiftUI
import UIKit

@main
struct OutlookBoilerplateApp: App {
    init() {
        OutlookBackdrop.applyToFluentTheme()
        UIViewController.swizzleStatusBarStyleForLightContent()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(StatusBarRefresher())
        }
    }
}

// MARK: - Status bar style override via swizzle + refresh

/// Production Outlook iOS renders the status bar in white (`.lightContent`)
/// regardless of system light/dark mode — the Inbox nav bar is brand blue
/// and dark text would be unreadable. SwiftUI's `.preferredColorScheme()`
/// modifier in `ContentView` pushes `UIWindow.overrideUserInterfaceStyle`,
/// whose derived trait collection forces `.darkContent` status bar
/// automatically — overriding both Info.plist's `UIStatusBarStyle` directive
/// and any custom `UIHostingController` subclass.
///
/// Workaround in two parts:
///
///   1. Swizzle `UIViewController.preferredStatusBarStyle` (getter) so every
///      VC returns `.lightContent`, and swizzle `childForStatusBarStyle`
///      (getter) so no VC delegates the decision down. The combination means
///      the status-bar style resolution chain terminates with `.lightContent`
///      at whichever VC iOS asks.
///
///   2. Force a refresh via `setNeedsStatusBarAppearanceUpdate()` on every
///      window's root VC after the swizzle is installed. SwiftUI doesn't
///      always trigger this on its own, so the initial style can lag behind
///      the swizzle until the user interacts.
///
/// Trade-off: white status bar EVERYWHERE — including the Calendar / Apps
/// placeholder tabs (white backgrounds). Acceptable for Phase 1; revisit
/// when those tabs ship real chrome.
private extension UIViewController {
    static func swizzleStatusBarStyleForLightContent() {
        swizzleGetter(
            of: #selector(getter: UIViewController.preferredStatusBarStyle),
            with: #selector(UIViewController._light_preferredStatusBarStyle)
        )
        swizzleGetter(
            of: #selector(getter: UIViewController.childForStatusBarStyle),
            with: #selector(UIViewController._nil_childForStatusBarStyle)
        )
    }

    private static func swizzleGetter(of original: Selector, with replacement: Selector) {
        guard
            let originalMethod = class_getInstanceMethod(UIViewController.self, original),
            let replacementMethod = class_getInstanceMethod(UIViewController.self, replacement)
        else { return }
        method_exchangeImplementations(originalMethod, replacementMethod)
    }

    @objc func _light_preferredStatusBarStyle() -> UIStatusBarStyle {
        .lightContent
    }

    @objc func _nil_childForStatusBarStyle() -> UIViewController? {
        nil
    }
}

/// Empty view whose only job is to find the window after the SwiftUI hierarchy
/// is mounted and ask each window's root VC to re-evaluate status bar style.
/// Without this, the swizzle is installed but the initial render still shows
/// the pre-swizzle style until something triggers a status-bar update.
private struct StatusBarRefresher: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        DispatchQueue.main.async {
            forceStatusBarUpdate()
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            forceStatusBarUpdate()
        }
    }

    private func forceStatusBarUpdate() {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { $0.rootViewController?.setNeedsStatusBarAppearanceUpdate() }
    }
}
