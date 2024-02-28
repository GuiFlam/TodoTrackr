//
//
//  DataController.swift
//  CoreDataTutorial
//
//  Created by GuiFlam on 2024-02-24.
//

import CoreData
import Foundation

class DataManager: ObservableObject {
    
    let container = NSPersistentContainer(name: "Model")
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func getCategories() -> [Categorie] {
        let request: NSFetchRequest<Categorie> = Categorie.fetchRequest()
        do {
            guard let categories = try? container.viewContext.fetch(request) else { return [] }
            return categories
        }
    }
    
    func getTodos(from category: Categorie) -> [Todo] {
        // Check if the category has todos
        guard let todos = category.todos as? Set<Todo> else {
            print("Error: Failed to get todos from category")
            return []
        }

        // Return the todos associated with the category
        return Array(todos)
    }
    
    func getNextCategoryIndex() -> Int64 {
        let categories = getCategories()
        
        if categories.count == 0 {
            return 0
        }
        return (categories[categories.count-1].id) + Int64(1)
    }
    
    func delete(todo: Todo, from category: Categorie) {
            guard let todos = category.todos as? Set<Todo> else {
                print("Error: Failed to get todos from category")
                return
            }

            // Check if the todo to be deleted exists in the category's todos
            guard todos.contains(todo) else {
                print("Error: Todo not found in category")
                return
            }

            // Delete the todo from the category
            category.removeFromTodos(todo)
        

            // Save changes to the managed object context
            saveContext()
        }
    
    func updateIsCompleted(for todo: Todo) {
        
            // Update the isCompleted attribute of the todo
            todo.isCompleted.toggle()

            // Save changes to the managed object context
            saveContext()
        }
    
    private func saveContext() {
            let context = container.viewContext
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    
    func deleteAllObjects(forEntityName entityName: String) {
        let context = container.viewContext
        
        // Create a fetch request for the specified entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        // Optionally, you can configure a batch delete request instead of fetching objects one by one
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            // Perform the batch delete request
            try context.execute(batchDeleteRequest)
            
            // Save the changes to the managed object context
            try context.save()
        } catch {
            print("Error deleting objects: \(error)")
        }
    }
    
    func deleteCategory(_ category: Categorie) {
            let context = container.viewContext
            
            // Delete all todos associated with the category
            if let todos = category.todos as? Set<Todo> {
                for todo in todos {
                    context.delete(todo)
                }
            }
            
            // Delete the category itself
            context.delete(category)

            // Save changes to the managed object context
            saveContext()
    }
}
