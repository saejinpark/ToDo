//
//  SeparatedGuage.swift
//  ToDo
//
//  Created by 박세진 on 9/7/24.
//
import Foundation
import SwiftUI

struct SeparatedGaugeStyle: GaugeStyle {
    var limit: Int

    func makeBody(configuration: Configuration) -> some View {
        let value = round(configuration.value * Double(limit))
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<limit, id: \.self) { index in
                    Rectangle()
                        .fill(Double(index) < value ? Color("Gauge") : Color(UIColor.systemGray4))
                        .cornerRadius(4)
                }
            }
        }
        .frame(height: 12)
    }
}


struct SeparatedGuage: View {
    var toDo: ToDo
    let step = 1
    
    var body: some View {
        let limit = toDo.steps.count
        let value = toDo.steps.filter{ $0.isCompleted }.count
        
        VStack(spacing: 20) {
            Gauge(value: Double(value), in: 0...Double(limit)) {
                Text("Progress")
            } currentValueLabel: {
                Text("\(value)")
            }
            .gaugeStyle(SeparatedGaugeStyle(limit: limit))
        }
    }
}

#Preview {
    SeparatedGuage(toDo: SampleData.shared.toDo)
}
