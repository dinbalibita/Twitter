//
//  TweetModels.swift
//  SnappApp
//
//  Created by Bita Dinbali on 3/12/22.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let data: T?
}

struct BaseArrayResponse<T: Decodable>: Decodable {
    let data: [T]
}

struct Tweet: Decodable {
    let id: String
    let createdAt: String
    let source: String
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case id, source, text
        case createdAt = "created_at"
    }
}

struct Rule: Decodable {
    let id: String
}



