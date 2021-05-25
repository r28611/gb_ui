//
//  GroupsTableViewController.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 04.01.2021.
//

import UIKit
import RealmSwift
import PromiseKit

class GroupsTableViewController: UITableViewController {
    
    private let realmManager = RealmManager.shared
    private let networkManager = NetworkManager.shared
    private var photoService: PhotoService?
    private var groupsNotificationToken: NotificationToken?
    private var groups: Results<Group>? {
        let groups: Results<Group>? = realmManager?
            .getObjects()
            .sorted(byKeyPath: "membersCount", ascending: false) // по убыванию количества участников
        return groups
    }
    
    private var heightCellCache: CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(GroupsTableViewCell.self, forCellReuseIdentifier: Constants.groupCellIdentifier)
        photoService = PhotoService(container: tableView)
        setRefresher()
        setGroupRealmNotofocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if groups == nil {
            getGroupsData()
        }
    }
    
    private func getGroupsData() {
        
        networkManager.loadGroups(token: Session.shared.token, on: .global())
            .get { [weak self] groups in
                guard let self = self else { return }
                try? self.realmManager?.save(objects: groups)
            }
            .catch { error in
                let alert = Alert()
                alert.showAlert(title: "Error", message: error.localizedDescription)
            }.finally {
                self.refreshControl?.endRefreshing()
            }
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        getGroupsData()
    }
    
    private func setGroupRealmNotofocation() {
        groupsNotificationToken = groups?.observe { [weak self] change in
            switch change {
            case .initial(let groups):
                print("Initialize \(groups.count)")
                break
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                self?.tableView.beginUpdates()
                self?.tableView.deleteRows(at: deletions.map { IndexPath(item: $0, section: 0) }, with: .automatic)
                self?.tableView.insertRows(at: insertions.map { IndexPath(item: $0, section: 0) }, with: .automatic)
                self?.tableView.reloadRows(at: modifications.map { IndexPath(item: $0, section: 0) }, with: .automatic)
                self?.tableView.endUpdates()
                break
            case .error(let error):
                let alert = Alert()
                alert.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    private func setRefresher() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = Constants.greenColor
        refreshControl?.attributedTitle = NSAttributedString(string: Constants.refreshTitle, attributes: [.font: UIFont.systemFont(ofSize: 12)])
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.groupCellIdentifier, for: indexPath) as? GroupsTableViewCell,
           let group = groups?[indexPath.row] {
            cell.avatar.image.image = photoService?.photo(atIndexpath: indexPath, byUrl: group.avatarURL)
            cell.groupModel = group
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heightCellCache {
            return height
        } else {
            let cell = GroupsTableViewCell()
            var cellHeight: CGFloat = 0
            if let group = groups?[indexPath.row] {
                cell.avatar.image.image = photoService?.photo(atIndexpath: indexPath, byUrl: group.avatarURL)
                cell.layoutAvatar()
                cell.groupModel = group
                cellHeight = cell.cellSize().height
            }
            heightCellCache = cellHeight
            return cellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let group = groups?[indexPath.row] else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if editingStyle == .delete {
            //реализовать удаление на api когда-нибудь
            try? realmManager?.delete(object: group)
        }
    }
}
