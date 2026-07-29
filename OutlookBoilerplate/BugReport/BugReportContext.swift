//
//  BugReportContext.swift
//  OutlookBoilerplate
//
//  Snapshots the auto-captured environment for a bug report: device, OS,
//  bundle version, and the current Designer Tools state. Gathered at trigger
//  time so the report reflects exactly what the designer was looking at.
//

import Foundation
import UIKit

struct BugReportContext: Equatable {
    var screen: String
    var deviceModel: String
    var osVersion: String
    var appVersion: String
    var buildNumber: String
    var appVariant: String
    var dataMode: String
    var colorScheme: String

    /// Builds a context from live system + `UserDefaults` state. `screen` is
    /// passed in because only the SwiftUI layer knows which surface is showing.
    static func capture(screen: String) -> BugReportContext {
        let device = UIDevice.current
        let defaults = UserDefaults.standard
        let info = Bundle.main.infoDictionary

        return BugReportContext(
            screen: screen,
            deviceModel: hardwareModel(),
            osVersion: "\(device.systemName) \(device.systemVersion)",
            appVersion: info?["CFBundleShortVersionString"] as? String ?? "—",
            buildNumber: info?["CFBundleVersion"] as? String ?? "—",
            // Mirror the same @AppStorage keys the Designer Tools sheet writes.
            appVariant: defaults.string(forKey: "appVariant") ?? "production",
            dataMode: defaults.string(forKey: "dataMode") ?? "demo",
            colorScheme: defaults.string(forKey: "appColorScheme") ?? "light"
        )
    }

    /// Raw hardware identifier (e.g. "iPhone16,2"). `UIDevice.model` only
    /// returns "iPhone"; the machine string is far more useful in a report.
    /// On the simulator this resolves to the host arch, so we fall back to the
    /// simulated model identifier when present.
    private static func hardwareModel() -> String {
        if let simulated = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return "\(simulated) (Simulator)"
        }
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafeBytes(of: &systemInfo.machine) { raw -> String in
            let bytes = raw.prefix { $0 != 0 }
            return String(decoding: bytes, as: UTF8.self)
        }
        return machine.isEmpty ? "Unknown device" : machine
    }
}
