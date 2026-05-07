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
import SwiftUI

struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.fluentTheme) private var fluentTheme: FluentTheme

    @State private var toField: String = ""
    @State private var subjectField: String = ""
    @State private var bodyField: String = ""
    @FocusState private var bodyFocused: Bool

    private let senderEmail = "junhwancho@microsoft.com"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        toRow
                        Divider()
                        subjectRow
                        Divider()
                        bodyEditor
                    }
                }

                ComposeToolbar()
            }
            .background(fluentTheme.swiftUIColor(.background1))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(fluentTheme.swiftUIColor(.foreground1))
                    }
                }
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Avatar(style: .default, size: .size24, primaryText: senderEmail)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("New Message")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(fluentTheme.swiftUIColor(.foreground1))
                            Text(senderEmail)
                                .font(.system(size: 12))
                                .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // Per Phase 1 spec: Send dismisses the sheet (no real send).
                        dismiss()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color(uiColor: GlobalTokens.brandColor(.comm80)))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var toRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("To:")
                .font(.system(size: 16))
                .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
            TextField("", text: $toField)
                .font(.system(size: 16))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var subjectRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Subject:")
                .font(.system(size: 16))
                .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
            TextField("", text: $subjectField)
                .font(.system(size: 16))
            Spacer()
            /// Production renders `SecurityLabelPinsButton` (encryption / sensitivity label)
            /// here. Visual-only in Phase 1.
            Image(systemName: "shield.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color(uiColor: GlobalTokens.brandColor(.comm80)))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var bodyEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $bodyField)
                .focused($bodyFocused)
                .font(.system(size: 16))
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(minHeight: 240)

            if bodyField.isEmpty && !bodyFocused {
                bodyPlaceholder
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .allowsHitTesting(false)
            }
        }
    }

    private var bodyPlaceholder: some View {
        HStack(spacing: 6) {
            Text("Start typing or")
                .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
            Image("CopilotIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
            Text("Help me write")
                .foregroundStyle(Color(uiColor: GlobalTokens.brandColor(.comm80)))
        }
        .font(.system(size: 16))
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            ComposeView()
        }
        .fluentTheme(FluentTheme.shared)
}
