//
//  Categorie+CoreDataClass.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-02-27.
//
//

import Foundation
import CoreData

@objc(Note)

public class Note: NSManagedObject, Codable {
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context!] as? NSManagedObjectContext else {
            throw ContextError.NoContextFound
        }
        
        self.init(context: context)
        let values = try decoder.container(keyedBy: CodingKeysp.self)
        date = try values.decode(Date.self, forKey: .date)
        text = try values.decode(String.self, forKey: .text)
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeysp.self)
        try values.encode(date, forKey: .date)
        try values.encode(text, forKey: .text)
    }
    
    enum CodingKeysp: CodingKey {
        case date
        case text
    }
}
