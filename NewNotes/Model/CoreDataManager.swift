//
//  CoreDataManager.swift
//  NewNotes
//
//  Created by andreasara-dev on 25/07/23.
//

import CoreData
import Foundation

final class CoreDataManager: ObservableObject {
    let container = NSPersistentContainer(name: "NoteModel")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load the store \(error.localizedDescription)")
            }
        }
    }
}
