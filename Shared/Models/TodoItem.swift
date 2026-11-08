import Foundation
import SwiftData

/// 하루를 나누는 시간대. 오늘 화면의 구간이자 할 일의 "언제쯤" 힌트.
enum DaySlot: String, CaseIterable, Identifiable, Codable {
    case morning, afternoon, evening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: "오전"
        case .afternoon: "오후"
        case .evening: "저녁"
        }
    }

    var hint: String {
        switch self {
        case .morning: "12시 전까지"
        case .afternoon: "12시부터 6시"
        case .evening: "6시 이후"
        }
    }

    /// 지금 시각이 속한 구간.
    static var current: DaySlot {
        let hour = Calendar.current.component(.hour, from: .now)
        return hour < 12 ? .morning : hour < 18 ? .afternoon : .evening
    }
}

@Model
final class TodoItem {
    var title: String = ""
    var notes: String = ""
    /// 자정 기준 날짜. nil이면 받은함.
    var date: Date?
    var slotRaw: String?
    var isDone: Bool = false
    var doneAt: Date?
    var createdAt: Date = Date.now

    init(
        title: String,
        notes: String = "",
        date: Date? = nil,
        slot: DaySlot? = nil,
        isDone: Bool = false,
        doneAt: Date? = nil,
        createdAt: Date = .now
    ) {
        self.title = title
        self.notes = notes
        self.date = date?.startOfDay
        self.slotRaw = slot?.rawValue
        self.isDone = isDone
        self.doneAt = doneAt
        self.createdAt = createdAt
    }

    var slot: DaySlot? {
        get { slotRaw.flatMap(DaySlot.init(rawValue:)) }
        set { slotRaw = newValue?.rawValue }
    }

    var isInbox: Bool { !isDone && date == nil }
    var isToday: Bool { !isDone && date?.startOfDay == Date.startOfToday }
    var isOverdue: Bool {
        guard let date, !isDone else { return false }
        return date.startOfDay < Date.startOfToday
    }
    var isUpcoming: Bool {
        guard let date, !isDone else { return false }
        return date.startOfDay > Date.startOfToday
    }

    func setDone(_ done: Bool) {
        isDone = done
        doneAt = done ? .now : nil
    }

    /// 날짜를 옮긴다. 받은함으로 보내면 시간대도 지운다.
    func move(to newDate: Date?, keepingSlot: Bool = true) {
        date = newDate?.startOfDay
        if newDate == nil {
            slot = nil
        } else if !keepingSlot || slot == nil {
            slot = DaySlot.current
        }
    }
}
