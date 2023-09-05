//
//  AddNoteView.swift
//  NewNotes
//
//  Created by andreasara-dev on 26/07/23.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var isFavourite = false
    @State private var text = ""
    
    var body: some View {
        Form {
            Section {
                TextField("Insert note title", text: $title)
                Toggle("Set as favourite", isOn: $isFavourite)
            }
            Section {
                TextEditor(text: $text)
            } header: {
                Text("Write a portion of your note here if you like, you can add more text or modify it later :)")
                    .font(.caption)
            }
        }
        .navigationTitle("Add Note")
        .toolbar {
            Button("Done") { dismiss() }
                .disabled(title.isEmpty)
        }
        .onDisappear() {
            if title.isEmpty == false {
                addNote()
            }
        }
    }
    
    private func addNote() {
        let newNote = Note(context: moc)
        newNote.id = UUID()
        newNote.dateOfCreation = Date.now
        newNote.lastEditing = Date.now
        newNote.isFavourite = isFavourite
        newNote.text = text
        newNote.title = title
        
        withAnimation {
            try? moc.save()
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                AddNoteView()
            }
            NavigationStack {
                AddNoteView()
            }
            .preferredColorScheme(.dark)
        }
    }
}
