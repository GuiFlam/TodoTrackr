//
//  TodoForgeApp.swift
//  TodoForge
//
//  Created by GuiFlam on 2024-02-26.
//

import SwiftUI

@main
struct TodoForgeApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, dataManager.container.viewContext)
                .environmentObject(dataManager)
        }
    }
}
