import SwiftUI
import SwiftData

struct ToDoList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ToDo.creatAt) private var toDos: [ToDo]
    
    @State private var selectedToDo: ToDo?
    @State private var isNew = false
    @State private var searchText = ""
    
    var filteredToDos: [ToDo] {
        let clearToDos = toDos.filter(isToDo)
        
        if searchText.isEmpty {
            return clearToDos
        } else {
            return clearToDos.filter {
                $0.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(filteredToDos) { toDo in
                    NavigationLink {
                        ToDoDetail(toDo: toDo, activeTab: .toDo, editFunc: { selectedToDo = toDo })
                    } label: {
                        Label(toDo.title, systemImage: toDo.category.systemImage)
                            .font(.headline)
                    }
                    #if os(iOS)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            deleteItems(indexSet: IndexSet(integer: filteredToDos.firstIndex(of: toDo)!))
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }.tint(.red)
                        
                        Button {
                            selectedToDo = toDo
                        } label: {
                            Label("Edit",systemImage: "rectangle.and.pencil.and.ellipsis")
                        }.tint(.blue)
                    }
                    #endif
                    
                }
                if filteredToDos.isEmpty {
                    ContentUnavailableView(label: {
                        Label("EmptyToDoList", systemImage: "tray.fill")
                    })
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    .listRowBackground(Color(UIColor.systemGray6))
                }
                
            }
            .navigationTitle("ToDo")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "SearchTodos")
            .toolbar {
                ToolbarItem {
                    Button(action: addToDo) {
                        Label("Add", systemImage: "plus")
                            .labelStyle(.iconOnly)
                            .accessibilityLabel(Text("Add"))
                    }
                }
            }
            .sheet(item: $selectedToDo) { toDo in
                ToDoSheet(toDo: toDo, isNew: $isNew)
                    .interactiveDismissDisabled(true)
            }
            .overlay {
                if filteredToDos.isEmpty {
                    ContentUnavailableView(label: {
                        Label("EmptyToDoList", systemImage: "tray.fill")
                    })
                }
            }
        } detail: {
            ContentUnavailableView(label: {
                Label("notSelected", systemImage: "square.dashed")
            })
        }
        .onAppear {
            cleanupLegacyData()
        }
    }

    private func isToDo(toDo: ToDo) -> Bool {
        for step in toDo.steps {
            if step.isCompleted {
                return false
            }
        }
        return true
    }

    private func addToDo() {
        withAnimation {
            let newItem = ToDo(title: "")
            isNew = true
            modelContext.insert(newItem)
            selectedToDo = newItem
        }
    }

    private func deleteItems(indexSet: IndexSet) {
        withAnimation {
            for index in indexSet {
                modelContext.delete(filteredToDos[index])
            }
        }
    }

    private func cleanupLegacyData() {
        let legacyToDos = toDos.filter { $0.title.isEmpty || $0.steps.isEmpty }
        for toDo in legacyToDos {
            modelContext.delete(toDo)
        }
        try? modelContext.save()
    }
}

#Preview {
    ToDoList()
        .modelContainer(SampleData.shared.modelContainer)
}
