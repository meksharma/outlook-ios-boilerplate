import SwiftUI
import OutlookBackdrop

struct OutlookReferencesSheet: View {
    let model: OutlookReferencesSheetModel
    let onDismiss: () -> Void
    let isExpanded: Bool

    var body: some View {
        sheet
        .accessibilityAddTraits(.isModal)
    }

    private var sheet: some View {
        VStack(spacing: 0) {
            Text(isExpanded ? "Sources" : "References")
                .font(isExpanded ? .odsTitle2 : .odsCaption1Strong)
                .foregroundStyle(Color.odsNeutralForeground3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, .odsSize200)
                .padding(.top, isExpanded ? .odsSize160 : .odsSize60)
                .padding(.bottom, .odsSize60)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(model.references) { reference in
                        referenceRow(reference)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.odsNeutralBackground1)
        .accessibilityAction(.escape, onDismiss)
    }

    private func referenceRow(
        _ reference: OutlookCardReference
    ) -> some View {
        Button(action: onDismiss) {
            HStack(alignment: .top, spacing: .odsSize120) {
                referenceIcon(reference.kind)

                VStack(alignment: .leading, spacing: .odsSize20) {
                    Text(reference.title)
                        .odsBody2Strong()
                        .foregroundStyle(Color.odsNeutralForeground1)
                        .lineLimit(1)

                    Text(reference.excerpt)
                        .odsCaption1()
                        .foregroundStyle(Color.odsNeutralForeground2)
                        .lineLimit(1)

                    if let date = reference.date {
                        Text(date)
                            .odsCaption1()
                            .foregroundStyle(Color.odsNeutralForeground2)
                            .lineLimit(1)
                    }
                }

                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, .odsSize200)
            .padding(.vertical, .odsSize120)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            [reference.title, reference.excerpt, reference.date]
                .compactMap { $0 }
                .joined(separator: ", ")
        )
    }

    @ViewBuilder
    private func referenceIcon(
        _ kind: OutlookCardReferenceKind
    ) -> some View {
        switch kind {
        case .mail:
            Image(.mail20Regular)
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 13)
                .frame(width: 20, height: 20)
        case .chat:
            Image(.chat20Regular)
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 16)
                .frame(width: 20, height: 20)
        }
    }
}

struct OutlookReferencesSheetPresentation: View {
    let model: OutlookReferencesSheetModel
    let onDismiss: () -> Void

    @State private var selectedDetent: PresentationDetent
    private let compactDetent: PresentationDetent

    init(
        model: OutlookReferencesSheetModel,
        onDismiss: @escaping () -> Void
    ) {
        self.model = model
        self.onDismiss = onDismiss

        let visibleReferenceCount = min(max(model.references.count, 1), 2)
        let height = 76 + CGFloat(visibleReferenceCount) * 84
        let detent = PresentationDetent.height(height)
        compactDetent = detent
        _selectedDetent = State(initialValue: detent)
    }

    var body: some View {
        OutlookReferencesSheet(
            model: model,
            onDismiss: onDismiss,
            isExpanded: selectedDetent == .large
        )
        .presentationDetents(
            [compactDetent, .large],
            selection: $selectedDetent
        )
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(34)
        .presentationContentInteraction(.resizes)
    }
}
