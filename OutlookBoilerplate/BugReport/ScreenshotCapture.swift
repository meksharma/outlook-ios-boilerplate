//
//  ScreenshotCapture.swift
//  OutlookBoilerplate
//
//  Snapshots the currently visible screen to a UIImage. Called at bug-report
//  trigger time (shake or beaker row) BEFORE the report form animates up, so
//  the capture shows what the designer was actually looking at.
//

import UIKit

enum ScreenshotCapture {
    /// Renders the app's foreground key window to a UIImage. Returns nil if no
    /// active window can be found (e.g. app not foregrounded).
    static func captureKeyWindow() -> UIImage? {
        guard let window = activeKeyWindow() else { return nil }

        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        return renderer.image { _ in
            // `afterScreenUpdates: false` grabs the already-rendered frame,
            // avoiding a relayout flash and capturing the exact current pixels.
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        }
    }

    private static func activeKeyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap(\.windows)
            .first { $0.isKeyWindow } ??
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first
    }
}
