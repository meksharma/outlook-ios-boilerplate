import FluentUI
import OutlookBackdrop
import SwiftUI

struct CalendarScreen: View {
    let onSearchTap: () -> Void

    @State private var displayMode: CalendarDisplayMode = .threeDay
    @State private var selectedDayIndex = 0

    var body: some View {
        VStack(spacing: 0) {
            CalendarHeader(
                displayMode: $displayMode,
                selectedDayIndex: $selectedDayIndex,
                onSearchTap: onSearchTap
            )

            switch displayMode {
            case .agenda:
                CalendarAgendaView()
            case .day:
                CalendarTimeGrid(dayCount: 1, selectedDayIndex: selectedDayIndex)
            case .threeDay:
                CalendarTimeGrid(dayCount: 3, selectedDayIndex: selectedDayIndex)
            case .month:
                CalendarMonthPlaceholder()
            }
        }
        .background(Color.odsNeutralBackground1)
    }
}

private struct CalendarHeader: View {
    @Binding var displayMode: CalendarDisplayMode
    @Binding var selectedDayIndex: Int
    let onSearchTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            titleRow
            dayPicker
        }
        .background(
            Color.odsControlNavBarBackground1
                .ignoresSafeArea(edges: .top)
        )
    }

    private var titleRow: some View {
        HStack(spacing: .odsSize120) {
            Avatar(
                style: .default,
                size: .size32,
                primaryText: "Jay Cho"
            )

            Text("July")
                .odsTitle1()
                .foregroundStyle(.white)

            Spacer()
            viewModeMenu

            Button(action: onSearchTap) {
                Image(.search24Regular)
                    .renderingMode(.template)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .hotspotTarget()
        }
        .frame(height: 48)
        .padding(.horizontal, .odsSpacingHorizontalL)
    }

    private var viewModeMenu: some View {
        Menu {
            ForEach(CalendarDisplayMode.allCases) { mode in
                Button(mode == displayMode ? "✓ \(mode.rawValue)" : mode.rawValue) {
                    displayMode = mode
                }
            }
        } label: {
            HStack(spacing: .odsSpacingHorizontalXS) {
                Image(.calendarEmpty24Regular)
                    .renderingMode(.template)
                Image(.chevronDown16Regular)
                    .renderingMode(.template)
            }
            .foregroundStyle(.white)
        }
        .hotspotTarget()
    }

    private var dayPicker: some View {
        HStack(spacing: .odsSpacingHorizontalS) {
            ForEach(dayLabels.indices, id: \.self) { index in
                dayButton(index)
            }
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.vertical, .odsSpacingVerticalS)
    }

    private func dayButton(_ index: Int) -> some View {
        Button {
            selectedDayIndex = index
        } label: {
            Text(dayLabels[index])
                .odsBody1Strong()
                .foregroundStyle(index == selectedDayIndex ? Color.odsBrandForeground1 : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background {
                    if index == selectedDayIndex {
                        Capsule().fill(.white)
                    }
                }
        }
        .buttonStyle(.plain)
        .hotspotTarget()
    }

    private var dayLabels: [String] {
        ["Mon 27", "Tue 28", "Wed 29"]
    }
}

private struct CalendarTimeGrid: View {
    let dayCount: Int
    let selectedDayIndex: Int

    private let startHour = 10
    private let endHour = 19
    private let hourHeight: CGFloat = 72
    private let gutterWidth: CGFloat = 56

    var body: some View {
        ScrollView {
            weatherRow
            allDayRows

            GeometryReader { proxy in
                let contentWidth = max(0, proxy.size.width - gutterWidth)
                let columnWidth = contentWidth / CGFloat(dayCount)

                ZStack(alignment: .topLeading) {
                    gridLines(contentWidth: contentWidth, columnWidth: columnWidth)
                    timeLabels

                    ForEach(visibleEvents) { event in
                        eventBlock(event, columnWidth: columnWidth)
                    }

                    nowIndicator(contentWidth: contentWidth)
                }
            }
            .frame(height: CGFloat(endHour - startHour) * hourHeight)

            Color.clear.frame(height: 96)
        }
    }

    private var visibleEvents: [CalendarGridEvent] {
        if dayCount == 1 {
            return CalendarSampleData.gridEvents
                .filter { $0.day == selectedDayIndex }
                .map {
                    CalendarGridEvent(
                        $0.title,
                        day: 0,
                        startHour: $0.startHour,
                        durationHours: $0.durationHours,
                        location: $0.location,
                        color: $0.color,
                        isTentative: $0.isTentative
                    )
                }
        }
        return CalendarSampleData.gridEvents
    }

    private var weatherRow: some View {
        HStack(spacing: 0) {
            Text("All Day")
                .font(.odsCaption2)
                .foregroundStyle(Color.odsNeutralForeground3)
                .frame(width: gutterWidth)

            ForEach(0..<dayCount, id: \.self) { index in
                Text(["☀ 75° / 63°", "☁ 75° / 63°", "☂ 75° / 63°"][index])
                    .font(.odsCaption1)
                    .foregroundStyle(Color.odsNeutralForeground2)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 48)
    }

    private var allDayRows: some View {
        VStack(alignment: .leading, spacing: .odsSize40) {
            allDayEvent("Miguel Garcia - Out of Office", width: nil)
            allDayEvent("Celeste's Birthday", width: dayCount == 1 ? nil : 118)
        }
        .padding(.leading, gutterWidth)
        .padding(.trailing, .odsSize40)
        .padding(.bottom, .odsSpacingVerticalS)
    }

    private func allDayEvent(_ title: String, width: CGFloat?) -> some View {
        Text(title)
            .font(.odsCaption1)
            .foregroundStyle(CalendarEventColor.green.foreground)
            .lineLimit(1)
            .padding(.horizontal, .odsSpacingHorizontalS)
            .frame(width: width, height: 24, alignment: .leading)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
            .background(CalendarEventColor.green.background, in: RoundedRectangle(cornerRadius: .odsSize40))
    }

    private func gridLines(contentWidth: CGFloat, columnWidth: CGFloat) -> some View {
        Canvas { context, size in
            let stroke = StrokeStyle(lineWidth: 0.5)
            let color = Color.odsNeutralStroke2

            for hour in 0...(endHour - startHour) {
                let y = CGFloat(hour) * hourHeight
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: gutterWidth, y: y))
                        path.addLine(to: CGPoint(x: gutterWidth + contentWidth, y: y))
                    },
                    with: .color(color),
                    style: stroke
                )
            }

            for day in 0...dayCount {
                let x = gutterWidth + CGFloat(day) * columnWidth
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    },
                    with: .color(color),
                    style: stroke
                )
            }
        }
    }

    private var timeLabels: some View {
        VStack(spacing: 0) {
            ForEach(startHour..<endHour, id: \.self) { hour in
                Text(hourLabel(hour))
                    .font(.odsCaption2)
                    .foregroundStyle(Color.odsNeutralForeground3)
                    .frame(width: gutterWidth - 8, height: hourHeight, alignment: .topTrailing)
                    .padding(.top, 2)
            }
        }
    }

    private func eventBlock(_ event: CalendarGridEvent, columnWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.title)
                .font(.odsCaption2.weight(.semibold))
                .lineLimit(2)

            if !event.location.isEmpty {
                Text(event.location)
                    .font(.system(size: 11))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(event.color.foreground)
        .padding(.odsSize60)
        .frame(
            width: max(0, columnWidth - 4),
            height: max(28, CGFloat(event.durationHours) * hourHeight - 2),
            alignment: .topLeading
        )
        .background {
            RoundedRectangle(cornerRadius: .odsSize40)
                .fill(event.isTentative ? Color.clear : event.color.background)
                .overlay {
                    if event.isTentative {
                        RoundedRectangle(cornerRadius: .odsSize40)
                            .stroke(event.color.foreground)
                    }
                }
        }
        .offset(
            x: gutterWidth + CGFloat(event.day) * columnWidth + 2,
            y: CGFloat(event.startHour - Double(startHour)) * hourHeight + 1
        )
    }

    private func nowIndicator(contentWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            Circle()
                .fill(Color.odsBrandForeground1)
                .frame(width: 10, height: 10)
            Rectangle()
                .fill(Color.odsBrandForeground1)
                .frame(width: contentWidth - 10, height: 2)
        }
        .offset(x: gutterWidth - 5, y: hourHeight * 0.47)
    }

    private func hourLabel(_ hour: Int) -> String {
        switch hour {
        case 12: "12 pm"
        case 13...23: "\(hour - 12) pm"
        default: "\(hour) am"
        }
    }
}

