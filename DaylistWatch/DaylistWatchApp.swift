import SwiftUI
import SwiftData

@main
struct DaylistWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchRootView()
        }
        .modelContainer(for: TodoItem.self)
    }
}
