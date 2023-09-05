//
//  ContentView.swift
//  NewNotes
//
//  Created by andreasara-dev on 25/07/23.
//

import LocalAuthentication
import SwiftUI

struct ContentView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.lastEditing, order: .reverse)]) private var notes: FetchedResults<Note>
    @State private var sortDescriptors: [SortDescriptor<Note>] = []
    @State private var currentSortDescriptor: String = "lastEditing"
    
    @State private var searchText = ""
    
    @State private var currentSelection = "Others"
    let categories = ["Favourites", "Others"]
    
    @State private var isShowingAddScreen = false
    
    @State private var isUnlocked = false
    
    @State private var authenticationError = "Unknown error"
    @State private var isshowingAuthenticationError = false
    
    var body: some View {
        if isUnlocked {
            NavigationStack {
                VStack {
                    Picker("Current selection", selection: $currentSelection) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding([.trailing, .leading])
                    
                    FilteredNoteList(descriptors: sortDescriptors, favouritePredicate: "isFavourite ==", filter: currentSelection == "Favourites" ? true : false, searchPredicate: "title CONTAINS[c]", searchValue: searchText)
                        .searchable(text: $searchText)
                }
                .sheet(isPresented: $isShowingAddScreen) {
                    NavigationStack {
                        AddNoteView()
                    }
                    .presentationDetents([.medium, .large])
                }
                .navigationTitle("NewNotes")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                            .disabled(notes.isEmpty)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            changeSortDescriptor()
                        } label: {
                            Image(systemName: currentSortDescriptor == "lastEditing" ? "slider.horizontal.3" :  "slider.vertical.3")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowingAddScreen = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        } else {
            Button("Unlock Notes") {
                authenticate()
            }
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .alert("Authentication error", isPresented: $isshowingAuthenticationError) {
                Button("Ok") { }
            } message: {
                Text(authenticationError)
            }
        }
    }
    
    private func changeSortDescriptor() {
        if currentSortDescriptor == "lastEditing" {
            withAnimation {
                sortDescriptors = [SortDescriptor(\.dateOfCreation, order: .forward)]
                currentSortDescriptor = "dateOfCreation"
            }
        } else {
            withAnimation {
                sortDescriptors = [SortDescriptor(\.lastEditing, order: .reverse)]
                currentSortDescriptor = "lastEditing"
            }
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your places."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                Task { @MainActor in
                    if success {
                        self.isUnlocked = true
                    } else {
                        self.authenticationError = "There was a problem authenticating you; please try again."
                        self.isshowingAuthenticationError = true
                    }
                }
            }
        } else {
            authenticationError = "Sorry, your device does not support biometrics authentication."
            isshowingAuthenticationError = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var coreDataManager = CoreDataManager()
    
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
        }
        .environment(\.managedObjectContext, coreDataManager.container.viewContext)
    }
}
