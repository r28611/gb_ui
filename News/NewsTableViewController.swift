//
//  NewsTableViewController.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 20.01.2021.
//

import UIKit

final class NewsTableViewController: UITableViewController, UICollectionViewDelegate {
    
    let networkManager = NetworkManager.shared
    private var newsPosts = [NewsPost]()
    private var users = [Int:User]()
    private var groups = [Int:Group]()

    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager.loadNewsPost(token: Session.shared.token) { [weak self] news, users, groups in
            DispatchQueue.main.async {
                self?.newsPosts = news
                self?.users = users
                self?.groups = groups
                self?.tableView.reloadData()
            }
        }
        tableView.register(UINib(nibName: Constants.newsCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.newsCellIdentifier)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsPosts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.newsCellIdentifier, for: indexPath) as? NewsCell {
            let news = newsPosts[indexPath.row]

            var authorName = ""
            var authorAvatar: URL
            if news.sourceID > 0 {
                authorName = self.users[news.sourceID]!.name
                authorAvatar = self.users[news.sourceID]!.avatarURL
            } else {
                authorName = self.groups[-news.sourceID]!.name
                authorAvatar = self.groups[-news.sourceID]!.avatarURL
            }

            cell.setup(news: news, authorName: authorName, authorAvatar: authorAvatar)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.beginUpdates()
        
        if let cell = tableView.cellForRow(at: indexPath) as? NewsCell {
            cell.newsText.numberOfLines = cell.newsText.calculateMaxLines()
        }
        tableView.endUpdates()
    }

}
