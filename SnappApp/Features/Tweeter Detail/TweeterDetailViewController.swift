//
//  TweetDetailViewController.swift
//  Rayanmehr.echarge
//
//  Created by Bita Dinbali on 10/26/20.
//  Copyright © 2020 bita dinbali. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {
    
    private let network = NetworkLayer(dispatchQueue: .main, httpHeaders: [
        "Authorization": "Bearer AAAAAAAAAAAAAAAAAAAAADIsaAEAAAAAgd%2BtVh1Fsi%2FnSzqdFY0YOvtmPBI%3DGqmajIyLFuzGppn9C3sStN7gdMJh4pztr1NDCbagjfhc8Wde6A"
    ])
    
    private var tweetId: String
    private var service: TwitterService?
    private var tweet: Tweet?
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    init(tweetId: String) {
        self.tweetId = tweetId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Tweete Detail"
        navigationController?.navigationBar.tintColor = .black
        service = TwitterService(networkLayer: network)
        getTweetDetail()
    }
    
    private func getTweetDetail() {
        service?.getTweet(id: tweetId, onStream: {
            [unowned self] tweet in
            self.tweet = tweet
            setupView()
        }, onError: { error in
            print(error)
            
        })
    }
    
    private func setupView() {
        guard let tweet = tweet else { return}
        textLabel.text = tweet.text
        createdDateLabel.text = tweet.createdAt
    }
}
