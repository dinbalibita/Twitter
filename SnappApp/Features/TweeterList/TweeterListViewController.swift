//
//  TweetDetailViewController.swift
//  SnappApp
//
//  Created by Bita Dinbali on 3/10/22.
//

import UIKit

protocol TweeterListTableViewControllerDelegate: AnyObject {
    func twitterListTableController(didSelectTweet id: String)
}

class TweeterListTableViewController: UITableViewController {
    
    weak var delegate: TweeterListTableViewControllerDelegate?
    
    private let cellItemNibName = String(describing: TweeterTableViewCell.self)
    private let mainIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var showTweets: Bool = false
    
    private var tweets: [Tweet] = []
    
    private let service: TwitterServiceProtocol?
    
    init(service: TwitterServiceProtocol) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupIndicator()
        setupSearchBar()
        setupTableView()
        setupNavigationBar()
        
        filteredStream()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Twitter Lists"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: cellItemNibName, bundle: nil), forCellReuseIdentifier: cellItemNibName)
        tableView.separatorInset = .zero
        tableView.delegate = self
        tableView.setEmptyMessage("Enter the phrase you want to search")
        
    }
    
    private func setupSearchBar() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    private func setupIndicator() {
        mainIndicator.hidesWhenStopped = true
        mainIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainIndicator)
        mainIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        mainIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
    }
    
    private func filteredStream() {
        
        guard let service = service else { return }
        
        service.filteredStream { [unowned self] tweet in
            guard showTweets else { return }
            mainIndicator.stopAnimating()
            tweets.insert(tweet, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        } onError: { error in
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellItemNibName, for: indexPath) as! TweeterTableViewCell
        cell.tweetTextLabel.text = "Text : " + tweets[indexPath.row].text
        cell.createdDateLabel.text = "CreatedAt : " + tweets[indexPath.row].createdAt
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        
        showTweets = false
        
        delegate?.twitterListTableController(didSelectTweet: self.tweets[indexPath.row].id)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

extension TweeterListTableViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        showTweets = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tableView.restore()
        showTweets = false
        guard let service = service else { return }
        guard let text = searchBar.text else { return }
        mainIndicator.startAnimating()
        tweets.removeAll()
        tableView.reloadData()
        service.applyKeyword(text) { error in
            guard let error = error else { return }
            self.showTweets = true
            print(error)
        }
    }
    
}
