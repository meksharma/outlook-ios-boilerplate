import Foundation
import OutlookBackdrop

enum OutlookCardTheme: String, CaseIterable {
    case brand
    case neutral
}

enum OutlookCardState: String, CaseIterable, Identifiable {
    case preGeneration
    case preGenerationAlternate
    case latencyWithTextStreaming
    case latencyWithoutText
    case outputCollapsed
    case outputExpanded
    case error
    case actionOnly
    case streamingCollapsed
    case streamingExpanded

    var id: Self { self }

    var displayName: String {
        switch self {
        case .preGeneration:
            "Pre-Generation"
        case .preGenerationAlternate:
            "Pre-Generation Alternate"
        case .latencyWithTextStreaming:
            "Latency with text streaming"
        case .latencyWithoutText:
            "Latency without text"
        case .outputCollapsed:
            "Output Collapsed"
        case .outputExpanded:
            "Output Expanded"
        case .error:
            "Error"
        case .actionOnly:
            "Action Only Card"
        case .streamingCollapsed:
            "Streaming Collapsed"
        case .streamingExpanded:
            "Streaming Expanded"
        }
    }
}

struct OutlookCardAction: Identifiable {
    let id: String
    let title: String
    let emphasizedPrefix: String?
    let icon: OutlookIcon?

    init(
        id: String,
        title: String,
        emphasizedPrefix: String? = nil,
        icon: OutlookIcon? = nil
    ) {
        self.id = id
        self.title = title
        self.emphasizedPrefix = emphasizedPrefix
        self.icon = icon
    }
}

enum OutlookCardReferenceKind {
    case mail
    case chat
}

struct OutlookCardReference: Identifiable {
    let id: String
    let kind: OutlookCardReferenceKind
    let title: String
    let excerpt: String
    let date: String?
}

struct OutlookCardCitation {
    let references: [OutlookCardReference]
}

struct OutlookCardSummaryItem: Identifiable {
    let id: String
    let text: String
    let citation: OutlookCardCitation?
}

struct OutlookReferencesSheetModel: Identifiable {
    let id = UUID()
    let references: [OutlookCardReference]
}

struct OutlookActionChatSheetModel: Identifiable {
    let id = UUID()
    let action: OutlookCardAction
}

struct OutlookCardContent {
    let prompt: String
    let commandTitle: String
    let title: String
    let generatingTitle: String
    let errorTitle: String
    let feedbackPrompt: String
    let summaryItems: [OutlookCardSummaryItem]
    let streamingStages: [[String]]
    let actions: [OutlookCardAction]
    let actionOnlyItems: [OutlookCardAction]
    let references: [OutlookCardReference]
}
