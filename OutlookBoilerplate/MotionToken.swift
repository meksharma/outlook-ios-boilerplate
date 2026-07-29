//
//  MotionToken.swift
//
//  AUTO-GENERATED from MotionDesignSystem/motion-tokens.json
//  Do not edit manually. Regenerate with:
//    node MotionDesignSystem/editor/generate-all.js
//

import SwiftUI

// MARK: - Easing Tokens

enum MotionEasing: String, CaseIterable {
    case enter
    case exit
    case standard
    case emphasized
    case linear
    case bounce

    var controlPoints: (Double, Double, Double, Double) {
        switch self {
        case .enter: return (0.0, 0.0, 0.2, 1.0)
        case .exit: return (0.4, 0.0, 1.0, 1.0)
        case .standard: return (0.8, 0.0, 0.2, 1.0)
        case .emphasized: return (0.05, 0.7, 0.1, 1.0)
        case .linear: return (0.0, 0.0, 1.0, 1.0)
        case .bounce: return (0.34, 1.54, 0.64, 1.0)
        }
    }

    func animation(duration: Double) -> Animation {
        let cp = controlPoints
        return .timingCurve(cp.0, cp.1, cp.2, cp.3, duration: duration)
    }
}

// MARK: - Duration Tokens

enum MotionDuration: String, CaseIterable {
    case instant
    case fast
    case normal
    case moderate
    case slow
    case gentle

    var seconds: Double {
        switch self {
        case .instant: return 0.05
        case .fast: return 0.15
        case .normal: return 0.25
        case .moderate: return 0.35
        case .slow: return 0.5
        case .gentle: return 0.7
        }
    }

    var milliseconds: Int { Int(seconds * 1000) }
}

// MARK: - Component Motion Assignment

enum MotionComponent: String, CaseIterable {
    case actionBar
    case sideDrawer
    case tabPill
    case tabCell
    case composePillFAB
    case copilotPillFAB
    case readingPane
    case copilotSheet
    case composeModal
    case inboxHeader
    case inboxRow
    case floatingButton
    case bottomNav
    case composeToolbar
    case alertDialog
    case tabBarIndicator

    var enterEasing: MotionEasing {
        switch self {
        case .actionBar: return .emphasized
        case .sideDrawer: return .enter
        case .tabPill: return .emphasized
        case .tabCell: return .emphasized
        case .composePillFAB: return .bounce
        case .copilotPillFAB: return .bounce
        case .readingPane: return .enter
        case .copilotSheet: return .emphasized
        case .composeModal: return .enter
        case .inboxHeader: return .enter
        case .inboxRow: return .enter
        case .floatingButton: return .enter
        case .bottomNav: return .standard
        case .composeToolbar: return .enter
        case .alertDialog: return .enter
        case .tabBarIndicator: return .enter
        }
    }

    var enterDuration: MotionDuration {
        switch self {
        case .actionBar: return .moderate
        case .sideDrawer: return .normal
        case .tabPill: return .moderate
        case .tabCell: return .normal
        case .composePillFAB: return .normal
        case .copilotPillFAB: return .normal
        case .readingPane: return .moderate
        case .copilotSheet: return .moderate
        case .composeModal: return .normal
        case .inboxHeader: return .normal
        case .inboxRow: return .normal
        case .floatingButton: return .normal
        case .bottomNav: return .fast
        case .composeToolbar: return .normal
        case .alertDialog: return .normal
        case .tabBarIndicator: return .normal
        }
    }

    var exitEasing: MotionEasing {
        switch self {
        case .actionBar: return .exit
        case .sideDrawer: return .exit
        case .tabPill: return .exit
        case .tabCell: return .exit
        case .composePillFAB: return .exit
        case .copilotPillFAB: return .standard
        case .readingPane: return .exit
        case .copilotSheet: return .exit
        case .composeModal: return .exit
        case .inboxHeader: return .exit
        case .inboxRow: return .exit
        case .floatingButton: return .exit
        case .bottomNav: return .exit
        case .composeToolbar: return .exit
        case .alertDialog: return .exit
        case .tabBarIndicator: return .exit
        }
    }

    var exitDuration: MotionDuration {
        switch self {
        case .actionBar: return .moderate
        case .sideDrawer: return .normal
        case .tabPill: return .moderate
        case .tabCell: return .normal
        case .composePillFAB: return .normal
        case .copilotPillFAB: return .fast
        case .readingPane: return .moderate
        case .copilotSheet: return .moderate
        case .composeModal: return .fast
        case .inboxHeader: return .normal
        case .inboxRow: return .normal
        case .floatingButton: return .normal
        case .bottomNav: return .fast
        case .composeToolbar: return .normal
        case .alertDialog: return .normal
        case .tabBarIndicator: return .normal
        }
    }

    var enterAnimation: Animation {
        enterEasing.animation(duration: enterDuration.seconds)
    }

    var exitAnimation: Animation {
        exitEasing.animation(duration: exitDuration.seconds)
    }
}

// MARK: - View Extension

extension View {
    func motionEnter<V: Equatable>(_ component: MotionComponent, value: V) -> some View {
        animation(component.enterAnimation, value: value)
    }

    func motionExit<V: Equatable>(_ component: MotionComponent, value: V) -> some View {
        animation(component.exitAnimation, value: value)
    }

    func motionAnimation<V: Equatable>(_ component: MotionComponent, value: V, isEntering: Bool) -> some View {
        animation(isEntering ? component.enterAnimation : component.exitAnimation, value: value)
    }

    func motionAnimationSafe<V: Equatable>(
        _ component: MotionComponent,
        value: V,
        isEntering: Bool,
        reduceMotion: Bool
    ) -> some View {
        animation(
            reduceMotion ? .easeOut(duration: 0.15) : (isEntering ? component.enterAnimation : component.exitAnimation),
            value: value
        )
    }
}
