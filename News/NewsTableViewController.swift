//
//  NewsTableViewController.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 20.01.2021.
//

import UIKit

final class NewsTableViewController: UITableViewController, UICollectionViewDelegate {
    
    let networkManager = NetworkManager.shared
    private let viewModelFactory = NewsPostViewModelFactory()
    private var viewModels: [NewsPostViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRefresher()
        tableView.register(UINib(nibName: Constants.newsCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.newsCellIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNewsData()
    }
    
    private func getNewsData() {
        networkManager.loadNewsPost(token: Session.shared.token) { [weak self] news, users, groups in
            DispatchQueue.main.async {
                self?.viewModels = (self?.viewModelFactory.constructViewModels(from: news, users: users, groups: groups))!
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func setRefresher() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = Constants.greenColor
        refreshControl?.attributedTitle = NSAttributedString(string: Constants.refreshTitle, attributes: [.font: UIFont.systemFont(ofSize: 12)])
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        getNewsData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.newsCellIdentifier, for: indexPath) as? NewsCell {
            cell.configure(with: viewModels[indexPath.row])
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
