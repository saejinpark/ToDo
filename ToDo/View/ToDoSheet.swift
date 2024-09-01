import SwiftUI

struct IdxAndOrder: Hashable {
    let index: Int
    let order: Int
    
    init(index: Int, order: Int) {
        self.index = index
        self.order = order
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
        hasher.combine(order)
    }
}

struct ToDoSheet: View {
    @Bindable var toDo: ToDo
    @Binding var isNew: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                Section("Title") {
                    TextField("EnterTitle", text: $toDo.title)
                }
                Section("Steps") {
                    let idxAndOrderArr = toDo.steps.enumerated().map { index, element in IdxAndOrder(index: index, order: element.order)}
                    let sortedIdxOrderArr = idxAndOrderArr.sorted { left, right in left.order < right.order}
                    ForEach(sortedIdxOrderArr, id: \.self) { idxAndOrder in
                        if idxAndOrder.index < toDo.steps.count {
                            NavigationLink {
                                StepEditor(step: $toDo.steps[idxAndOrder.index])
                            } label: {
                                Text(toDo.steps[idxAndOrder.index].desc)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteContent(at: idxAndOrder.index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    Button {
                        let newStep = Step(order: toDo.steps.count)
                        toDo.steps.append(newStep)
                        newStep.toDo = toDo
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "plus")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "New" : toDo.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let orderedSteps = toDo.steps.enumerated().map{ index, element in
                            element.order = index
                            return element
                        }
                        toDo.steps = orderedSteps
                        isNew = false
                        dismiss()
                    }
                    .disabled(toDo.title == "" || toDo.steps.count == 0)
                }
                ToolbarItem(placement: .cancellationAction) {
                    if isNew {
                        Button("Cancel") {
                            modelContext.delete(toDo)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    func deleteContent(at index: Int) {
        let temp = toDo.steps[index].order
        toDo.steps.remove(at: index)
        toDo.steps.forEach { step in
            if step.order > temp {
                step.order -= 1
            }
        }
    }
}

