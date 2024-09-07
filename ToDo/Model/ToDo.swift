import Foundation
import SwiftData

@Model
final class ToDo {
    let id: UUID
    var title: String
    @Relationship(deleteRule: .cascade) var steps: [Step]
    var creatAt: Date
    
    init(id: UUID = UUID(), title: String, steps: [Step] = [], creatAt: Date = Date()) {
        self.id = id
        self.title = title
        self.steps = steps
        self.creatAt = creatAt
    }
    
    static let sampleData = [
        ToDo(title: "기상", steps: [
            Step(isCompleted: true),
            Step(isCompleted: true),
            Step()
        ]),
        ToDo(title: "밥먹기", steps: [
            Step(),
            Step(),
            Step()
        ]),
        ToDo(title: "씻기", steps: [
            Step(),
            Step(),
            Step()
        ]),
        ToDo(title: "준비하기", steps: [
            Step(),
            Step(),
            Step()
        ]),
        ToDo(title: "출근하기", steps: [
            Step(),
            Step(),
            Step(),
            Step()
        ])
    ]
}
