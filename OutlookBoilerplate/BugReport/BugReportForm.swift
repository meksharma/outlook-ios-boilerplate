//
//  BugReportForm.swift
//  OutlookBoilerplate
//
//  The shared bug-report form, opened by BOTH the shake gesture and the
//  "Report a Bug" row in the Designer Tools sheet. Shows the auto-captured
//  screenshot + context, takes a title and description, then on submit saves
//  the report locally and hands it to the iOS share sheet.
//

import SwiftUI

struct BugReportForm: View {
    /// Context captured at trigger time (screen, device, app state).
    let context: BugReportContext
    /// Screenshot captured at trigger time. Optional — the designer can also
    /// clear it before submitting.
    let screenshot: UIImage?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var includeScreenshot: Bool = true

    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                if let screenshot, includeScreenshot {
                    Section("Screenshot") {
                        Image(uiImage: screenshot)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                        Toggle("Attach screenshot", isOn: $includeScreenshot)
                    }
                } else if screenshot != nil {
                    Section("Screenshot") {
                        Toggle("Attach screenshot", isOn: $includeScreenshot)
                    }
                }

                Section("What went wrong?") {
                    TextField("Short title", text: $title)
                    TextField(
                        "Describe what happened and what you expected",
                        text: $details,
                        axis: .vertical
                    )
                    .lineLimit(4...10)
                }

                Section("Captured context") {
                    contextRow("Screen", context.screen)
                    contextRow("Device", context.deviceModel)
                    contextRow("iOS", context.osVersion)
                    contextRow("App", "\(context.appVersion) (\(context.buildNumber))")
                    contextRow("Variant", context.appVariant)
                    contextRow("Data source", context.dataMode)
                    contextRow("Appearance", context.colorScheme)
                }
            }
            .navigationTitle("Report a Bug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit", action: submit)
                        .disabled(!canSubmit)
                }
            }
        }
    }

    @ViewBuilder
    private func contextRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.callout)
    }

    private func submit() {
        let attachedScreenshot = includeScreenshot ? screenshot : nil

        let report = BugReport(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            details: details,
            context: context
        )

        let saved = (try? BugReportStore.shared.save(report, screenshot: attachedScreenshot)) ?? report

        var items: [Any] = [saved.markdown]
        if includeScreenshot, let attachedScreenshot {
            items.append(attachedScreenshot)
        }

        // Dismiss the form first, then present the share sheet from the root
        // via UIKit. Presenting the share sheet while the form sheet is still
        // up (or as a nested SwiftUI `.sheet`) renders it empty/black on device.
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            SharePresenter.present(items: items)
        }
    }
}
