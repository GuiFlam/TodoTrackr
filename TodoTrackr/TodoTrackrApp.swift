//
//  TodoForgeApp.swift
//  TodoForge
//
//  Created by GuiFlam on 2024-02-26.
//

import SwiftUI

@main
struct TodoTrackrApp: App {
    @StateObject private var dataManager = DataManager()
    @StateObject private var notesDataManager = NotesDataManager()
    
    var body: some Scene {
        WindowGroup {
            InitialView()
                .environment(\.managedObjectContext, dataManager.container.viewContext)
                .environmentObject(dataManager)
                .environmentObject(notesDataManager)
        }
    }
}
