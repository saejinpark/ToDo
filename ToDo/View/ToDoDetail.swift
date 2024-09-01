import SwiftUI

struct ToDoDetail: View {
    var toDo: ToDo
    
    @State private var multiSelection = Set<UUID>()
    @State private var isEditing = true
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List(toDo.steps.sorted{left, right in left.order < right.order}, selection: $multiSelection) { step in
            Text(step.desc)
        }
        .listStyle(.plain)
        .navigationTitle(toDo.title)
        .toolbar {
            ToolbarItem {
                Button {
                    toDo.steps.forEach { step in
                        step.isCompleted = multiSelection.contains(step.id)
                    }
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Done")
                }
            }
        }
        .environment(\.editMode, Binding(
            get: { isEditing ? .active : .inactive },
            set: {
                if $0 == .active {
                    isEditing = true
                } else {
                    isEditing = false
                }
            }
        ))
        .onAppear {
            for item in toDo.steps {
                if !item.isCompleted { continue }
                multiSelection.insert(item.id)
            }
        }
        
        
    }
}
