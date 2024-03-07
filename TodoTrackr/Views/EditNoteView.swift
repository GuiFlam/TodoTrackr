//
//  EditNoteView.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-03-06.
//

import SwiftUI

struct EditNoteView: View {
    var note: Note
    @State var text: String = ""
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
                .onAppear {
                    text = note.text ?? ""
                }
               
                .padding(.horizontal)
                .toolbar {
                    if isFocused {
                        ToolbarItem(placement: .topBarTrailing, content: {
                            Button("Done", action: {
                                note.text = text
                                try? moc.save()
                                isFocused = false
                            })
                        })
                    }
                    
                }
                
        }
        .scrollContentBackground(.hidden) // <- Hide it
        .background(Color("BackgroundColor")) // To see this
        .navigationTitle("Edit Note")
           
        
        
    }
    private func firstLine(of string: String) -> String {
            return string.split(separator: "\n").first.map(String.init) ?? ""
        }
}
