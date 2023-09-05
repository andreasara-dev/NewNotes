//
//  NewNotesApp.swift
//  NewNotes
//
//  Created by andreasara-dev on 25/07/23.
//

import SwiftUI

@main
struct NewNotesApp: App {
   @StateObject private var coreDataManager = CoreDataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.container.viewContext)
        }
    }
}