private struct CalendarAgendaView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                weekStrip
                agendaHeader

                ForEach(CalendarSampleData.agendaEvents) { event in
                    agendaRow(event)
                }

                Color.clear.frame(height: 96)
            }
        }
    }

    private var weekStrip: some View {
        HStack {
            ForEach(["S\n26", "M\n27", "T\n28", "W\n29", "T\n30", "F\n31", "S\n1"], id: \.self) { day in
                Text(day)
                    .font(.odsCaption1Strong)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(day == "W\n29" ? .white : Color.odsNeutralForeground2)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background {
                        if day == "W\n29" {
                            Circle().fill(Color.odsBrandForeground1)
                        }
                    }
            }
        }
        .padding(.vertical, .odsSpacingVerticalS)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var agendaHeader: some View {
        HStack {
            Text("TODAY · WEDNESDAY, JULY 29")
            Spacer()
            Text("☂ 75° / 63°")
        }
        .font(.odsCaption1Strong)
        .foregroundStyle(Color.odsBrandForeground1)
        .padding(.horizontal, .odsSpacingHorizontalL)
        .frame(height: 48)
        .background(Color.odsBrandBackgroundTint2)
    }

    private func agendaRow(_ event: CalendarAgendaEvent) -> some View {
        HStack(alignment: .top, spacing: .odsSpacingHorizontalL) {
            VStack(alignment: .leading, spacing: 2) {
                Text(event.time)
                    .font(.odsCaption1)
                    .foregroundStyle(Color.odsNeutralForeground1)
                Text(event.duration)
                    .font(.odsCaption1)
                    .foregroundStyle(Color.odsNeutralForeground3)
            }
            .frame(width: 76, alignment: .leading)

            Circle()
                .fill(event.color.foreground)
                .frame(width: 12, height: 12)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: .odsSize40) {
                Text(event.title)
                    .font(.odsHeadlineStrong)
                    .foregroundStyle(Color.odsNeutralForeground1)

                if !event.location.isEmpty {
                    Text(event.location)
                        .font(.odsCaption1)
                        .foregroundStyle(Color.odsNeutralForeground2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, .odsSpacingHorizontalL)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Divider().padding(.leading, 120)
        }
    }
}

private struct CalendarMonthPlaceholder: View {
    var body: some View {
        VStack(spacing: .odsSize160) {
            Image(.calendarEmpty24Regular)
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(Color.odsNeutralForeground3)
                .frame(width: 44, height: 44)

            Text("Month view")
                .font(.odsTitle3)
                .foregroundStyle(Color.odsNeutralForeground2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
