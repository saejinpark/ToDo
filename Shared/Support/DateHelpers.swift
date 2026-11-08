import Foundation

extension Date {
    static var startOfToday: Date { Calendar.current.startOfDay(for: .now) }
    static var startOfTomorrow: Date { startOfToday.adding(days: 1) }

    var startOfDay: Date { Calendar.current.startOfDay(for: self) }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// 오늘 기준 며칠 차이인지. 어제는 -1.
    var daysFromToday: Int {
        Calendar.current.dateComponents([.day], from: Date.startOfToday, to: startOfDay).day ?? 0
    }

    /// 오늘 · 내일 · 어제 · 11월 4일 (수)
    var dayLabel: String {
        switch daysFromToday {
        case 0: return "오늘"
        case 1: return "내일"
        case -1: return "어제"
        default: return KoreanFormat.shortDay.string(from: self)
        }
    }

    /// 오늘 · 내일 · 어제 · 11월 4일 수요일
    var longDayLabel: String {
        switch daysFromToday {
        case 0: return "오늘"
        case 1: return "내일"
        case -1: return "어제"
        default: return KoreanFormat.longDay.string(from: self)
        }
    }

    /// 11월 4일 수요일 (항상 날짜로)
    var fullDayLabel: String { KoreanFormat.longDay.string(from: self) }

    /// 오후 3:53
    var timeLabel: String { KoreanFormat.time.string(from: self) }
}

enum KoreanFormat {
    private static func make(_ template: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.setLocalizedDateFormatFromTemplate(template)
        return f
    }

    static let shortDay = make("MMMd EEE")
    static let longDay = make("MMMd EEEE")
    static let time = make("jm")
}
