//
//  ToDoRow.swift
//  ToDo
//
//  Created by 박세진 on 9/7/24.
//

import SwiftUI
import SwiftData

struct DoingRowStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            configuration.content
        }
    }
}

struct DoingRow: View {
    @Query private var toDos: [ToDo]
    @State private var currentToDo: ToDo?
    private let toDoId: UUID

    init(toDo: ToDo) {
        self.toDoId = toDo.id
        _toDos = Query(sort: \ToDo.creatAt)
    }
    
    var body: some View {
        Group {
            if let toDo = currentToDo {
                let limit = toDo.steps.count
                let value = toDo.steps.filter{ $0.isCompleted }.count
                
                LabeledContent{
                    SeparatedGuage(limit: limit, value: value)
                } label: {
                    Label(toDo.title, systemImage: toDo.category.systemImage)
                        .font(.headline)
                }
                .labeledContentStyle(DoingRowStyle())
            } else {
                Text("ToDoNotFound")
            }
        }
        .onAppear(perform: updateCurrentToDo)
    }
    
    func updateCurrentToDo() {
        currentToDo = toDos.first { $0.id == toDoId }
    }
}

#Preview {
    DoingRow(toDo: SampleData.shared.toDo)
}
