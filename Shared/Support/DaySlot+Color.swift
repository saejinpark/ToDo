import SwiftUI

extension DaySlot {
    var color: Color {
        switch self {
        case .morning: .orange
        case .afternoon: .blue
        case .evening: .indigo
        }
    }
}

extension Optional where Wrapped == DaySlot {
    /// 시간 미정은 회색.
    var color: Color { self?.color ?? .gray }
    var title: String { self?.title ?? "시간 미정" }
}
