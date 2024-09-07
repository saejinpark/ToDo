//
//  DoneList.swift
//  ToDo
//
//  Created by 박세진 on 8/18/24.
//

import SwiftUI
import SwiftData

struct DoneList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ToDo.creatAt) private var toDos: [ToDo]
    
    @State private var selectedToDo: ToDo?
    @State private var isNew = false
    @State private var searchText = ""
    
    var filteredToDos: [ToDo] {
        let clearToDos = toDos.filter(isDone)
        
        if searchText.isEmpty {
            return clearToDos
        } else {
            return clearToDos.filter {
                $0.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredToDos) { toDo in
                    NavigationLink {
                        ToDoDetail(toDo: toDo)
                    } label: {
                        Text(toDo.title)
                    }
                    .swipeActions(edge: .trailing) {
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
                        Button {
                            for step in toDo.steps {
                                step.isCompleted = false
                            }
                        } label: {
                            Label("Reload",systemImage: "arrow.3.trianglepath")
                        }.tint(.gray)
                    }
                }.onDelete(perform: deleteItems)
                if filteredToDos.isEmpty {
                    ContentUnavailableView(label: {
                        Label("EmptyToDoList", systemImage: "tray.fill")
                    })
                }
            }
            .navigationTitle("Done")
            .searchable(text: $searchText, prompt: "SearchTodos")

            .sheet(item: $selectedToDo) { toDo in
                ToDoSheet(toDo: toDo, isNew: $isNew)
            }
            .interactiveDismissDisabled(true)
        }
    }
    
    private func isDone(toDo: ToDo) -> Bool {
        for step in toDo.steps {
            if !step.isCompleted {
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
}

#Preview {
    DoneList()
}
