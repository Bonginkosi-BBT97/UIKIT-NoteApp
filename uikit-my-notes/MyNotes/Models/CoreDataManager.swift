//
//  CoreDataManager.swift
//  MyNotes
//
//  Created by Bonginkosi Tshabalala on 2023/04/14.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared =  CoreDataManager(modelName: "MyNotes")
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init (modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
