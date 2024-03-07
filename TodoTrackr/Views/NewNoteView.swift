//
//  NewNoteView.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-03-06.
//

import SwiftUI

struct NewNoteView: View {
    @State private var text = ""
    @Environment(\.managedObjectContext) private var moc
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            Divider()
                .overlay(Color.white.opacity(0.8))
                .padding(.horizontal)
                .padding(.vertical, 7)
            TextEditor(text: $text)
                .focused($isFocused)
                .padding(.horizontal)
                .toolbar {
                    if text != "" {
                        ToolbarItem(placement: .topBarTrailing, content: {
                            Button("Done", action: {
                                let note = Note(context: moc)
                                note.text = text
                                note.date = Date()
                                try? moc.save()
                                isFocused = false
                            })
                        })
                    }
                    
                }
        }
        
        .scrollContentBackground(.hidden) // <- Hide it
        .background(Color("BackgroundColor")) // To see this
        .navigationTitle("New Note")
        
        
    }
    private func firstLine(of string: String) -> String {
        return string.split(separator: "\n").first.map(String.init) ?? ""
    }
}

#Preview {
    NewNoteView()
}
