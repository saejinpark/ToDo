import Foundation
import SwiftUI
import SwiftData

@Model
final class ToDo {
    let id: UUID
    var title: String
    var category: Category
    var creatAt: Date
    @Relationship(deleteRule: .cascade) var steps: [Step]
    
    init(id: UUID = UUID(), title: String = "", category: Category = Category.work, creatAt: Date = Date(), steps: [Step] = []) {
        self.id = id
        self.title = title
        self.category = category
        self.creatAt = creatAt
        self.steps = steps
    }
    
    enum Category: String, CaseIterable, Identifiable, Codable {
        case work = "Work"
        case personal = "Personal"
        case health = "Health"
        case finance = "Finance"
        case education = "Education"
        case home = "Home"
        case shopping = "Shopping"
        case social = "Social"
        case errands = "Errands"
        case projects = "Projects"
        
        var id: String { self.rawValue }
        
        var color: Color {
            switch self {
            case .work: return .blue
            case .personal: return .green
            case .health: return .red
            case .finance: return .purple
            case .education: return .orange
            case .home: return .yellow
            case .shopping: return .pink
            case .social: return .teal
            case .errands: return .gray
            case .projects: return .indigo
            }
        }
        
        var systemImage: String {
            switch self {
            case .work: return "briefcase"
            case .personal: return "person"
            case .health: return "heart"
            case .finance: return "dollarsign.circle"
            case .education: return "book"
            case .home: return "house"
            case .shopping: return "cart"
            case .social: return "person.3"
            case .errands: return "list.bullet"
            case .projects: return "folder"
            }
        }
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
