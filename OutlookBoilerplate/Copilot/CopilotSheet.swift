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

    /// Suggestion prompts shown in the empty / zero-query state. Production loads these
    /// dynamically from `ZeroQueryMessage`; we hard-code three to match the reference.
    /// "Voice catch-up" carries a waveform icon to mirror production.
    private let suggestions: [Suggestion] = [
        Suggestion(title: "Voice catch-up", iconSystemName: "waveform"),
        Suggestion(title: "What did I miss?", iconSystemName: nil),
        Suggestion(title: "What needs my reply?", iconSystemName: nil),
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
        // Known limitation: production raises the keyboard automatically on sheet open
        // (input is focused immediately). SwiftUI's @FocusState in a `.sheet` with
        // `.presentationDetents` silently drops focus changes during sheet presentation
        // — tested with `.onAppear` + DispatchQueue (0.25s, 0.6s, 0.8s delays) and
        // `.task` + Task.sleep, neither works reliably. Designers tap the field to
        // focus, which is standard iOS interaction.
    }

    private var suggestionChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions) { suggestion in
                    SuggestionChip(suggestion: suggestion)
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

    /// Voice / listening button. Production shows `MicListeningButton` with a real-time
    /// waveform when listening (file: `VoiceInputView.swift` line 80, `WaveformView`).
    /// We render the listening-state visual statically using SF Symbol `waveform` — closer
    /// to the production reference than the static mic asset alone.
    private var voiceButton: some View {
        Button(action: {}) {
            Image(systemName: "waveform")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(Color(uiColor: GlobalTokens.brandColor(.comm80)))
                )
        }
        .buttonStyle(.plain)
    }
}

private struct Suggestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let iconSystemName: String?
}

/// Suggestion chip — production uses `CopilotUIKit.ShortcutPill` (SwiftUI custom button
/// with FluentUI tokens). We replicate the visual: rounded capsule with subtle border,
/// optional leading icon. Per the production reference screenshot.
private struct SuggestionChip: View {
    let suggestion: Suggestion

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                if let icon = suggestion.iconSystemName {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.primary)
                }
                Text(suggestion.title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            .overlay(
                Capsule()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
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
