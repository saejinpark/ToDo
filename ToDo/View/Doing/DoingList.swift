//
//  DoingList.swift
//  ToDo
//
//  Created by 박세진 on 8/18/24.
//

import SwiftUI
import SwiftData

struct DoingList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ToDo.creatAt) private var toDos: [ToDo]
    @State private var searchText = ""
    
    var filteredToDos: [ToDo] {
        let clearToDos = toDos.filter(isDoing)
        
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
            List(filteredToDos) {toDo in
                NavigationLink {
                    ToDoDetail(toDo: toDo)
                } label: {
                    DoingRow(toDo: toDo)
                }
            }
            .navigationTitle("Doing")
            .searchable(text: $searchText,  prompt: "SearchTodos")
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
    
    private func isDoing(toDo: ToDo) -> Bool {
        var hasUnCompleted = false
        var hasCompleted = false
        for step in toDo.steps {
            if step.isCompleted {
                hasCompleted = true
            } else {
                hasUnCompleted = true
            }
        }
        return hasUnCompleted && hasCompleted
    }
    
}

#Preview {
    DoingList()
        .modelContainer(SampleData.shared.modelContainer)
}
