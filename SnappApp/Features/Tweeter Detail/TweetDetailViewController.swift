//
//  TweetDetailViewController.swift
//  SnappApp
//
//  Created by Bita Dinbali on 3/10/22.
//

import UIKit

class TweetDetailViewController: UIViewController {

    let mainIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    private var tweetId: String
    private let service: TwitterServiceProtocol?
    private var tweet: Tweet?
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    init(tweetId: String, service: TwitterServiceProtocol) {
        self.tweetId = tweetId
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        getTweetDetail()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Tweete Detail"
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func getTweetDetail() {
        service?.getTweet(id: tweetId, onResult: { [weak self] tweet in
            guard let self = self else { return }
            self.tweet = tweet
            self.setupView()
        }, onError: { error in
            print(error)
        })
    }
    
    private func setupView() {
        guard let tweet = tweet else { return}
        textLabel.text = "Text : " + tweet.text
        createdDateLabel.text = "Created Date: " + tweet.createdAt
        sourceLabel.text = "Source : " + tweet.source
    }
}
