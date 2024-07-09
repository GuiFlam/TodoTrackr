//
//  Todo+CoreDataClass.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-02-27.
//
//

import SwiftUI
import CoreData
import Foundation

public class Todo: NSManagedObject, Decodable, Encodable {
    // Define the properties you want to decode
    
    // Add other properties as needed
    
    // Implement required initializer for Decodable
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context!] as? NSManagedObjectContext else {
            fatalError("Missing context userInfo key")
        }
        
        // Create an entity description
        guard let entity = NSEntityDescription.entity(forEntityName: "Todo", in: context) else {
            fatalError("Failed to find entity description")
        }
        
        // Call designated initializer
        self.init(entity: entity, insertInto: context)
        
        // Decode properties
        let container = try decoder.container(keyedBy: CodingKeys.self)
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        id = try container.decode(UUID.self, forKey: .id)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        tint = try container.decodeIfPresent(String.self, forKey: .tint)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        // Decode other properties
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(id, forKey: .id)
        try values.encode(title, forKey: .title)
        try values.encode(caption, forKey: .caption)
        try values.encode(date, forKey: .date)
        try values.encode(isCompleted, forKey: .isCompleted)
        try values.encode(tint, forKey: .tint)
    }
    
    // Define coding keys if needed
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case caption
        case date
        case isCompleted
        case tint
        case categorie
        // Add other coding keys as needed
    }
}
