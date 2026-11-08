import SwiftUI
import SwiftData

@main
struct DaylistApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
        }
        .modelContainer(for: TodoItem.self)
        #if os(macOS)
        .defaultSize(width: 1_000, height: 700)
        #endif
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("새로운 할 일") { appState.isPresentingNewTask = true }
                    .keyboardShortcut("n", modifiers: .command)
            }
            CommandGroup(after: .sidebar) {
                Divider()
                ForEach(Array(AppTab.allCases.enumerated()), id: \.element) { index, tab in
                    Button(tab.title) { appState.tab = tab }
                        .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command)
                }
            }
        }
    }
}
