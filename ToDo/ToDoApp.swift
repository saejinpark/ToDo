import SwiftUI
import SwiftData

@main
struct ToDoApp: App {
    @State private var selection: Tab = .toDo
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ToDo.self,
            Step.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selection) {
                ToDoList()
                    .tabItem {
                        Label("ToDo", systemImage: "checklist.unchecked")
                    }
                    .tag(Tab.toDo)
                DoingList()
                    .tabItem {
                        Label("Doing", systemImage: "checklist")
                    }
                    .tag(Tab.doing)
                DoneList()
                    .tabItem {
                        Label("Done", systemImage: "checklist.checked")
                    }
                    .tag(Tab.done)
                
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
