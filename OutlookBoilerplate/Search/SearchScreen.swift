import OutlookBackdrop
import SwiftUI

private enum SearchCategory: String, CaseIterable, Identifiable {
    case mail = "Mail"
    case people = "People"
    case events = "Events"

    var id: Self { self }
}

private struct SearchPerson: Identifiable {
    let id = UUID()
    let initials: String
    let name: String
    let role: String
    let color: Color
}

private struct SearchEvent: Identifiable {
    let id = UUID()
    let day: String
    let title: String
    let details: String
    let isCanceled: Bool
}

struct SearchScreen: View {
    let onDismiss: () -> Void

    @State private var query = ""
    @State private var category: SearchCategory = .mail
    @State private var showingFilters = false
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            searchHeader

            switch category {
            case .mail:
                SearchMailResults(query: query, onShowFilters: { showingFilters = true })
            case .people:
                SearchPeopleResults(query: query)
            case .events:
                SearchEventResults(query: query)
            }
        }
        .background(Color.odsNeutralBackground1)
        .sheet(isPresented: $showingFilters) {
            SearchFilterSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            searchFocused = true
        }
    }

    private var searchHeader: some View {
        VStack(spacing: .odsSpacingVerticalS) {
            HStack(spacing: .odsSize120) {
                Button(action: onDismiss) {
                    Image(.arrowLeft24Regular)
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")

                TextField("Microsoft 365", text: $query)
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .font(.odsBody1)
                    .foregroundStyle(.white)
                    .tint(.white)

                Image(.appFolder24Regular)
                    .renderingMode(.template)
                    .foregroundStyle(.white)

                Image(.chevronDown16Regular)
                    .renderingMode(.template)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Color.odsControlSearchbarBackground1, in: Capsule())

            HStack(spacing: 2) {
                ForEach(SearchCategory.allCases) { tab in
                    Button {
                        category = tab
                    } label: {
                        HStack(spacing: .odsSpacingHorizontalXS) {
                            Text(tab.rawValue)
                                .font(.odsHeadlineStrong)

                            if tab == .mail {
                                Image(.chevronDown16Regular)
                                    .renderingMode(.template)
                            }
                        }
                        .foregroundStyle(category == tab ? Color.odsBrandForeground1 : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background {
                            if category == tab {
                                Capsule().fill(.white)
                            } else {
                                RoundedRectangle(cornerRadius: .odsSize40)
                                    .fill(Color.odsControlSearchbarBackground1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            if tab == .mail, category == .mail {
                                showingFilters = true
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.vertical, .odsSpacingVerticalS)
        .background(
            Color.odsControlNavBarBackground1
                .ignoresSafeArea(edges: .top)
        )
    }
}

private struct SearchMailResults: View {
    let query: String
    let onShowFilters: () -> Void

    private let suggestions = [
        ("Track emails", nil),
        ("Find recent file", nil),
        ("Your storylines update", "Elvia Atkins sent · 4:05 PM"),
        ("elementary school", nil),
        ("Elvia Atkins", "From: klarsson@outlook.com"),
        ("Design review notes", nil),
        ("Travel itinerary", nil),
    ]

    var body: some View {
        List {
            if query.isEmpty {
                Section {
                    RecentPeopleStrip()
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
            } else {
                Text("Results for \"\(query)\"")
                    .font(.odsCaption1Strong)
                    .foregroundStyle(Color.odsNeutralForeground2)
                    .listRowSeparator(.hidden)
            }

            ForEach(filteredSuggestions, id: \.0) { item in
                HStack(spacing: .odsSpacingHorizontalL) {
                    Image(item.0.localizedCaseInsensitiveContains("file") ? .folder24Regular : .search24Regular)
                        .renderingMode(.template)
                        .foregroundStyle(Color.odsBrandForeground1)
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.0)
                            .font(.odsBody1)
                            .foregroundStyle(Color.odsNeutralForeground1)

                        if let subtitle = item.1 {
                            Text(subtitle)
                                .font(.odsCaption1)
                                .foregroundStyle(Color.odsNeutralForeground2)
                        }
                    }
                }
                .padding(.vertical, .odsSize40)
            }

            Button("Search filters", action: onShowFilters)
                .foregroundStyle(Color.odsBrandForeground1)
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.interactively)
    }

    private var filteredSuggestions: [(String, String?)] {
        guard !query.isEmpty else { return suggestions }
        return suggestions.filter { $0.0.localizedCaseInsensitiveContains(query) }
    }
}

private struct RecentPeopleStrip: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .odsSpacingHorizontalL) {
                ForEach(Array(searchPeople.prefix(5))) { person in
                    VStack(spacing: .odsSize60) {
                        SearchInitialsAvatar(person: person, size: 54)
                        Text(person.name.components(separatedBy: " ").first ?? person.name)
                            .font(.odsCaption2)
                            .foregroundStyle(Color.odsNeutralForeground1)
                    }
                    .frame(width: 58)
                }
            }
            .padding(.horizontal, .odsSpacingHorizontalL)
            .padding(.vertical, 18)
        }
    }
}

private struct SearchPeopleResults: View {
    let query: String

    var body: some View {
        List(filteredPeople) { person in
            HStack(spacing: 14) {
                SearchInitialsAvatar(person: person, size: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(person.name)
                        .font(.odsBody1)
                        .foregroundStyle(Color.odsNeutralForeground1)
                    Text(person.role)
                        .font(.odsCaption1)
                        .foregroundStyle(Color.odsNeutralForeground2)
                }
            }
            .padding(.vertical, .odsSize40)
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.interactively)
    }

    private var filteredPeople: [SearchPerson] {
        guard !query.isEmpty else { return searchPeople }
        return searchPeople.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.role.localizedCaseInsensitiveContains(query)
        }
    }
}

private struct SearchEventResults: View {
    let query: String

    var body: some View {
        List {
            Text("JUNE 2023")
                .font(.odsCaption1Strong)
                .foregroundStyle(Color.odsNeutralForeground3)

            ForEach(filteredEvents) { event in
                HStack(alignment: .top, spacing: .odsSpacingHorizontalL) {
                    Text(event.day)
                        .font(.odsHeadline)
                        .multilineTextAlignment(.center)
                        .frame(width: 48)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.odsBody1)
                            .foregroundStyle(Color.odsNeutralForeground1)
                        Text(event.details)
                            .font(.odsBody2)
                            .foregroundStyle(Color.odsNeutralForeground2)
                    }

                    Spacer()

                    Circle()
                        .fill(event.isCanceled ? Color.red : Color.odsStatusSuccessForeground2)
                        .frame(width: 10, height: 10)
                        .padding(.top, .odsSize60)
                }
                .padding(.vertical, .odsSize40)
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.interactively)
    }

    private var filteredEvents: [SearchEvent] {
        guard !query.isEmpty else { return searchEvents }
        return searchEvents.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
}

private struct SearchInitialsAvatar: View {
    let person: SearchPerson
    let size: CGFloat

    var body: some View {
        Text(person.initials)
            .font(.system(size: size / 3, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(person.color, in: Circle())
    }
}

private struct SearchFilterSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var includeDeleted = true
    @State private var hasAttachments = true
    @State private var folder = "All Folders"

    private let folders = [
        "All Folders",
        "Inbox",
        "Drafts",
        "Archive",
        "Sent",
        "Snoozed",
        "Deleted",
        "Junk",
        "Conversation History",
    ]

    var body: some View {
        NavigationStack {
            List {
                Toggle("Include Deleted Items", isOn: $includeDeleted)
                Toggle("Has Attachments", isOn: $hasAttachments)

                Section("Folder") {
                    ForEach(folders, id: \.self) { item in
                        Button {
                            folder = item
                        } label: {
                            HStack(spacing: .odsSpacingHorizontalL) {
                                Image(icon(for: item))
                                    .renderingMode(.template)
                                    .foregroundStyle(Color.odsNeutralForeground2)
                                Text(item)
                                    .foregroundStyle(Color.odsNeutralForeground1)
                                Spacer()
                                if folder == item {
                                    Text("✓")
                                        .foregroundStyle(Color.odsBrandForeground1)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { dismiss() }
                }
            }
        }
    }

    private func icon(for folder: String) -> OutlookIcon {
        switch folder {
        case "Archive": .archive24Regular
        case "Deleted": .delete24Regular
        case "Inbox": .mailInbox24Regular
        default: .folder24Regular
        }
    }
}

private let searchPeople = [
    SearchPerson(
        initials: "DP",
        name: "Daisy Phillips",
        role: "Product Designer",
        color: Color(red: 196 / 255, green: 95 / 255, blue: 19 / 255)
    ),
    SearchPerson(
        initials: "CB",
        name: "Celeste Burton",
        role: "Engineering Manager",
        color: Color(red: 0, green: 24 / 255, blue: 143 / 255)
    ),
    SearchPerson(
        initials: "AB",
        name: "Amanda Brady",
        role: "Program Manager",
        color: Color(red: 0, green: 120 / 255, blue: 212 / 255)
    ),
    SearchPerson(
        initials: "CN",
        name: "Chris Naidoo",
        role: "Software Engineer",
        color: Color(red: 73 / 255, green: 130 / 255, blue: 5 / 255)
    ),
    SearchPerson(
        initials: "EA",
        name: "Elvia Atkins",
        role: "elvia.atkins@outlook.com",
        color: Color(red: 135 / 255, green: 100 / 255, blue: 184 / 255)
    ),
    SearchPerson(
        initials: "KB",
        name: "Kadji Bell",
        role: "Marketing Lead",
        color: Color(red: 3 / 255, green: 131 / 255, blue: 135 / 255)
    ),
    SearchPerson(
        initials: "JR",
        name: "Joshua Reyes",
        role: "Finance Analyst",
        color: Color(red: 202 / 255, green: 80 / 255, blue: 16 / 255)
    ),
]

private let searchEvents = [
    SearchEvent(day: "15\nWed", title: "Canceled: Stand-up", details: "12:00 PM - 1:00 PM", isCanceled: true),
    SearchEvent(day: "29\nWed", title: "Team Lunch", details: "12:00 PM - 1:00 PM", isCanceled: false),
    SearchEvent(day: "", title: "Team Lunch", details: "12:00 PM - 1:00 PM · Fabrikam", isCanceled: false),
    SearchEvent(day: "17\nWed", title: "Team Lunch", details: "12:00 PM - 1:00 PM · Fabrikam", isCanceled: false),
]
