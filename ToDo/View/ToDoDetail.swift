import SwiftUI
import SwiftData

struct ToDoDetail: View {
    let toDo: ToDo
    let activeTab: Tab
    let editFunc: (() -> Void)?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @Query(sort: \ToDo.creatAt) private var toDos: [ToDo]
    
    @State private var multiSelection = Set<UUID>()
    @State private var isEditing = true
    
    init(toDo: ToDo, activeTab: Tab, editFunc: (() -> Void)? = nil) {
        self.toDo = toDo
        self.activeTab = activeTab
        self.editFunc = editFunc
    }
    
    var body: some View {
        Group {
            if let toDo = toDos.first(where: { $0.id == toDo.id}) {
                List(toDo.steps.sorted { $0.order < $1.order }, selection: $multiSelection) { step in
                    Text(step.desc)
                }
                .listStyle(.plain)
                .navigationTitle(toDo.title)
                .toolbar {
                    ToolbarItemGroup {
                        if activeTab == .done {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                                for step in toDo.steps {
                                    step.isCompleted = false
                                }
                            } label: {
                                Label("Reload",systemImage: "arrow.3.trianglepath")
                            }
                        }
                        if activeTab == .toDo {
                            if let editFunc = editFunc {
                                Button {
                                    editFunc()
                                } label: {
                                    Label("Edit",systemImage: "rectangle.and.pencil.and.ellipsis")
                                }
                            }
                            
                            Button {
                                modelContext.delete(toDo)
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                }
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
