//
//  BugReport.swift
//  OutlookBoilerplate
//
//  The persisted record for a single in-app bug report. Auto-captured
//  device/app context lives alongside the two user-entered fields (title,
//  description). `markdown` renders a GitHub-Issue-ready body so a report can
//  be shared into Slack/Teams or pasted straight into an Issue later.
//

import Foundation

struct BugReport: Codable, Identifiable, Equatable {
    let id: UUID

    // User-entered
    var title: String
    var details: String

    // Auto-captured context
    var screen: String
    var deviceModel: String
    var osVersion: String
    var appVersion: String
    var buildNumber: String
    var appVariant: String
    var dataMode: String
    var colorScheme: String
    var createdAt: Date

    /// Filename (not full path) of the PNG screenshot stored next to the JSON
    /// in `Documents/BugReports/`. Nil when the user removed the screenshot.
    var screenshotFilename: String?

    init(
        id: UUID = UUID(),
        title: String,
        details: String,
        context: BugReportContext,
        screenshotFilename: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.screen = context.screen
        self.deviceModel = context.deviceModel
        self.osVersion = context.osVersion
        self.appVersion = context.appVersion
        self.buildNumber = context.buildNumber
        self.appVariant = context.appVariant
        self.dataMode = context.dataMode
        self.colorScheme = context.colorScheme
        self.screenshotFilename = screenshotFilename
        self.createdAt = createdAt
    }

    /// GitHub-Issue-ready Markdown body. Kept free of the screenshot (which
    /// travels as a separate image attachment through the share sheet).
    var markdown: String {
        let formatter = ISO8601DateFormatter()
        let when = formatter.string(from: createdAt)

        let body = details.trimmingCharacters(in: .whitespacesAndNewlines)
        let describedBody = body.isEmpty ? "_No description provided._" : body

        return """
        ## \(title.isEmpty ? "Untitled bug report" : title)

        \(describedBody)

        ---

        ### Context
        | Field | Value |
        | --- | --- |
        | Screen | \(screen) |
        | Device | \(deviceModel) |
        | iOS | \(osVersion) |
        | App version | \(appVersion) (\(buildNumber)) |
        | App variant | \(appVariant) |
        | Data source | \(dataMode) |
        | Appearance | \(colorScheme) |
        | Reported | \(when) |

        _Filed from the Outlook iOS Boilerplate in-app bug reporter._
        """
    }
}
