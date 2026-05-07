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
import SwiftUI

struct CopilotSheetOverlay: View {
    @Binding var isShowing: Bool

    @Environment(\.fluentTheme) private var fluentTheme: FluentTheme

    @State private var promptText: String = ""

    private let suggestions: [Suggestion] = [
        Suggestion(title: "Voice catch-up", iconSystemName: "waveform"),
        Suggestion(title: "What did I miss?", iconSystemName: nil),
        Suggestion(title: "What needs my reply?", iconSystemName: nil),
    ]

    private let sheetHeight: CGFloat = 168
    private let cornerRadius: CGFloat = 24
    private let animationDuration: Double = 0.25

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
            VStack(spacing: 12) {
                suggestionChipsRow
                inputBar
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(height: sheetHeight, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(fluentTheme.swiftUIColor(.background1))
                .ignoresSafeArea(edges: .bottom)
        )
        .offset(y: isShowing ? 0 : sheetHeight + 200)
        .allowsHitTesting(isShowing)
    }

    private var dragIndicator: some View {
        Capsule()
            .fill(fluentTheme.swiftUIColor(.foreground2).opacity(0.4))
            .frame(width: 36, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    private var suggestionChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions) { suggestion in
                    SuggestionChip(suggestion: suggestion)
                }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
                }
                .buttonStyle(.plain)

                FocusableTextField(
                    text: $promptText,
                    placeholder: "Ask Copilot",
                    shouldFocus: $isShowing
                )
                .frame(height: 24)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                Capsule().fill(fluentTheme.swiftUIColor(.background3))
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

private struct SuggestionChip: View {
    let suggestion: Suggestion

    @Environment(\.fluentTheme) private var fluentTheme: FluentTheme

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                if let icon = suggestion.iconSystemName {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(fluentTheme.swiftUIColor(.foreground1))
                }
                Text(suggestion.title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(fluentTheme.swiftUIColor(.foreground1))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(fluentTheme.swiftUIColor(.background3))
            )
            .overlay(
                /// `.strokeAlpha2` (10% inverting black/white) lands in a later FluentUI Apple
                /// release; 0.35.0 has no equivalent. `.foreground1` at 0.08 reproduces the
                /// original SwiftUI `Color.primary.opacity(0.08)` look while staying tokenized.
                Capsule().stroke(fluentTheme.swiftUIColor(.foreground1).opacity(0.08), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
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
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            self._text = text
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let current = textField.text, let textRange = Range(range, in: current) {
                text = current.replacingCharacters(in: textRange, with: string)
            }
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
