//
//  ToDoRow.swift
//  ToDo
//
//  Created by 박세진 on 9/7/24.
//

import SwiftUI

struct ToDoRowStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            HStack {
                configuration.label
                Spacer()
            }
            configuration.content
        }
    }
}

struct ToDoRow: View {
    var toDo: ToDo
    
    var body: some View {
        LabeledContent{
            SeparatedGuage(toDo: toDo)
        } label: {
            Label(toDo.title, systemImage: "circle")
        }
        .labeledContentStyle(ToDoRowStyle())
    }}

#Preview {
    ToDoRow(toDo: SampleData.shared.toDo)
}
