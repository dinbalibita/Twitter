//
//  TwiterService.swift
//  SnappApp
//
//  Created by Bita Dinbali on 3/12/22.
//

import Foundation

protocol TwitterServiceProtocol {
    
    func filteredStream(_ onStream: @escaping (Tweet) -> Void, onError: ((Error) -> Void)?)
    func applyKeyword(_ keyword: String, _ completion: @escaping (Error?) -> Void)
    func getTweet(id: String, onResult: @escaping (Tweet) -> Void, onError: ((Error) -> Void)?)
}

class TwitterService: TwitterServiceProtocol {
    
    private let networkLayer: NetworkLayerProtocol
    private var currentStreamRequest: Connectable?
    private var lastRuleID: String? {
        get {
            UserDefaults.standard.string(forKey: "lastRuleID")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastRuleID")
        }
    }
    
    init(networkLayer: NetworkLayerProtocol) {
        self.networkLayer = networkLayer
    }
    
    func getTweet(id: String, onResult: @escaping (Tweet) -> Void, onError: ((Error) -> Void)?) {
        let url = "https://api.twitter.com/2/tweets/\(id)?"
        var components = URLComponents(string: url)!
        components.queryItems = [
            URLQueryItem(name: "tweet.fields", value: "id,created_at,text,public_metrics,source")
        ]
        var request: URLRequest = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        networkLayer.request(request, { data, error in
            if let error = error {
                onError?(error)
            } else if let data = data {
                do {
                    let responseObject = try JSONDecoder().decode(BaseResponse<Tweet>.self, from: data)
                    guard let responseData = responseObject.data else { return }
                    onResult(responseData)
                } catch {
                    onError?(error)
                }
            }
        })
    }
    
    func filteredStream(_ onStream: @escaping (Tweet) -> Void, onError: ((Error) -> Void)?) {
        currentStreamRequest?.disconnect()
        
        var components = URLComponents(string: "https://api.twitter.com/2/tweets/search/stream")!
        components.queryItems = [
            URLQueryItem(name: "tweet.fields", value: "id,created_at,text,public_metrics,source")
        ]
        var request: URLRequest = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        currentStreamRequest = networkLayer.streamRequest(request, { data, error in
            if let error = error {
                onError?(error)
            } else if let data = data {
                do {
                    let responseObject = try JSONDecoder().decode(BaseResponse<Tweet>.self, from: data)
                    guard let responseData = responseObject.data else { return }
                    onStream(responseData)
                } catch {
                    onError?(error)
                }
            }
        })
        currentStreamRequest?.connect()
    }
    
    func applyKeyword(_ keyword: String, _ completion: @escaping (Error?) -> Void) {
        removeLastRule { [weak self] error in
            if let error = error {
                completion(error)
            } else {
                self?.addRule(withKeyword: keyword) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    private func addRule(withKeyword keyword: String, _ completion: @escaping (Error?) -> Void) {
        let params = [
            "add": [
                ["value": keyword, "tag": ""]
            ]
        ]
        var request = URLRequest(url: URL(string: "https://api.twitter.com/2/tweets/search/stream/rules")!)
        request.httpMethod = "PosT"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        
        networkLayer.request(request) { data, error in
            guard let data = data else {
                completion(error)
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(BaseArrayResponse<Rule>.self, from: data)
                self.lastRuleID = responseObject.data.first?.id
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    private func removeLastRule(_ completion: @escaping (Error?) -> Void) {
        guard let id = lastRuleID else {
            completion(nil)
            return
        }
        let params = [
            "delete": [
                "ids": [id]
            ]
        ]
        var request = URLRequest(url: URL(string: "https://api.twitter.com/2/tweets/search/stream/rules")!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        networkLayer.request(request) { _, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
}
