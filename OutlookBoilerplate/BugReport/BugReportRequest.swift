//
//  BugReportRequest.swift
//  OutlookBoilerplate
//
//  Identifiable payload for presenting the bug-report form via `.sheet(item:)`.
//  Bundling the captured context + screenshot into one non-optional value lets
//  the sheet present only when everything is ready — sidestepping the blank
//  sheet that an `isPresented`-plus-optional pattern can produce.
//

import UIKit

struct BugReportRequest: Identifiable {
    let id = UUID()
    let context: BugReportContext
    let screenshot: UIImage?
}
