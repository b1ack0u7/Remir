//
//  Persistence.swift
//  Remir
//
//  Created by Axel Montes de Oca on 25/06/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let newItem = Item(context: viewContext)
        let newItem2 = Item(context: viewContext)
        
        newItem.title = "Actividad 1"
        newItem.note = "Nota"
        newItem.colorTag = "MDL green"
        newItem.weeksSelected = "L,V"
        newItem.startDate = Date()
        newItem.endDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date())
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: newItem.startDate!)
        newItem.timeSort = "\(timeComponents.hour! as Int):\(timeComponents.minute! as Int)"
        newItem.time12HStart = "10:00 AM"
        newItem.time12HEnd = "11:22 AM"
        newItem.tasks = [Task(title: "Lavar los trastes", isCompleted: false, isTimer: true, hour: 0, min: 15), Task(title: "Sacar la basura", isCompleted: true, isTimer: true, hour: 0, min: 5)]
        newItem.tasksCount = 2
        
        newItem2.title = "Actividad 2"
        newItem2.note = "Nota2"
        newItem2.colorTag = "MDL purple"
        newItem2.weeksSelected = "L,J,S"
        newItem2.startDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        newItem2.endDate = Calendar.current.date(byAdding: .hour, value: 2, to: newItem2.startDate!)
        let timeComponents2 = Calendar.current.dateComponents([.hour, .minute], from: newItem.startDate!)
        newItem2.timeSort = "\(timeComponents2.hour! as Int):\(timeComponents2.minute! as Int)"
        newItem.time12HStart = "1:00 PM"
        newItem.time12HEnd = "5:00 PM"
        newItem2.tasks = [Task(title: "Levantarse", isCompleted: false, isTimer: false, hour: 0, min: 0)]
        newItem2.tasksCount = 1
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Remir")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
