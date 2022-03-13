//
//  ErrorClass.swift
//  Rayanmehr.echarge
//
//  Created by bita dinbali on 5/14/20.
//  Copyright © 2020 bita dinbali. All rights reserved.
//

import Foundation
import ObjectMapper

class ErrorClass: MappableObject {
    
    var message: String?

    override func mapping(map: Map) {
        message <- map["message"]
    }
    
}
