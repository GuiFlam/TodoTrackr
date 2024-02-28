//
//  Categorie+CoreDataProperties.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-02-27.
//
//

import Foundation
import CoreData


extension Categorie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Categorie> {
        return NSFetchRequest<Categorie>(entityName: "Categorie")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var todos: NSSet?

}

// MARK: Generated accessors for todos
extension Categorie {

    @objc(addTodosObject:)
    @NSManaged public func addToTodos(_ value: Todo)

    @objc(removeTodosObject:)
    @NSManaged public func removeFromTodos(_ value: Todo)

    @objc(addTodos:)
    @NSManaged public func addToTodos(_ values: NSSet)

    @objc(removeTodos:)
    @NSManaged public func removeFromTodos(_ values: NSSet)

}

extension Categorie : Identifiable {

}
