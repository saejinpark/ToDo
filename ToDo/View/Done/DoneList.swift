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
    @State private var searchText = ""
    
    @State var selectedToDo: ToDo?
    
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
        NavigationSplitView {
            List(filteredToDos) { toDo in
                NavigationLink {
                    ToDoDetail(toDo: toDo)
                } label: {
                    Label(toDo.title, systemImage: toDo.category.systemImage)
                        .font(.headline)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        for step in toDo.steps {
                            step.isCompleted = false
                        }
                    } label: {
                        Label("Reload",systemImage: "arrow.3.trianglepath")
                    }.tint(.gray)
                }
            }
            .navigationTitle("Done")
            .searchable(text: $searchText, prompt: "SearchTodos")
            .interactiveDismissDisabled(true)
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
    }
    
    private func isDone(toDo: ToDo) -> Bool {
        for step in toDo.steps {
            if !step.isCompleted {
                return false
            }
        }
        return true
    }
    
}

#Preview {
    DoneList()
}
