import Foundation
import SwiftData

@Model
class Step {
    let id: UUID
    var order: Int
    var desc: String
    var isCompleted: Bool
    var toDo: ToDo?
    
    init(id: UUID = UUID(), order: Int = 0, desc: String = "새로운 스탭", isCompleted: Bool = false) {
        self.id = id
        self.order = order
        self.desc = desc
        self.isCompleted = isCompleted
    }
}