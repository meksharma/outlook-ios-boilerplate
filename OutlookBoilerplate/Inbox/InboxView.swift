//
//  InboxView.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Modules/Mail/MailMessageList/
//      (production Inbox composes a header + table view + DAB-managed floating actions)
//

import FluentUI
import SwiftUI

struct InboxView: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                InboxHeader()
                threadList
            }
            InboxFloatingActions()
                .padding(.bottom, 8)
        }
        .background(Color(uiColor: .systemBackground))
    }

    private var threadList: some View {
        FluentList {
            FluentListSection {
                ForEach(sampleThreads) { thread in
                    InboxRow(thread: thread)
                }
            }
        }
        .fluentListStyle(.plain)
    }
}

#Preview {
    InboxView()
        .fluentTheme(FluentTheme.shared)
}
