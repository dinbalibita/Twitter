//
//  MappableObjectRequest.swift
//  Customer Portal
//
//  Created by Erfan Iranpour on 9/24/18.
//  Copyright © 2018 Chargoon. All rights reserved.
//

import Foundation
import ObjectMapper

class MappableObjectRequest: MappableObject {
    
    var token: String?
    
    override init() {
        super.init()
        //self.token = CacheHelper.getCacheString(for: .token)
    }
    
    required init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    override func mapping(map: Map) {
        token <- map["token"]
    }
    
}
