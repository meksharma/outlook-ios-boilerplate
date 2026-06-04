//
//  Persona.swift
//  OutlookBackdrop
//
//  Typed wrapper around the subset of CELA-approved persona avatars vendored
//  into `Avatars.xcassets`. Sourced from the Fluent avatars Figma file:
//      https://www.figma.com/design/KGP1cSTKB0NsKZeLhkdlJBXv
//      `🎨 Fluent avatars` — node `6251:222`
//
//  Each persona is a CELA-approved name + portrait pair. Use them as mock
//  sender data anywhere the Boilerplate needs realistic-looking content
//  (mail rows, reading pane, drawer, etc.).
//
//  Usage:
//      // Random
//      let p = Persona.random()
//
//      // Specific
//      Image(.sarahPerez)
//          .resizable()
//          .clipShape(Circle())
//          .frame(width: 40, height: 40)
//
//  Adding a new persona (per `Avatars.xcassets/README.md`):
//    1. Drop the imageset into `Avatars.xcassets/`
//    2. Add a case here matching the file name (kebab-case in rawValue).
//

import SwiftUI

/// Typed identifier for a CELA-approved persona avatar vendored from the
/// Fluent avatars Figma file. `displayName` returns the human-readable name
/// used in sample mail rows.
public enum Persona: String, CaseIterable, Sendable, Hashable {
    case sarahPerez        = "sarah-perez"
    case mauricioAugust    = "mauricio-august"
    case carlosSlattery    = "carlos-slattery"
    case daisyPhillips     = "daisy-phillips"
    case allanMunger       = "allan-munger"
    case aadiKapoor        = "aadi-kapoor"
    case ashleyMccarthy    = "ashley-mccarthy"
    case cassandraDunn     = "cassandra-dunn"
    case wandaHoward       = "wanda-howard"
    case henryBrill        = "henry-brill"
    case keikoTanaka       = "keiko-tanaka"
    case monaKane          = "mona-kane"
    case robinCounts       = "robin-counts"
    case charlotteWaltson  = "charlotte-waltson"
    case kadjiBell         = "kadji-bell"
    case ericIshida        = "eric-ishida"
    case erikaFuller       = "erika-fuller"
    case kristinPatterson  = "kristin-patterson"
    case bethDavies        = "beth-davies"
    case timDeboer         = "tim-deboer"
    case danielaMandera    = "daniela-mandera"
    case elliotWoodward    = "elliot-woodward"
    case andreLawson       = "andre-lawson"
    case lydiaBauer        = "lydia-bauer"
    case babakShammas      = "babak-shammas"
    case kayoMiwa          = "kayo-miwa"
    case robertTolbert     = "robert-tolbert"
    case carolePoland      = "carole-poland"
    case brunoZhao         = "bruno-zhao"
    case hillaryReyes      = "hillary-reyes"

    /// Human-readable display name for the persona.
    public var displayName: String {
        switch self {
        case .sarahPerez:       return "Sarah Perez"
        case .mauricioAugust:   return "Mauricio August"
        case .carlosSlattery:   return "Carlos Slattery"
        case .daisyPhillips:    return "Daisy Phillips"
        case .allanMunger:      return "Allan Munger"
        case .aadiKapoor:       return "Aadi Kapoor"
        case .ashleyMccarthy:   return "Ashley McCarthy"
        case .cassandraDunn:    return "Cassandra Dunn"
        case .wandaHoward:      return "Wanda Howard"
        case .henryBrill:       return "Henry Brill"
        case .keikoTanaka:      return "Keiko Tanaka"
        case .monaKane:         return "Mona Kane"
        case .robinCounts:      return "Robin Counts"
        case .charlotteWaltson: return "Charlotte Waltson"
        case .kadjiBell:        return "Kadji Bell"
        case .ericIshida:       return "Eric Ishida"
        case .erikaFuller:      return "Erika Fuller"
        case .kristinPatterson: return "Kristin Patterson"
        case .bethDavies:       return "Beth Davies"
        case .timDeboer:        return "Tim Deboer"
        case .danielaMandera:   return "Daniela Mandera"
        case .elliotWoodward:   return "Elliot Woodward"
        case .andreLawson:      return "Andre Lawson"
        case .lydiaBauer:       return "Lydia Bauer"
        case .babakShammas:     return "Babak Shammas"
        case .kayoMiwa:         return "Kayo Miwa"
        case .robertTolbert:    return "Robert Tolbert"
        case .carolePoland:     return "Carole Poland"
        case .brunoZhao:        return "Bruno Zhao"
        case .hillaryReyes:     return "Hillary Reyes"
        }
    }

    /// Pick a random persona. Useful for fixture generation + the randomize
    /// content control. Never returns nil because `allCases` is non-empty.
    public static func random() -> Persona {
        allCases.randomElement()!
    }
}

// MARK: - SwiftUI Image init

public extension Image {
    /// Typed init for `Persona`. Resolves the avatar asset against the main
    /// app bundle (where `Avatars.xcassets/` lives). Mirrors the ergonomics
    /// of `Image(.alert24Regular)` from `OutlookIcon`.
    init(_ persona: Persona) {
        self.init(persona.rawValue, bundle: nil)
    }
}
