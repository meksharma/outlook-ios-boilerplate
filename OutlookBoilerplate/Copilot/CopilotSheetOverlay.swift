//
//  CopilotSheetOverlay.swift
//  OutlookBoilerplate
//
//  Custom bottom sheet that mirrors production's `MiniChatSheetViewController`
//  behavior in SwiftUI. Production drops SwiftUI's `.sheet(isPresented:)` modal API
//  in favor of `addChild` + `addSubview` + `CADisplayLinkAnimator` so the sheet
//  animation and keyboard rise on the same RunLoop tick — keyboard appears in the
//  same beat as the sheet, not a second later.
//
//  Real-source references:
//    - client-cocoa/app-ios/Pods/CopilotChatKit/.../CopilotMiniBottomSheetManagerV2.swift
//      lines 132-179: production NOT-modal presentation via addChild + addSubview;
//      DispatchQueue.main.async after layoutIfNeeded triggers the animation
//    - client-cocoa/app-ios/Pods/CopilotChatKit/.../MiniChatSheetViewController.swift
//      line 77-82: animation duration = 0.25s (NOT 0.4s)
//      line 1361-1407: content-aware sheet height (chips + input + keyboard)
//      line 42-75: corner radius = 36pt when nav bar hidden
//    - client-cocoa/app-ios/Pods/CopilotChatKit/.../CopilotMiniChatViewModelV2.swift
//      lines 95-159: keyboard height tracked via Combine publisher (NOT
//      UIKeyboardWillShow notification); sheet auto-resizes reactively
//
//  Why we drop SwiftUI's `.sheet`: its modal presentation introduces a layout
//  pass that runs *after* the slide animation completes, which is when SwiftUI
//  finally processes `@FocusState` changes. Net: keyboard ~1s after sheet.
//  Custom overlay + offset slide + UIKit becomeFirstResponder() runs everything
//  on the same RunLoop tick, matching production.
//

import FluentUI
import OutlookBackdrop
import SwiftUI

struct CopilotSheetOverlay: View {
    @Binding var isShowing: Bool

    @State private var promptText: String = ""
    @State private var workIQResponse: WorkIQResponseState = .idle
    @AppStorage("workIQEnabled") private var workIQEnabled: Bool = false

    private let suggestions: [Suggestion] = [
        Suggestion(title: "Voice catch-up", iconSystemName: "waveform"),
        Suggestion(title: "What did I miss?", iconSystemName: nil),
        Suggestion(title: "What needs my reply?", iconSystemName: nil),
    ]

    private let cornerRadius: CGFloat = 24
    private let animationDuration: Double = 0.25

