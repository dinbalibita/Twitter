//
//  AppCoordinator.swift
//  SnappApp
//
//  Created by Bita Dinbali on 3/13/22.
//

import Foundation
import UIKit

class AppCoordinator {
    
    private let network = NetworkLayer(dispatchQueue: .main, httpHeaders: [
        "Authorization": "Bearer AAAAAAAAAAAAAAAAAAAAANCXaAEAAAAAnfTohEc36zrhWdZKztUDAfxiCEU%3Daj4fXdKAmMwOyKvF3MTJd0nz7iV2eIjk3VWBgtE7eL6L3MvAWP"
    ])
    private let window: UIWindow?
    private weak var navigationController: UINavigationController?
    private lazy var service: TwitterService = TwitterService(networkLayer: network)
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func initViewController() {
        let tweetersListViewController = TweeterListTableViewController(service: service)
        tweetersListViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: tweetersListViewController)
        self.navigationController = navigationController
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
}

extension AppCoordinator: TweeterListTableViewControllerDelegate {
    func twitterListTableController(didSelectTweet id: String) {
        let tweetDetailViewController = TweetDetailViewController(tweetId: id, service: service)
        navigationController?.pushViewController(tweetDetailViewController, animated: true)
    }
}
