//
//  BugReportStore.swift
//  OutlookBoilerplate
//
//  Local, on-device persistence for bug reports. Each report is a JSON file in
//  Documents/BugReports/<id>.json with its PNG screenshot stored alongside as
//  <id>.png. No backend, no auth — the share sheet is the hand-off path.
//

import Foundation
import UIKit

final class BugReportStore {
    static let shared = BugReportStore()

    private let fileManager = FileManager.default
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private var directory: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("BugReports", isDirectory: true)
    }

    private init() {
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    // MARK: - Save

    /// Persists a report and its optional screenshot. Mutates `report` to
    /// record the screenshot filename before writing the JSON. Returns the
    /// saved report (with screenshot filename populated) or throws on failure.
    @discardableResult
    func save(_ report: BugReport, screenshot: UIImage?) throws -> BugReport {
        var stored = report

        if let screenshot, let data = screenshot.pngData() {
            let filename = "\(report.id.uuidString).png"
            try data.write(to: directory.appendingPathComponent(filename), options: .atomic)
            stored.screenshotFilename = filename
        }

        let data = try encoder.encode(stored)
        let url = directory.appendingPathComponent("\(report.id.uuidString).json")
        try data.write(to: url, options: .atomic)
        return stored
    }

    // MARK: - Load

    func loadAll() -> [BugReport] {
        guard let files = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) else { return [] }

        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                (try? Data(contentsOf: url)).flatMap { try? decoder.decode(BugReport.self, from: $0) }
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// Full on-disk URL of a report's screenshot, if it has one.
    func screenshotURL(for report: BugReport) -> URL? {
        guard let filename = report.screenshotFilename else { return nil }
        let url = directory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    // MARK: - Delete

    func delete(_ report: BugReport) {
        try? fileManager.removeItem(at: directory.appendingPathComponent("\(report.id.uuidString).json"))
        if let filename = report.screenshotFilename {
            try? fileManager.removeItem(at: directory.appendingPathComponent(filename))
        }
    }
}
