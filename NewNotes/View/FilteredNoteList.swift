//
//  FilteredNoteList.swift
//  NewNotes
//
//  Created by andreasara-dev on 27/07/23.
//

import SwiftUI

struct FilteredNoteList: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest var fetchRequest: FetchedResults<Note>
    
    @State private var showAlert = false
    
    let relativeDateTimeFormatter = RelativeDateTimeFormatter()
    
    var body: some View {
        List {
            ForEach(fetchRequest) { note in
                NavigationLink {
                    NoteView(note: note)
                } label: {
                    HStack {
                        VStack {
                            Text(note.wrappedTitle)
                                .font(.title3)
                        }
                        Spacer()
                        Text((relativeDateTimeFormatter.localizedString(for: note.wrappedLastEditing, relativeTo: Date())))
                            .font(.caption)
                            .italic()
                    }
                }
            }
            .onDelete(perform: deleteNotes)
        }
        
    }
    
    init(descriptors: [SortDescriptor<Note>], favouritePredicate: String, filter: Bool, searchPredicate: String, searchValue: String) {
        let favouritePredicate = NSPredicate(format: "\(favouritePredicate) %@", NSNumber(value: filter))
        let searchPredicate = searchValue.isEmpty ? nil : NSPredicate(format: "\(searchPredicate) %@", searchValue)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [favouritePredicate, searchPredicate].compactMap { $0 })
        
        _fetchRequest = FetchRequest<Note>(sortDescriptors: descriptors, predicate: compoundPredicate)
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        for offset in offsets {
            let note = fetchRequest[offset]
            moc.delete(note)
        }
        try? moc.save()
    }
}
