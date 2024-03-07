//
//
//  DataController.swift
//  CoreDataTutorial
//
//  Created by GuiFlam on 2024-02-24.
//

import CoreData
import Foundation

class NotesDataManager: ObservableObject {
    
    let container = NSPersistentContainer(name: "Notes")
    
    init() {
        container.persistentStoreDescriptions.first!.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func getNotes() -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        do {
            guard let categories = try? container.viewContext.fetch(request) else { return [] }
            return categories
        }
    }
}
