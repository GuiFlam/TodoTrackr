//
//  Todo+CoreDataProperties.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-02-27.
//
//

import Foundation
import CoreData


extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var caption: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var tint: String?
    @NSManaged public var title: String?

}

extension Todo : Identifiable {

}
