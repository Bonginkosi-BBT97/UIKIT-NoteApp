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
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("An error ocurred while saving \(error.localizedDescription) ")
            }
        }
    }
}

// MARK:-  Helper functions

extension CoreDataManager {
    func createNotre() -> Note {
        let note = Note(context: viewContext)
        note.id = UUID()
        note.text = ""
        note.lastUpdated = Date()
        save()
        return note
    }
    
    func fetchNotes() -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return (try? viewContext.fetch(request)) ?? []
        
    }
    
    func deleteNote(_ note: Note) {
        viewContext.delete(note)
        save()
    }
}
