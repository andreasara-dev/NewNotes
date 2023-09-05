//
//  Note+CoreDataProperties.swift
//  NewNotes
//
//  Created by andreasara-dev on 30/07/23.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var dateOfCreation: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isFavourite: Bool
    @NSManaged public var lastEditing: Date?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    
    public var wrappedDateOfCreation: Date {
        dateOfCreation ?? Date.now
    }
    
    public var wrappedLastEditing: Date {
        lastEditing ?? Date.now
    }

    public var wrappedText: String {
        text ?? "Unknown note text"
    }
    
    public var wrappedTitle: String {
        title ?? "Unknown note title"
    }

}

extension Note : Identifiable {

}
