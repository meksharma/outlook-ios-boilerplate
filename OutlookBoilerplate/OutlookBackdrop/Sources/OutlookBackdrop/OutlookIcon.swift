//
//  OutlookIcon.swift
//  OutlookBackdrop
//
//  Typed wrapper around the subset of Fluent System Icons vendored into the
//  Boilerplate's `Icon Inbox.xcassets/`. Mirrors the upstream `FluentIcons`
//  Swift package's enum API (`.alert24Regular`, `.send24Filled`, etc.) so
//  callsites read the same way, but the icon source is local — no 15-minute
//  asset-catalog compile on Clean, no SPM resolution flakiness, no CoreUI
//  runtime crash risk.
//
//  Naming convention matches the upstream:
//      {name}{size}{variant}        — enum case
//      ic_fluent_{name}_{size}_{variant} — asset name (rawValue)
//
//  Adding a new icon (per `Icon Inbox.xcassets/README.md`):
//    1. Drop the `.imageset` from fluentui-system-icons into `Icon Inbox.xcassets/`
//    2. Add a case here matching the upstream name pattern.
//
//  Usage:
//      Image(.alert24Regular)
//          .renderingMode(.template)
//          .foregroundStyle(Color.odsNeutralForeground1)
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Typed identifier for Fluent System Icons vendored into the Boilerplate.
public enum OutlookIcon: String, CaseIterable, Sendable {
    // Chrome — nav bar, search, ellipsis
    case alert24Regular            = "ic_fluent_alert_24_regular"
    case search24Regular           = "ic_fluent_search_24_regular"
    case moreHorizontal24Regular   = "ic_fluent_more_horizontal_24_regular"
    case moreHorizontal16Regular   = "ic_fluent_more_horizontal_16_regular"
    case dismiss24Regular          = "ic_fluent_dismiss_24_regular"

    // Mail row + reading pane actions
    case mail24Regular             = "ic_fluent_mail_24_regular"
    case mail24Filled              = "ic_fluent_mail_24_filled"
    case arrowReply24Regular       = "ic_fluent_arrow_reply_24_regular"
    case delete24Regular           = "ic_fluent_delete_24_regular"
    case shield16Filled            = "ic_fluent_shield_16_filled"
    case flag20Filled              = "ic_fluent_flag_20_filled"
    case pin20Filled               = "ic_fluent_pin_20_filled"
    case airplane24Filled          = "ic_fluent_airplane_24_filled"
    case vehicleTruckCube24Filled  = "ic_fluent_vehicle_truck_cube_24_filled"
    case info24Filled              = "ic_fluent_info_24_filled"

    // Filter pill, chevrons
    case filter20Regular           = "ic_fluent_filter_20_regular"
    case chevronDown16Regular      = "ic_fluent_chevron_down_16_regular"
    case chevronRight16Regular     = "ic_fluent_chevron_right_16_regular"

    // Compose toolbar
    case send24Regular             = "ic_fluent_send_24_regular"
    case send24Filled              = "ic_fluent_send_24_filled"
    case attach24Regular           = "ic_fluent_attach_24_regular"
    case camera24Regular           = "ic_fluent_camera_24_regular"
    case textFont24Regular         = "ic_fluent_text_font_24_regular"
    case textEditStyle24Regular    = "ic_fluent_text_edit_style_24_regular"
    case calendarClock24Regular    = "ic_fluent_calendar_clock_24_regular"
    case calendarEmpty24Regular    = "ic_fluent_calendar_empty_24_regular"
    case penSparkle24Regular       = "ic_fluent_pen_sparkle_24_regular"
    case chatSparkle24Regular      = "ic_fluent_chat_sparkle_24_regular"
    case textBulletListSquareSparkle24Regular = "ic_fluent_text_bullet_list_square_sparkle_24_regular"

    // Side drawer — folders, account chrome
    case mailInbox24Regular        = "ic_fluent_mail_inbox_24_regular"
    case drafts24Regular           = "ic_fluent_drafts_24_regular"
    case archive24Regular          = "ic_fluent_archive_24_regular"
    case folder24Regular           = "ic_fluent_folder_24_regular"
    case folderProhibited24Regular = "ic_fluent_folder_prohibited_24_regular"
    case people24Regular           = "ic_fluent_people_24_regular"
    case edit24Regular             = "ic_fluent_edit_24_regular"
    case settings24Regular         = "ic_fluent_settings_24_regular"
    case questionCircle24Regular   = "ic_fluent_question_circle_24_regular"

    // Bottom tab bar (filled when active, regular when not)
    case calendarDate24Regular     = "ic_fluent_calendar_date_24_regular"
    case calendarDate24Filled      = "ic_fluent_calendar_date_24_filled"
    case appFolder24Regular        = "ic_fluent_app_folder_24_regular"
    case appFolder24Filled         = "ic_fluent_app_folder_24_filled"

    // Beaker settings — upstream ships at 16pt + 20pt only, no 24pt variant
    case beakerSettings16Regular   = "ic_fluent_beaker_settings_16_regular"
    case beakerSettings16Filled    = "ic_fluent_beaker_settings_16_filled"
    case beakerSettings20Regular   = "ic_fluent_beaker_settings_20_regular"
    case beakerSettings20Filled    = "ic_fluent_beaker_settings_20_filled"
}

// MARK: - SwiftUI Image init

public extension Image {
    /// Typed init for `OutlookIcon`. Resolves against the main app bundle
    /// (where `Icon Inbox.xcassets/` lives). Mirrors `Image(systemName:)`'s
    /// ergonomics: `Image(.alert24Regular)`.
    init(_ icon: OutlookIcon) {
        self.init(icon.rawValue, bundle: nil)
    }
}

// MARK: - UIImage init (UIKit bridging)

#if canImport(UIKit)
public extension UIImage {
    /// Typed init for `OutlookIcon`. Returns nil if the imageset isn't in the
    /// asset catalog (forgot to drop it into `Icon Inbox.xcassets/`).
    convenience init?(_ icon: OutlookIcon) {
        self.init(named: icon.rawValue)
    }
}
#endif
