//
//  SampleData.swift
//  ToDo
//
//  Created by 박세진 on 9/1/24.
//

import Foundation
import SwiftData

@MainActor
class SampleData {
    static let shared = SampleData()
    
    let modelContainer: ModelContainer
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    private init() {
        let schema = Schema([
            ToDo.self,
            Step.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            insertSampleData()
        } catch {
            fatalError("Could not create ModelContainer")
        }
    }
    
    func insertSampleData() {
        for toDo in ToDo.sampleData {
            context.insert(toDo)
        }
        
        do {
            try context.save()
        } catch {
            print("Sample data context failed to save")
        }
    }
    
    var toDo: ToDo {
        ToDo.sampleData[0]
    }
}
