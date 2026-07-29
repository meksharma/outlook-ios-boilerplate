import SwiftUI

enum CalendarDisplayMode: String, CaseIterable, Identifiable {
    case agenda = "Agenda"
    case day = "Day"
    case threeDay = "3 Day"
    case month = "Month"

    var id: Self { self }
}

enum CalendarEventColor {
    case blue
    case purple
    case green

    var background: Color {
        switch self {
        case .blue: Color(red: 214 / 255, green: 231 / 255, blue: 250 / 255)
        case .purple: Color(red: 234 / 255, green: 216 / 255, blue: 242 / 255)
        case .green: Color(red: 205 / 255, green: 234 / 255, blue: 216 / 255)
        }
    }

    var foreground: Color {
        switch self {
        case .blue: Color(red: 23 / 255, green: 70 / 255, blue: 111 / 255)
        case .purple: Color(red: 92 / 255, green: 45 / 255, blue: 111 / 255)
        case .green: Color(red: 16 / 255, green: 124 / 255, blue: 65 / 255)
        }
    }
}

struct CalendarGridEvent: Identifiable {
    let id = UUID()
    let title: String
    let day: Int
    let startHour: Double
    let durationHours: Double
    let location: String
    let color: CalendarEventColor
    let isTentative: Bool

    init(
        _ title: String,
        day: Int,
        startHour: Double,
        durationHours: Double,
        location: String = "",
        color: CalendarEventColor = .blue,
        isTentative: Bool = false
    ) {
        self.title = title
        self.day = day
        self.startHour = startHour
        self.durationHours = durationHours
        self.location = location
        self.color = color
        self.isTentative = isTentative
    }
}

struct CalendarAgendaEvent: Identifiable {
    let id = UUID()
    let time: String
    let duration: String
    let title: String
    let location: String
    let color: CalendarEventColor
}

enum CalendarSampleData {
    static let gridEvents = [
        CalendarGridEvent("Intern Meet & Greet", day: 0, startHour: 11, durationHours: 0.75),
        CalendarGridEvent(
            "Team Lunch",
            day: 0,
            startHour: 12,
            durationHours: 1,
            location: "Lucerne Publishing"
        ),
        CalendarGridEvent(
            "Review with Northwind",
            day: 0,
            startHour: 15,
            durationHours: 1.5,
            location: "Conference Room B987"
        ),
        CalendarGridEvent(
            "Happy Hour",
            day: 0,
            startHour: 17,
            durationHours: 1,
            location: "Fabrikam",
            color: .purple
        ),
        CalendarGridEvent(
            "1/1 Carlos",
            day: 1,
            startHour: 12,
            durationHours: 1,
            location: "Soho",
            color: .purple
        ),
        CalendarGridEvent(
            "All Hands",
            day: 1,
            startHour: 14,
            durationHours: 1,
            location: "Online Meeting",
            isTentative: true
        ),
        CalendarGridEvent(
            "Lunch",
            day: 2,
            startHour: 12,
            durationHours: 1,
            location: "Cafe 9",
            color: .purple
        ),
        CalendarGridEvent(
            "Design Review",
            day: 2,
            startHour: 13,
            durationHours: 1,
            location: "Conf Room"
        ),
        CalendarGridEvent(
            "Focus Time",
            day: 2,
            startHour: 15,
            durationHours: 3,
            color: .purple
        ),
    ]

    static let agendaEvents = [
        CalendarAgendaEvent(
            time: "ALL DAY",
            duration: "3d",
            title: "Miguel Garcia - Out of Office",
            location: "",
            color: .green
        ),
        CalendarAgendaEvent(
            time: "ALL DAY",
            duration: "1d",
            title: "Celeste's Birthday",
            location: "",
            color: .purple
        ),
        CalendarAgendaEvent(
            time: "11:00 AM",
            duration: "30m",
            title: "Intern Meet & Greet",
            location: "",
            color: .blue
        ),
        CalendarAgendaEvent(
            time: "12:00 PM",
            duration: "1h",
            title: "Team Lunch",
            location: "Lucerne Publishing",
            color: .blue
        ),
        CalendarAgendaEvent(
            time: "3:00 PM",
            duration: "1h",
            title: "Review with Northwind",
            location: "Conference Room B987",
            color: .blue
        ),
    ]
}
