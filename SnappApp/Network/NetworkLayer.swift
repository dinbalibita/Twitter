//
//  NetworkLayer.swift
//  SnappApp
//
//  Created by Bita Dinbali on 3/12/22.
//

import Foundation

protocol NetworkLayerProtocol {
    func streamRequest(_ request: URLRequest, _ streamClosure: ((Data?, Error?) -> Void)?) -> Connectable
    
    @discardableResult
    func request(_ request: URLRequest, _ completion: ((Data?, Error?) -> Void)?) -> Cancellable
}

class NetworkLayer: NSObject, NetworkLayerProtocol {
    private let dispatchQueue: DispatchQueue
    private var streamClosure: ((Data?, Error?) -> Void)?
    private let httpHeaders: [String: String]
    
    private lazy var streamSession: URLSession = {
        let operationQueue = OperationQueue()
        operationQueue.underlyingQueue = dispatchQueue
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
    }()
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    init(dispatchQueue: DispatchQueue = .main, httpHeaders: [String: String] = [:]) {
        self.dispatchQueue = dispatchQueue
        self.httpHeaders = httpHeaders
    }
    
    func streamRequest(_ request: URLRequest, _ streamClosure: ((Data?, Error?) -> Void)?) -> Connectable {
        var request = request
        attachHttpHeaders(to: &request)
        self.streamClosure = streamClosure
        let connectable = streamSession.dataTask(with: request)
        return connectable
    }
    
    func request(_ request: URLRequest, _ completion: ((Data?, Error?) -> Void)?) -> Cancellable {
        var request = request
        attachHttpHeaders(to: &request)
        let cancellable = session.dataTask(with: request) { data, _, error in
            completion?(data, error)
        }
        defer { cancellable.resume() }
        return cancellable
    }
    
    private func attachHttpHeaders(to request: inout URLRequest) {
        for (key, value) in httpHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
}

extension NetworkLayer: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(dataTask.state != .canceling ? .allow : .cancel)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if dataTask.state != .canceling {
            streamClosure?(data, nil)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        streamClosure?(nil, error)
    }
}
