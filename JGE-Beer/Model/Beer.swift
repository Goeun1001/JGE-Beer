//
//  Beer.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/26.
//

import Foundation

struct Beer: Codable, Equatable {
    var id: Int?
    var name: String?
    var description: String?
    var imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageURL = "image_url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try? values.decode(Int.self, forKey: .id)
        self.name = try? values.decode(String.self, forKey: .name)
        self.description = try? values.decode(String.self, forKey: .description)
        self.imageURL = try? values.decode(String.self, forKey: .imageURL)
    }
}
