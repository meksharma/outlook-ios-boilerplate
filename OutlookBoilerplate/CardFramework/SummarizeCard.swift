import SwiftUI
import OutlookBackdrop

struct SummarizeCard: View {
    @State private var state: OutlookCardState
    @State private var streamingStage = 0
    @State private var generationTask: Task<Void, Never>?
    private let theme: OutlookCardTheme
    private let onOpenReferences: ([OutlookCardReference]) -> Void
    private let onAction: (OutlookCardAction) -> Void

    init(
        initialState: OutlookCardState = .preGeneration,
        theme: OutlookCardTheme = .neutral,
        onOpenReferences: @escaping ([OutlookCardReference]) -> Void = { _ in },
        onAction: @escaping (OutlookCardAction) -> Void = { _ in }
    ) {
        _state = State(initialValue: initialState)
        self.theme = theme
        self.onOpenReferences = onOpenReferences
        self.onAction = onAction
    }

    var body: some View {
        OutlookCardView(
            state: state,
            content: .summarize,
            theme: theme,
            streamingStage: streamingStage,
            onGenerate: generateSummary,
            onToggleExpansion: toggleExpansion,
            onRetry: generateSummary,
            onAction: onAction,
            onOpenCitation: onOpenReferences,
            onOpenSources: {
                onOpenReferences(OutlookCardContent.summarize.references)
            }
        )
        .animation(
            MotionEasing.emphasized.animation(duration: MotionDuration.normal.seconds),
            value: state
        )
        .animation(
            MotionEasing.enter.animation(duration: MotionDuration.fast.seconds),
            value: streamingStage
        )
        .onDisappear {
            generationTask?.cancel()
        }
    }

    private func generateSummary() {
        generationTask?.cancel()
        state = .latencyWithoutText
        streamingStage = 0

        generationTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .milliseconds(700))
                state = .latencyWithTextStreaming
                try await Task.sleep(for: .milliseconds(350))
                state = .streamingExpanded

                for index in OutlookCardContent.summarize.streamingStages.indices.dropFirst() {
                    try await Task.sleep(for: .milliseconds(450))
                    streamingStage = index
                }

                try await Task.sleep(for: .milliseconds(600))
                state = state == .streamingCollapsed
                    ? .outputCollapsed
                    : .outputExpanded
            } catch is CancellationError {
                return
            } catch {
                assertionFailure("Unexpected summary generation delay failure: \(error)")
            }
        }
    }

    private func toggleExpansion() {
        switch state {
        case .outputCollapsed:
            state = .outputExpanded
        case .outputExpanded:
            state = .outputCollapsed
        case .streamingCollapsed:
            state = .streamingExpanded
        case .streamingExpanded:
            state = .streamingCollapsed
        default:
            break
        }
    }
}

private extension OutlookCardContent {
    static let summarizeReferences = [
        OutlookCardReference(
            id: "weekly-update",
            kind: .mail,
            title: "Weekly Update",
            excerpt: "Hi team, I wanted to share a quick update following our latest discussion on the Copilot search toggle experience.",
            date: "4/8/2026 5:02 AM"
        ),
        OutlookCardReference(
            id: "copilot-search-results",
            kind: .mail,
            title: "Copilot Search Results",
            excerpt: "\"...customers often submitted tickets for performance...\"",
            date: "3/29/2026 8:42 AM"
        ),
        OutlookCardReference(
            id: "daily-scrum",
            kind: .chat,
            title: "Daily scrum",
            excerpt: "Conversation with Jane Liu and 23 others",
            date: nil
        )
    ]

    static let summarize = OutlookCardContent(
        prompt: "Get up to speed fast",
        commandTitle: "Summarize",
        title: "Summary",
        generatingTitle: "Creating summary...",
        errorTitle: "Something went wrong",
        feedbackPrompt: "Give feedback?",
        summaryItems: [
            OutlookCardSummaryItem(
                id: "rollout-decision",
                text: "Team decided not to roll out the tooltip prompting turning off Copilot search with the toggle experience.",
                citation: OutlookCardCitation(references: summarizeReferences)
            ),
            OutlookCardSummaryItem(
                id: "messaging-debate",
                text: "There is also ongoing debate about whether messaging is needed to help users find the setting to disable Copilot search after enabling it.",
                citation: nil
            ),
            OutlookCardSummaryItem(
                id: "feature-sync",
                text: "The group will discuss messaging and user experience concerns in the next feature sync.",
                citation: OutlookCardCitation(
                    references: [summarizeReferences[0]]
                )
            )
        ],
        streamingStages: [
            [
                "Team decided not"
            ],
            [
                "Team decided not to roll out the tooltip prompting turning off Copilot search."
            ],
            [
                "Team decided not to roll out the tooltip prompting turning off Copilot search with the toggle experience.",
                "There is also ongoing debate"
            ],
            [
                "Team decided not to roll out the tooltip prompting turning off Copilot search with the toggle experience.",
                "There is also ongoing debate about whether the change should ship in the next release."
            ]
        ],
        actions: [
            OutlookCardAction(
                id: "show-more-details",
                title: "Show more details"
            ),
            OutlookCardAction(
                id: "make-bullets-concise",
                title: "Make the bullets more concise"
            ),
            OutlookCardAction(
                id: "ask-copilot",
                title: "Ask Copilot"
            )
        ],
        actionOnlyItems: [
            OutlookCardAction(
                id: "propose-new-time",
                title: "Propose a new time",
                emphasizedPrefix: "Propose",
                icon: .deviceEq24Regular
            ),
            OutlookCardAction(
                id: "draft-response",
                title: "Draft a response",
                emphasizedPrefix: "Draft",
                icon: .deviceEq24Regular
            )
        ],
        references: summarizeReferences
    )
}

#Preview("Card Framework states") {
    ScrollView {
        LazyVStack(spacing: .odsSize160) {
            ForEach(OutlookCardState.allCases) { state in
                VStack(alignment: .leading, spacing: .odsSize80) {
                    Text(state.displayName)
                        .odsCaption1Strong()
                        .foregroundStyle(Color.odsNeutralForeground2)

                    OutlookCardView(
                        state: state,
                        content: .summarize
                    )
                }
            }
        }
        .padding(.odsSize160)
    }
    .background(Color.odsNeutralBackground1)
}
