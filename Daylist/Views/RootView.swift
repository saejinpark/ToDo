import SwiftUI
import SwiftData

/// iPhone에서는 탭 바, iPad와 Mac에서는 사이드바로 바뀌는 뿌리 화면.
struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context
    @Query private var items: [TodoItem]

    private var todayCount: Int { items.filter { $0.isToday || $0.isOverdue }.count }

    var body: some View {
        @Bindable var appState = appState
        TabView(selection: $appState.tab) {
            Tab(AppTab.today.title, systemImage: AppTab.today.systemImage, value: .today) {
                NavigationStack { TodayView() }
            }
            .badge(todayCount)

            Tab(AppTab.inbox.title, systemImage: AppTab.inbox.systemImage, value: .inbox) {
                NavigationStack { InboxView() }
            }

            Tab(AppTab.history.title, systemImage: AppTab.history.systemImage, value: .history) {
                NavigationStack { HistoryView() }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .sheet(isPresented: $appState.isPresentingNewTask) {
            TaskEditor(
                item: nil,
                presetDate: appState.tab == .today ? .startOfToday : nil,
                presetSlot: appState.tab == .today ? DaySlot.current : nil
            )
        }
        .onAppear { SampleData.seedIfNeeded(in: context) }
    }
}
