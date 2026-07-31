//
//  CopilotSheetOverlayBeta.swift
//  OutlookBoilerplate
//
//  Beta variant of the Copilot chat sheet. Ported from Figma
//  "ios26 — Mail and chrome updates" node 3060:31513 ([Bebop] Sheet).
//  Selected via the App Variant toggle in the Designer Tools sheet
//  (appVariant == "beta"); production keeps `CopilotSheetOverlay`.
//
//  Structural deltas from prod:
//    - Header line "How I can help you today?" (Title 3)
//    - Vertical suggested-action pills (prod scrolls them horizontally)
//    - Redesigned input bar: 44pt-radius field + mic + blue "End" voice pill
//    - Floating card with asymmetric corners (34pt top / 58pt bottom)
//
//  Figma raw alphas (rgba(0,0,0,0.12) handle, rgba(0,0,0,0.06) input field)
//  are mode-locked to Light. Re-expressed as `Color.primary.opacity(...)` so
//  they invert correctly under the in-app Dark Mode toggle.
//

import FluentUI
import OutlookBackdrop
import SwiftUI

struct CopilotSheetOverlayBeta: View {
    @Binding var isShowing: Bool

    @State private var promptText: String = ""
    @State private var workIQResponse: WorkIQResponseState = .idle
    @AppStorage("workIQEnabled") private var workIQEnabled: Bool = false

    private let suggestions: [String] = [
        "Triage top emails",
        "Polish writing",
        "Recap meeting",
    ]

    private var sheetHeight: CGFloat {
        workIQResponse == .idle ? 355 : 600
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            scrim
            sheetCard
        }
        // Extend past the home-indicator safe area so the sheet's 6px bottom
        // margin is measured from the physical screen edge, not above it.
        .ignoresSafeArea(.container, edges: .bottom)
    }

    // Beta floats the sheet over an undimmed inbox (per Figma) — no scrim
    // darkening. A transparent tap-catcher preserves tap-outside-to-dismiss.
    private var scrim: some View {
        Color.clear
            .contentShape(Rectangle())
            .allowsHitTesting(isShowing)
            .ignoresSafeArea()
            .onTapGesture { isShowing = false }
    }

    private var sheetShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 34,
            bottomLeadingRadius: 58,
            bottomTrailingRadius: 58,
            topTrailingRadius: 34
        )
    }

    private var sheetCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            dragIndicator
                .frame(maxWidth: .infinity)

            Text("How I can help you today?")
                .font(.odsTitle3)
                .tracking(-0.45)
                .foregroundStyle(Color.odsNeutralForeground1)
                .padding(.top, 18)
                .padding(.bottom, 24)
                .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(suggestions, id: \.self) { title in
                    suggestionPill(title)
                }
            }
            .padding(.horizontal, 16)

            WorkIQResponseView(state: workIQResponse)
                .padding(.horizontal, 16)
                .padding(.top, workIQResponse == .idle ? 0 : 12)

            // 12px gap to the input bar — matches the inter-pill spacing.
            inputBar
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        // Heavily tinted glass — a near-opaque neutral surface with the iOS 26
        // glass material supplying only the edge sheen/refraction. The neutral
        // fill dominates so the sheet reads almost solid (not see-through).
        .background(
            Color.clear.glassEffect(
                .regular.tint(Color.odsNeutralBackground1.opacity(0.95)),
                in: sheetShape
            )
        )
        .clipShape(sheetShape)
        // Figma drop shadow: X0 Y8, Blur 40, Black 12%. SwiftUI radius ≈ half
        // the Figma blur (no spread param; spread is 0 anyway).
        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
        .padding(.horizontal, 6)
        .padding(.bottom, 6)
        .offset(y: isShowing ? 0 : sheetHeight + 200)
        .allowsHitTesting(isShowing)
    }

    private var dragIndicator: some View {
        Capsule()
            .fill(Color.primary.opacity(0.12))
            .frame(width: 36, height: 4)
            .padding(.top, 4)
    }

    private func suggestionPill(_ title: String) -> some View {
        Button {
            submitToWorkIQ(title)
        } label: {
            Text(title)
                .odsBody2Strong()
                .foregroundStyle(Color.odsNeutralForeground1)
                .padding(.leading, 14)
                .padding(.trailing, 20)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.odsNeutralBackground5))
        }
        .buttonStyle(.plain)
        .hotspotTarget(isEnabled: workIQEnabled)
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 2) {
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color.odsNeutralForeground2)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            TextField("Ask Copilot", text: $promptText)
                .font(.system(size: 17))
                .tracking(-0.43)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .submitLabel(.send)
                .onSubmit {
                    submitToWorkIQ(promptText)
                }

            trailingActions
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.primary.opacity(0.06))
        )
    }

    private var trailingActions: some View {
        HStack(spacing: 8) {
            Button(action: {}) {
                Image(systemName: "mic")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(Color.odsNeutralForeground1)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            // Blue voice button — Device-EQ icon only (label dropped). Circular
            // brand-blue affordance. Decorative in the boilerplate.
            Button(action: {}) {
                Image(systemName: "waveform")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.odsBrandBackground1))
            }
            .buttonStyle(.plain)
        }
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

#Preview {
    ZStack {
        Color.gray
        CopilotSheetOverlayBeta(isShowing: .constant(true))
    }
    .fluentTheme(FluentTheme.shared)
}
