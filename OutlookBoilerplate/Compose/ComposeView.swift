//
//  ComposeView.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Shared/SharedMail/DAB/ComposeButton.swift
//      (production Compose FAB definition — `compose28Regular`, telemetry button)
//    - client-cocoa/app-ios/Modules/Mail/MailCompose/Compose/Other/ComposeVC.swift line 236
//      (production compose presentation — `isModalInPresentation = true`, full-screen modal)
//    - client-cocoa/app-ios/Modules/Mail/MailCompose/Compose/Components/GUI/Root/ComposeRootVC.swift
//      (production root compose VC — composes header + editor + toolbar children)
//    - client-cocoa/app-ios/Modules/Mail/MailCompose/Compose/Components/GUI/NavigationItem/ComposeNavigationItemController.swift
//      lines 87, 154-167, 208 (production header — close button, AvatarTwoLinesTitleView with
//      "New Message" + sender email subtitle, send24Filled icon)
//    - client-cocoa/app-ios/Modules/Mail/MailCompose/Compose/Components/GUI/Header/Recipients/ComposeHeaderRecipientsView.swift
//      lines 65-68 (production To field — TokenizableTextField with chip support;
//      we use SwiftUI TextField for visual-only Phase 1)
//    - client-cocoa/app-ios/Modules/Mail/MailCompose/Compose/Components/GUI/Header/Subject/ComposeHeaderSubjectView.swift
//      lines 23, 26 (production Subject field + SecurityLabelPinsButton shield icon)
//    - client-cocoa/app-ios/Modules/Mail/MailCompose/Compose/Components/GUI/Editor/ComposeEditorVC.swift line 52
//      (production body — OLMEditorView wrapping WKWebView for HTML; we use SwiftUI TextEditor)
//

import FluentUI
import OutlookBackdrop
import SwiftUI

struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var toField: String = ""
    @State private var subjectField: String = ""
    @State private var bodyField: String = ""
    @FocusState private var bodyFocused: Bool

    private let senderEmail = "junhwancho@microsoft.com"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                    toRow
                    Divider()
                    subjectRow
                    Divider()
                    bodyEditor
                }
            }
            .background(Color.odsNeutralBackground1)
            // Float the toolbar at the bottom safe area inset so the scroll
            // content extends UNDER it. With `.liquidGlassEffect()`, this lets
            // body text blur through the toolbar (matches dev build).
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ComposeToolbar()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(.dismiss24Regular)
                            .renderingMode(.template)
                            .foregroundStyle(Color.odsNeutralForeground1)
                    }
                    .hotspotTarget()
                }
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("New Message")
                            .font(.odsHeadlineStrong)
                            .foregroundStyle(Color.odsNeutralForeground1)
                        Text(senderEmail)
                            .font(.odsCaption2)
                            .foregroundStyle(Color.odsNeutralForeground2)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // Per Phase 1 spec: Send dismisses the sheet (no real send).
                        dismiss()
                    }) {
                        Image(.send24Regular)
                            .renderingMode(.template)
                            .foregroundStyle(Color.odsNeutralForeground3)
                    }
                    .hotspotTarget()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var toRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("To:")
                .font(.odsBody2)
                .foregroundStyle(Color.odsNeutralForeground2)
            TextField("", text: $toField)
                .font(.odsBody2)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Spacer()
            Image(.chevronDown16Regular)
                .renderingMode(.template)
                .foregroundStyle(Color.odsNeutralForeground2)
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.vertical, 14)
    }

    private var subjectRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Subject:")
                .font(.odsBody2)
                .foregroundStyle(Color.odsNeutralForeground2)
            TextField("", text: $subjectField)
                .font(.odsBody2)
            Spacer()
            /// Production renders `SecurityLabelPinsButton` (encryption / sensitivity label)
            /// here. Visual-only in Phase 1.
            Image(.shield16Filled)
                .renderingMode(.template)
                .foregroundStyle(ODSPrimitive.brandCommBlue80)
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.vertical, 14)
    }

    private var bodyEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $bodyField)
                .focused($bodyFocused)
                .font(.odsBody2)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, .odsSize120)
                .padding(.vertical, .odsSize120)
                .frame(minHeight: 240)

            if bodyField.isEmpty && !bodyFocused {
                VStack(alignment: .leading, spacing: .odsSize160) {
                    bodyPlaceholder
                    signatureLine
                }
                .padding(.horizontal, .odsSpacingHorizontalL)
                .padding(.vertical, .odsSize200)
                .allowsHitTesting(false)
            }
        }
    }

    private var bodyPlaceholder: some View {
        HStack(spacing: .odsSpacingVerticalSNudge) {
            Text("Start typing or")
                .foregroundStyle(Color.odsNeutralForeground2)
            Image(.chatSparkle24Regular)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundStyle(ODSPrimitive.brandCommBlue80)
            Text("Help me write")
                .foregroundStyle(ODSPrimitive.brandCommBlue80)
        }
        .font(.odsBody2)
    }

    /// Mail signature line — pre-filled "Get Outlook for iOS" link that mirrors
    /// the device's default Outlook mobile signature. Visual-only in Phase 1.
    private var signatureLine: some View {
        HStack(spacing: 0) {
            Text("Get ")
                .foregroundStyle(Color.odsNeutralForeground1)
            Text("Outlook for iOS")
                .foregroundStyle(ODSPrimitive.brandCommBlue80)
                .underline()
        }
        .font(.odsBody2)
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            ComposeView()
        }
        .fluentTheme(FluentTheme.shared)
}
