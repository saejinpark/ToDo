import SwiftUI
import SwiftData

struct ToDoDetail: View {
    let toDo: ToDo
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ToDo.creatAt) private var toDos: [ToDo]
    
    @State private var multiSelection = Set<UUID>()
    @State private var isEditing = true
    
    
    var body: some View {
        Group {
            if let toDo = toDos.first(where: { $0.id == toDo.id}) {
                List(toDo.steps.sorted { $0.order < $1.order }, selection: $multiSelection) { step in
                    Text(step.desc)
                }
                .listStyle(.plain)
                .navigationTitle(toDo.title)
                .onChange(of: multiSelection) { _, newValue in
                    toDo.steps.forEach { step in
                        step.isCompleted = newValue.contains(step.id)
                    }
                }
                .environment(\.editMode, .constant(isEditing ? .active : .inactive))
                .onAppear {
                    updateMultiSelection(for: toDo)
                }
                .onChange(of: toDo.steps) {
                    updateMultiSelection(for: toDo)
                }
            } else {
                ContentUnavailableView(label: {
                    Label("notSelected", systemImage: "square.dashed")
                })
            }
        }
    }
    
    private func updateMultiSelection(for toDo: ToDo) {
        multiSelection = Set(toDo.steps.filter { $0.isCompleted }.map { $0.id })
    }
}
