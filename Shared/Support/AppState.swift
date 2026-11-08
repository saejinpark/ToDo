import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case today, inbox, history

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: "오늘"
        case .inbox: "받은함"
        case .history: "기록"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "sun.max"
        case .inbox: "tray"
        case .history: "clock.arrow.circlepath"
        }
    }
}

/// 화면 전환과 새 할 일 시트처럼 메뉴 명령에서도 건드려야 하는 상태.
@Observable
final class AppState {
    var tab: AppTab = .today
    var isPresentingNewTask = false
}
