//
//  CopilotSheet.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Shared/SharedIntelligence/Chat/CopilotChatManager.swift line 224
//      (production sheet entry — copilotButtonTapped → showHalfSheetChat)
//    - client-cocoa/app-ios/Pods/CopilotChatKit/.../MiniChatV2/MiniChatSheetViewController.swift
//      (production sheet container — custom UIKit BottomSheetController. Half-sheet at
//      0.38 height ratio, drag handle, drag-down dismiss. We substitute SwiftUI's native
//      .sheet + .presentationDetents which gives the same UX with a tenth of the code.)
//    - client-cocoa/app-ios/Pods/CopilotUIKit/.../ZeroQuery/ZeroQueryView.swift
//      + .../Shared/ShortcutPill.swift
//      (production "zero query" empty state — suggestion pills + Ask Copilot input)
//    - client-cocoa/app-ios/Pods/CopilotUIKit/.../InputView/InputView.swift line 186
//      (production input bar — TextField + Send + Mic. Single-line variant.)
//    - client-cocoa/app-ios/Pods/CopilotUIKit/.../InputView/VoiceInput/VoiceInputView.swift
//      (production voice input — uses MicAsset.pdf, vendored)
//
//  Vendored assets:
//    - MicIcon.imageset (from client-cocoa MainAppOnly.xcassets/20x20/ios-settings-microphone-20x20.imageset)
//    - CopilotIcon.imageset (already vendored in M2)
//
//  Per Phase 1 spec: typing in the input works (SwiftUI free), submit / chip taps no-op,
//  drag-down dismiss works (SwiftUI free).
//

import FluentUI
import SwiftUI

struct CopilotSheet: View {
    @State private var promptText: String = ""
    @FocusState private var inputFocused: Bool

    private let suggestions: [String] = [
        "What did I miss?",
        "What needs my reply?",
        "Unblock me",
    ]

    var body: some View {
        VStack(spacing: 0) {
            suggestionChipsRow
            Spacer()
            inputBar
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color(uiColor: .systemBackground))
    }

    private var suggestionChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    SuggestionChip(title: suggestion)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                TextField("Ask Copilot", text: $promptText)
                    .focused($inputFocused)
                    .submitLabel(.send)
                    .onSubmit { /* no-op in Phase 1 */ }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color(uiColor: .secondarySystemBackground))
            )

            voiceButton
        }
        .padding(.horizontal, 16)
    }

    private var voiceButton: some View {
        Button(action: {}) {
            Image("MicIcon")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(Color(uiColor: GlobalTokens.brandColor(.comm80)))
                )
        }
        .buttonStyle(.plain)
    }
}

/// Suggestion chip — production uses `CopilotUIKit.ShortcutPill` (a SwiftUI custom button
/// with FluentUI tokens). We replicate the visual minimally with a Capsule background.
private struct SuggestionChip: View {
    let title: String

    var body: some View {
        Button(action: {}) {
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            CopilotSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .fluentTheme(FluentTheme.shared)
}
