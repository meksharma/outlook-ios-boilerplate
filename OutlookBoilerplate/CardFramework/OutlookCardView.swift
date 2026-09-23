import SwiftUI
import OutlookBackdrop

struct OutlookCardView: View {
    let state: OutlookCardState
    let content: OutlookCardContent
    var theme: OutlookCardTheme = .brand
    var streamingStage: Int = .max
    var onGenerate: () -> Void = {}
    var onToggleExpansion: () -> Void = {}
    var onRetry: () -> Void = {}
    var onAction: (OutlookCardAction) -> Void = { _ in }
    var onOpenCitation: ([OutlookCardReference]) -> Void = { _ in }
    var onOpenSources: () -> Void = {}
    var onCopy: () -> Void = {}
    var onFeedback: (Bool) -> Void = { _ in }

    private enum Metrics {
        static let cardRadius: CGFloat = 24
        static let preGenerationRadius: CGFloat = 20
        static let pillRadius: CGFloat = 16
        static let iconButtonSize: CGFloat = 36
        static let progressSize: CGFloat = 12
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .odsSize120) {
            switch state {
            case .preGeneration:
                preGeneration
            case .preGenerationAlternate:
                preGenerationAlternate
            case .latencyWithTextStreaming:
                generationHeader(isExpanded: true)
                streamingSummaryList(items: visibleStreamingItems)
            case .latencyWithoutText:
                generationHeader()
            case .outputCollapsed:
                outputHeader(isExpanded: false)
                collapsedSummary(items: content.summaryItems)
            case .outputExpanded:
                outputHeader(isExpanded: true)
                summaryList(items: content.summaryItems)
                actionPills(content.actions)
                outputFooter
            case .error:
                errorHeader
                errorFooter
            case .actionOnly:
                outputHeader(isExpanded: true)
                actionPills(content.actionOnlyItems)
                actionOnlyFooter
            case .streamingCollapsed:
                generationHeader(isExpanded: false)
                collapsedStreamingText
            case .streamingExpanded:
                generationHeader(isExpanded: true)
                streamingSummaryList(items: visibleStreamingItems)
            }
        }
        .padding(.horizontal, .odsSize160)
        .padding(.vertical, .odsSize120)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: cardRadius, style: .continuous))
    }

    private var cardBackground: Color {
        switch theme {
        case .brand:
            Color.odsBrandBackgroundTint2
        case .neutral:
            Color.odsNeutralBackground5
        }
    }

    private var cardRadius: CGFloat {
        state == .preGeneration
            ? Metrics.preGenerationRadius
            : Metrics.cardRadius
    }

    private var preGeneration: some View {
        Button(action: onGenerate) {
            HStack(spacing: .odsSize80) {
                Image(.textBulletListSquareSparkle20Regular)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)

                Text(content.commandTitle)
                    .odsBody2Strong()

                Spacer(minLength: 0)
            }
            .foregroundStyle(commandForeground)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .hotspotTarget()
        .accessibilityHint("Creates a summary of this message")
    }

    private var preGenerationAlternate: some View {
        HStack(spacing: .odsSize120) {
            Text(content.prompt)
                .odsBody2()
                .foregroundStyle(Color.odsNeutralForeground1)

            Spacer(minLength: .odsSize80)

            Button(action: onGenerate) {
                HStack(spacing: .odsSize80) {
                    Image(.textBulletListSquareSparkle24Regular)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)

                    Text(content.commandTitle)
                        .odsBody2Strong()
                }
                .foregroundStyle(commandForeground)
            }
            .buttonStyle(.plain)
            .hotspotTarget()
            .accessibilityHint("Creates a summary of this message")
        }
    }

    private var commandForeground: Color {
        switch theme {
        case .brand:
            Color.odsBrandForegroundTint
        case .neutral:
            Color.odsNeutralForeground1
        }
    }

    @ViewBuilder
    private func generationHeader(isExpanded: Bool? = nil) -> some View {
        if let isExpanded {
            Button(action: onToggleExpansion) {
                generationHeaderLabel(isExpanded: isExpanded)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .hotspotTarget()
            .accessibilityLabel(
                "\(content.generatingTitle), \(isExpanded ? "expanded" : "collapsed")"
            )
            .accessibilityHint(
                isExpanded ? "Collapses the generating summary" : "Expands the generating summary"
            )
        } else {
            generationHeaderLabel(isExpanded: nil)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(content.generatingTitle)
        }
    }

    private func generationHeaderLabel(isExpanded: Bool?) -> some View {
        HStack(spacing: .odsSize40) {
            AnimatedGIFView(
                assetName: "card_latency_animation",
                size: CGSize(
                    width: Metrics.progressSize,
                    height: Metrics.progressSize
                )
            )
                .frame(width: Metrics.progressSize, height: Metrics.progressSize)
                .clipped()
                .frame(width: 20, height: 20)
                .accessibilityHidden(true)

            Text(content.generatingTitle)
                .odsBody2Strong()
                .foregroundStyle(Color.odsNeutralForeground1)

            Spacer(minLength: 0)

            if let isExpanded {
                Image(isExpanded ? .chevronUp16Regular : .chevronDown16Regular)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color.odsNeutralForeground1)
                    .accessibilityHidden(true)
            }
        }
    }

    private func outputHeader(isExpanded: Bool) -> some View {
        Button(action: onToggleExpansion) {
            HStack(spacing: .odsSize80) {
                Text(content.title)
                    .odsBody2Strong()

                Spacer(minLength: 0)

                Image(isExpanded ? .chevronUp16Regular : .chevronDown16Regular)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Color.odsNeutralForeground1)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .hotspotTarget()
        .accessibilityLabel("\(content.title), \(isExpanded ? "expanded" : "collapsed")")
        .accessibilityHint(isExpanded ? "Collapses the card" : "Expands the card")
    }

    private var errorHeader: some View {
        HStack(spacing: .odsSize120) {
            Text(content.errorTitle)
                .odsBody2()
                .foregroundStyle(Color.odsNeutralForeground1)

            Spacer(minLength: 0)

            Button("Try Again", action: onRetry)
                .font(.odsBody2Strong)
                .foregroundStyle(Color.odsBrandForegroundTint)
                .buttonStyle(.plain)
                .hotspotTarget()
        }
    }

    private var visibleStreamingItems: [String] {
        guard !content.streamingStages.isEmpty else {
            return []
        }

        let index = min(
            max(streamingStage, 0),
            content.streamingStages.count - 1
        )
        return content.streamingStages[index]
    }

    private var collapsedStreamingText: some View {
        Text(visibleStreamingItems.joined(separator: " "))
            .odsBody2()
            .foregroundStyle(Color.odsNeutralForeground1)
            .lineLimit(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        cardBackground.opacity(0),
                        cardBackground
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 24)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .accessibilityLabel(visibleStreamingItems.joined(separator: " "))
    }

    private func summaryList(items: [OutlookCardSummaryItem]) -> some View {
        VStack(alignment: .leading, spacing: .odsSize40) {
            ForEach(items) { item in
                HStack(alignment: .top, spacing: .odsSize80) {
                    Text("•")
                        .font(.odsBody2)
                        .foregroundStyle(Color.odsNeutralForeground1)
                        .frame(height: 20, alignment: .top)
                        .accessibilityHidden(true)

                    summaryItem(item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    @ViewBuilder
    private func summaryItem(_ item: OutlookCardSummaryItem) -> some View {
        if let citation = item.citation {
            InlineCitationText(
                text: item.text,
                referenceCount: citation.references.count,
                tint: citationForeground,
                onOpen: {
                    onOpenCitation(citation.references)
                }
            )
            .hotspotTarget()
        } else {
            Text(item.text)
                .font(.odsBody2)
                .foregroundStyle(Color.odsNeutralForeground1)
        }
    }

    private func streamingSummaryList(items: [String]) -> some View {
        VStack(alignment: .leading, spacing: .odsSize40) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .firstTextBaseline, spacing: .odsSize80) {
                    Text("•")
                        .accessibilityHidden(true)

                    Text(item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.odsBody2)
                .foregroundStyle(Color.odsNeutralForeground1)
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func collapsedSummary(items: [OutlookCardSummaryItem]) -> some View {
        summaryList(items: items)
            .lineLimit(3)
            .frame(height: 60, alignment: .top)
            .clipped()
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        cardBackground.opacity(0),
                        cardBackground
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
    }

    private func actionPills(_ actions: [OutlookCardAction]) -> some View {
        FlowLayout(spacing: .odsSize80) {
            ForEach(actions) { action in
                Button {
                    onAction(action)
                } label: {
                    HStack(spacing: .odsSize40) {
                        actionLabel(action)

                        if let icon = action.icon {
                            Image(icon)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 16, height: 16)
                                .accessibilityHidden(true)
                        }
                    }
                    .foregroundStyle(actionForeground)
                    .padding(.horizontal, .odsSize120)
                    .frame(minHeight: 34)
                    .background(actionBackground)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: Metrics.pillRadius,
                            style: .continuous
                        )
                    )
                    .overlay {
                        if theme == .neutral {
                            RoundedRectangle(
                                cornerRadius: Metrics.pillRadius,
                                style: .continuous
                            )
                            .strokeBorder(Color.odsNeutralStroke1, lineWidth: 0.5)
                        }
                    }
                }
                .buttonStyle(.plain)
                .hotspotTarget()
                .accessibilityLabel(action.title)
            }
        }
    }

    private var actionForeground: Color {
        switch theme {
        case .brand:
            Color.odsBrandForegroundTint
        case .neutral:
            Color.odsNeutralStrokeAccessible
        }
    }

    private var citationForeground: Color {
        switch theme {
        case .brand:
            Color.odsBrandForegroundTint
        case .neutral:
            Color.odsNeutralForeground2
        }
    }

    private var actionBackground: Color {
        switch theme {
        case .brand:
            Color.odsBrandBackgroundTint1
        case .neutral:
            Color.odsNeutralBackground4
        }
    }

    @ViewBuilder
    private func actionLabel(_ action: OutlookCardAction) -> some View {
        if let prefix = action.emphasizedPrefix,
           action.title.hasPrefix(prefix) {
            HStack(spacing: 0) {
                Text(prefix)
                    .odsCaption1Strong()
                Text(String(action.title.dropFirst(prefix.count)))
                    .odsCaption1()
            }
        } else {
            Text(action.title)
                .odsCaption1()
        }
    }

    private var outputFooter: some View {
        HStack(spacing: .odsSize80) {
            HStack(spacing: .odsSize40) {
                Image(.shieldLock16Regular)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .accessibilityHidden(true)

                Text("AI-generated")
                    .odsCaption2()
            }
            .foregroundStyle(Color.odsNeutralForeground2)
            .accessibilityElement(children: .combine)

            Spacer(minLength: 0)

            Button(action: onOpenSources) {
                HStack(spacing: .odsSize40) {
                    Image(.link16Regular)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(sourcesForeground)

                    Text("Sources")
                        .odsCaption2()
                }
            }
            .accessibilityLabel("Open summary sources")
            .hotspotTarget()

            iconButton(.copy20Regular, label: "Copy summary", action: onCopy)
            iconButton(.thumbLike20Regular, label: "Helpful") {
                onFeedback(true)
            }
            iconButton(.thumbDislike20Regular, label: "Not helpful") {
                onFeedback(false)
            }
        }
        .foregroundStyle(Color.odsNeutralForeground2)
        .buttonStyle(.plain)
    }

    private var sourcesForeground: Color {
        switch theme {
        case .brand:
            Color.odsBrandForegroundTint
        case .neutral:
            Color.odsNeutralForeground2
        }
    }

    private var errorFooter: some View {
        HStack(spacing: .odsSize80) {
            Text(content.feedbackPrompt)
                .odsCaption2()
                .foregroundStyle(Color.odsNeutralForeground2)

            Spacer(minLength: 0)

            feedbackButtons
        }
    }

    private var feedbackButtons: some View {
        HStack(spacing: .odsSize40) {
            iconButton(.thumbLike20Regular, label: "Helpful") {
                onFeedback(true)
            }
            iconButton(.thumbDislike20Regular, label: "Not helpful") {
                onFeedback(false)
            }
        }
        .foregroundStyle(Color.odsNeutralForeground2)
        .buttonStyle(.plain)
    }

    private var actionOnlyFooter: some View {
        HStack {
            Spacer(minLength: 0)
            feedbackButtons
        }
    }

    private func iconButton(
        _ icon: OutlookIcon,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .frame(width: Metrics.iconButtonSize, height: Metrics.iconButtonSize)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(label)
        .hotspotTarget()
    }
}

private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let result = layout(
            subviews: subviews,
            availableWidth: proposal.width ?? .infinity
        )
        return CGSize(width: proposal.width ?? result.width, height: result.height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let result = layout(subviews: subviews, availableWidth: bounds.width)

        for index in subviews.indices {
            let point = result.points[index]
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(
        subviews: Subviews,
        availableWidth: CGFloat
    ) -> (points: [CGPoint], width: CGFloat, height: CGFloat) {
        var points: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var usedWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX > 0, currentX + size.width > availableWidth {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            points.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            usedWidth = max(usedWidth, currentX - spacing)
        }

        return (points, usedWidth, currentY + lineHeight)
    }
}
