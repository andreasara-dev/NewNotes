//
//  NoteView.swift
//  NewNotes
//
//  Created by andreasara-dev on 26/07/23.
//

import SwiftUI

struct NoteView: View {
    @Environment(\.managedObjectContext) var moc
    var note: Note
    
    @State private var isEdited = false
    @State private var noteTitle: String
    @State private var noteText: String
    @State private var textChecker = false
    @State private var isShowingConfirmation = false
    @State private var isHeartFilled: Bool
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY"
        return formatter
    }()
    
    var buttons: [RadialButton] {
        [
            RadialButton(label: "Bullet list", image: Image(systemName: "list.bullet"), action: createBulletList),
            RadialButton(label: "Dash list", image: Image(systemName: "list.dash"), action: createDashList),
            RadialButton(label: "Delete all", image: Image(systemName: "eraser.line.dashed")) { isShowingConfirmation = true }
        ]
    }
    
    init(note: Note) {
        self.note = note
        self._noteTitle = State(initialValue: note.title ?? "")
        self._noteText = State(initialValue: note.text ?? "")
        self._isHeartFilled = State(initialValue: note.isFavourite)
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                TextField("Note title", text: $noteTitle)
                    .onChange(of: noteTitle) { _ in
                        isEdited = true
                    }
                    .font(.title)
                    .bold()
                    //.padding()
                Text("Created: \((dateFormatter.string(from: note.wrappedDateOfCreation)))")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
                HStack {
                    Text(isHeartFilled ? "Unmark as favourite: " : "Mark as favourite: ")
                    Button {
                        withAnimation {
                            note.isFavourite.toggle()
                            isHeartFilled = note.isFavourite
                        }
                        print(note.isFavourite)
                        
                        try? moc.save()
                    } label: {
                        Image(systemName: isHeartFilled == true ? "heart.fill" : "heart")
                    }
                    .foregroundColor(.red)
                    .font(.title2)
                }
                .padding(.top, 0.5)
                TextEditor(text: $noteText)
                    .onChange(of: noteText) { _ in
                        isEdited = true
                    }
                    .font(.title3)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    RadialMenu(title: "Attach", closedImage: Image(systemName: "ellipsis.circle"), openImage: Image(systemName: "multiply.circle.fill"), buttons: buttons, animation: .interactiveSpring(response: 0.4, dampingFraction: 0.6))
                        .offset(x: -20, y: -20)
                        .buttonStyle(CustomButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onChange(of: noteText) { _ in
            textChecker = true
        }
        .onDisappear {
            if isEdited {
                editTitle(newTitle: noteTitle)
                
                if textChecker {
                    editNote(newText: noteText)
                }
            }
        }
        .confirmationDialog("Erase all content", isPresented: $isShowingConfirmation) {
            Button(role: .destructive) {
                eraseAll()
            } label: {
                Text("Yes, I'm sure")
            }
        } message: {
            Text("All note content wil be erased, are you sure?")
        }
    }
    
    private func editTitle(newTitle: String) {
        note.title = newTitle
        note.lastEditing = Date.now
        
        try? moc.save()
    }
    
    private func editNote(newText: String) {
        note.text = newText
        note.lastEditing = Date.now
        
        try? moc.save()
    }
    
    private func createBulletList() {
        var bulletList = ""
        for _ in 0...2 {
            bulletList.append("• \n")
        }
        noteText.append(" \n" + bulletList)
        
        try? moc.save()
    }
    
    private func createDashList() {
        var dashList = ""
        for _ in 0...2 {
            dashList.append("- \n")
        }
        noteText.append(" \n" + dashList)
        
        try? moc.save()
    }
    
    private func eraseAll() {
        noteText = ""
        note.isFavourite = false
        
        try? moc.save()
    }
}

struct NoteView_Previews: PreviewProvider {
    static var coreDataManager = CoreDataManager()
    static var moc = coreDataManager.container.viewContext
    
    static var previews: some View {
        let note = Note(context: moc)
        note.title = "Test note"
        note.text = "Test text"
        note.lastEditing = Date.now
        note.dateOfCreation = Date.now
        
        return Group {
            NavigationStack {
                NoteView(note: note)
            }
            NavigationStack {
                NoteView(note: note)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
