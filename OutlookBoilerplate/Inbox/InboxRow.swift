//
//  InboxRow.swift
//  OutlookBoilerplate
//
//  Real-source references:
//    - client-cocoa/app-ios/Modules/Mail/MailMessageList/SnippetCell/SnippetCell.swift
//      (production inbox row, UITableViewCell — confirms 40pt avatar, body/subheadline/footnote font roles)
//    - client-cocoa/app-ios/Modules/Mail/MailMessageList/SnippetCell/SnippetCellStyle.swift
//      (spacing constants — avatar diameter, vertical padding)
//    - fluentui-apple/Sources/FluentUI_iOS/Components/Avatar/Avatar.swift line 111
//      (FluentUI's SwiftUI Avatar, used for the leading avatar)
//    - fluentui-apple/Sources/FluentUI_iOS/Components/List/ListItem.swift line 30
//      (FluentUI's SwiftUI ListItem, used for row composition)
//    - fluentui-apple/Demos/FluentUIDemo_iOS/.../ListItemDemoController_SwiftUI.swift line 153
//      (canonical ListItem usage with leadingContent / trailingContent ViewBuilders)
//

import FluentUI
import SwiftUI

struct InboxRow: View {
    let thread: InboxThread
    let onTap: () -> Void

    @Environment(\.fluentTheme) private var fluentTheme: FluentTheme

    var body: some View {
        ListItem(
            title: thread.sender,
            subtitle: thread.subject,
            footer: thread.preview,
            leadingContent: {
                HStack(spacing: 12) {
                    unreadDot
                    Avatar(
                        style: .default,
                        size: .size40,
                        primaryText: thread.sender
                    )
                }
            },
            trailingContent: {
                Text(thread.timeStamp)
                    .font(.subheadline)
                    .foregroundStyle(fluentTheme.swiftUIColor(.foreground2))
            },
            action: onTap
        )
        .titleLineLimit(1)
        .subtitleLineLimit(1)
        .footerLineLimit(2)
    }

    private var unreadDot: some View {
        Circle()
            .fill(thread.isUnread ? fluentTheme.swiftUIColor(.brandForeground1) : Color.clear)
            .frame(width: 8, height: 8)
    }
}

#Preview {
    VStack(spacing: 0) {
        InboxRow(thread: sampleThreads[0], onTap: {})
        InboxRow(thread: sampleThreads[5], onTap: {})
    }
    .fluentTheme(FluentTheme.shared)
}
