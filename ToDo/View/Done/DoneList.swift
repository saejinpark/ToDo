//
//  DoneList.swift
//  ToDo
//
//  Created by 박세진 on 8/18/24.
//

import SwiftUI
import SwiftData

struct DoneList: View {
    @Query(sort: \ToDo.creatAt) private var toDos: [ToDo]
    @State private var searchText = ""
    
    @Environment(\.modelContext) private var modelContext
    
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
            List{
                ForEach(filteredToDos) { toDo in
                    NavigationLink {
                        ToDoDetail(toDo: toDo, activeTab: .done)
                    } label: {
                        Label(toDo.title, systemImage: toDo.category.systemImage)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Done")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "SearchTodos")
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
