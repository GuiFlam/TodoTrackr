//
//  Categorie+CoreDataClass.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-02-27.
//
//

import Foundation
import CoreData

@objc(Categorie)
public class Categorie: NSManagedObject, Codable {
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context!] as? NSManagedObjectContext else {
            throw ContextError.NoContextFound
        }
        self.init(context: context)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int64.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        todos = try values.decode(Set<Todo>.self, forKey: .todos) as NSSet
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(id, forKey: .id)
        try values.encode(title, forKey: .title)
        if let array = todos?.allObjects as? [Todo] {
            try values.encode(array, forKey: .todos)
        }
    }
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case todos
    }
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "managedObjectContext")
}

enum ContextError: Error {
    case NoContextFound
}
