//
//  ServiceProtocols.swift
//  SnappApp
//
//  Created by Bita Dinbali on 3/11/22.
//

import Foundation

protocol Cancellable {
    func cancelTask()
}

protocol Connectable {
    func connect()
    func disconnect()
}

extension URLSessionDataTask: Cancellable, Connectable {
    func cancelTask() {
        cancel()
    }
    
    func connect() {
        resume()
    }
    
    func disconnect() {
        cancel()
    }
}