    private var sheetHeight: CGFloat {
        workIQResponse == .idle ? 168 : 380
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            scrim
            sheetCard
        }
    }

    private var scrim: some View {
        Color.black
            .opacity(isShowing ? 0.4 : 0)
            .allowsHitTesting(isShowing)
            .ignoresSafeArea()
            .onTapGesture { isShowing = false }
    }

    private var sheetCard: some View {
        VStack(spacing: 0) {
            dragIndicator
            VStack(spacing: .odsSize120) {
                suggestionChipsRow
                inputBar
                WorkIQResponseView(state: workIQResponse)
            }
            .padding(.horizontal, .odsSpacingHorizontalL)
            .padding(.bottom, .odsSize120)
        }
        .frame(height: sheetHeight, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(
            Color.clear
                .glassEffectCompat(in: RoundedRectangle(cornerRadius: cornerRadius))
                .ignoresSafeArea(edges: .bottom)
        )
        .offset(y: isShowing ? 0 : sheetHeight + 200)
        .allowsHitTesting(isShowing)
    }

    private var dragIndicator: some View {
        Capsule()
            .fill(Color.odsNeutralForeground2.opacity(0.4))
            .frame(width: 36, height: 5)
            .padding(.top, .odsSpacingVerticalS)
            .padding(.bottom, .odsSize40)
    }

    private var suggestionChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .odsSpacingHorizontalS) {
                ForEach(suggestions) { suggestion in
                    SuggestionChip(suggestion: suggestion, isEnabled: workIQEnabled) {
                        submitToWorkIQ(suggestion.title)
                    }
                }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: .odsSize120) {
            HStack(spacing: .odsSpacingHorizontalS) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(Color.odsNeutralForeground2)
                }
                .buttonStyle(.plain)

                FocusableTextField(
                    text: $promptText,
                    placeholder: "Ask Copilot",
                    shouldFocus: $isShowing,
                    onSubmit: submitToWorkIQ
                )
                .frame(height: .odsSize240)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, .odsSize120)
            .background(
                Capsule().fill(Color.odsNeutralBackground3)
            )

            voiceButton
        }
    }

    private var voiceButton: some View {
        Button(action: {}) {
            Image(systemName: "waveform")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(ODSPrimitive.brandCommBlue80)
                )
        }
        .buttonStyle(.plain)
    }

    private func submitToWorkIQ(_ question: String) {
        let trimmedQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard workIQEnabled, !trimmedQuestion.isEmpty else { return }

        workIQResponse = .loading
        Task {
            do {
                let answer = try await WorkIQClient().ask(trimmedQuestion)
                workIQResponse = .answer(answer)
            } catch {
                workIQResponse = .failure(
                    "Work IQ is unavailable. Start `node Tools/workiq_bridge.js` on your Mac, then try again.\n\n\(error.localizedDescription)"
                )
            }
        }
    }
}

private struct Suggestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let iconSystemName: String?
}

private struct SuggestionChip: View {
    let suggestion: Suggestion
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: .odsSpacingHorizontalS) {
                if let icon = suggestion.iconSystemName {
                    Image(systemName: icon)
                        .font(.odsBody2)
                        .foregroundStyle(Color.odsNeutralForeground1)
                }
                Text(suggestion.title)
                    .font(.odsBody2)
                    .foregroundStyle(Color.odsNeutralForeground1)
            }
            .padding(.horizontal, .odsSpacingHorizontalL)
            .padding(.vertical, .odsSpacingVerticalMNudge)
            .background(
                Capsule().fill(Color.odsNeutralBackground3)
            )
            .overlay(
                /// `.strokeAlpha2` (10% inverting black/white) lands in a later FluentUI Apple
                /// release; 0.35.0 has no equivalent. `.foreground1` at 0.08 reproduces the
                /// original SwiftUI `Color.primary.opacity(0.08)` look while staying tokenized.
                Capsule().stroke(Color.odsNeutralForeground1.opacity(0.08), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .hotspotTarget(isEnabled: isEnabled)
    }
}

/// Bridges UITextField focus state to a SwiftUI Binding<Bool>. When the binding
/// flips true, the field calls `becomeFirstResponder()`. When it flips false, the
/// field calls `resignFirstResponder()`. SwiftUI's `updateUIView` runs on the
/// same RunLoop tick that triggered the change — keyboard rises in parallel with
/// the slide animation, matching production.
private struct FocusableTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    @Binding var shouldFocus: Bool
    let onSubmit: (String) -> Void

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.delegate = context.coordinator
        field.borderStyle = .none
        field.font = .systemFont(ofSize: 16)
        field.returnKeyType = .send
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.onSubmit = onSubmit
        if uiView.text != text {
            uiView.text = text
        }
        if shouldFocus && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !shouldFocus && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var onSubmit: (String) -> Void

        init(text: Binding<String>, onSubmit: @escaping (String) -> Void) {
            self._text = text
            self.onSubmit = onSubmit
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let current = textField.text, let textRange = Range(range, in: current) {
                text = current.replacingCharacters(in: textRange, with: string)
            }
            return true
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onSubmit(textField.text ?? "")
            textField.resignFirstResponder()
            return true
        }
    }
}

#Preview {
    ZStack {
        Color.gray
        CopilotSheetOverlay(isShowing: .constant(true))
    }
    .fluentTheme(FluentTheme.shared)
}
