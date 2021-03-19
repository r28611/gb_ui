//
//  FriendsViewController.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 06.01.2021.
//

import UIKit
import RealmSwift

struct FriendSection {
    var title: String
    var items: [User]
}

class FriendsViewController: UIViewController {
    
    var users = [User]()
    var sections = [FriendSection]()
    var chosenUser: User!
    
    private let realmManager = RealmManager.shared
    private var userResults: Results<User>? {
        let users: Results<User>? = realmManager?.getObjects()
        return users
    }
    private var filteredUserResults: Results<User>? {
        let users: Results<User>? = realmManager?.getObjects()
        return users?.filter("status == 1")
    }
    
    private var filteredUsersNotificationToken: NotificationToken?
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0.1354144812, green: 0.8831900954, blue: 0.6704884171, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(string: "Reload Data", attributes: [.font: UIFont.systemFont(ofSize: 12)])
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var friendsFilterControl: UISegmentedControl!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTextFieldLeading: NSLayoutConstraint!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchImageCenterX: NSLayoutConstraint!
    @IBOutlet weak var searchCancelButton: UIButton!
    @IBOutlet weak var searchCancelButtonLeading: NSLayoutConstraint!
    
    @IBOutlet weak var charPicker: CharacterPicker!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.register(UINib(nibName: "HeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        filteredUsersNotificationToken = filteredUserResults?.observe { [weak self] change in
            switch change {
            case .initial(let users):
                print("Initialize \(users.count)")
                break
            case .update(let users, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                print("""
                    New count \(users.count)
                    Deletions \(deletions)
                    Insertions \(insertions)
                    Modifications \(modifications)
                    """
                    )
                self?.tableView.beginUpdates()
                let deletionIndexPaths = deletions.map { IndexPath(item: $0, section: 0) }
                self?.tableView.deleteRows(at: deletionIndexPaths, with: .automatic)
                self?.tableView.insertRows(at: insertions.map { IndexPath(item: $0, section: 0) }, with: .automatic)
                self?.tableView.reloadRows(at: modifications.map { IndexPath(item: $0, section: 0) }, with: .automatic)
                self?.tableView.endUpdates()
                
                break
            case .error(let error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let results = userResults {
            self.users = results.toArray() as! [User]
            groupUsersForTable(users: self.users)
            render()
        } else {
            refresh(refreshControl)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if self.searchTextField.text == "" {
            self.searchTextField.endEditing(true)
            self.searchTextFieldLeading.constant = 0
            self.searchImageCenterX.constant = 0
            self.searchCancelButtonLeading.constant = 0
            self.searchImage.tintColor = .gray
        }
    }
    
    deinit {
        filteredUsersNotificationToken?.invalidate()
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        NetworkManager.loadFriends(token: Session.shared.token) { [weak self] users in
            try? self?.realmManager?.save(objects: users)
            print(Realm.Configuration.defaultConfiguration.fileURL ?? "Realm error")
            self?.users = users
            self?.render()
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func showAlert(title: String? = nil,
                           message: String? = nil,
                           handler: ((UIAlertAction) -> Void)? = nil,
                           completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: completion)
    }
    
    func groupUsersForTable(users: [User]) {
        let friendsDictionary = Dictionary.init(grouping: users) {$0.surname.prefix(1)}
        sections = friendsDictionary.map {FriendSection(title: String($0.key), items: $0.value)}
        sections.sort {$0.title < $1.title}
        charPicker.chars = sections.map {$0.title}
        charPicker.setupUi()
    }
    
    func render() {
        switch self.friendsFilterControl.selectedSegmentIndex {
        case 0:
            groupUsersForTable(users: self.users)
        default:
            if let filteredUsers = self.filteredUserResults {
                groupUsersForTable(users: filteredUsers.toArray() as! [User] )
            self.charPicker.isHidden = true
        }
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Character Picker
    
    @IBAction func characterPicked(_ sender: CharacterPicker) {
        var indexPath = IndexPath()
        for (index, section) in sections.enumerated() {
            if sender.selectedChar == section.title {
                indexPath = IndexPath(item: 0, section: index)
            }
        }
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    @IBAction func didMakePan(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: charPicker).y
        let coef = Int(charPicker.frame.height) / sections.count
        let letterIndex = Int(location) / coef
        
        if letterIndex >= 0 && letterIndex <= sections.count - 1 {
            charPicker.selectedChar = sections[letterIndex].title
        }
    }
    
    // MARK: FriendsFilterControl
    
    @IBAction func friendsFilterControlChanged(_ sender: UISegmentedControl) {
        render()
        self.searchTextField.text = ""
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to_collection" {
            if let destination = segue.destination as? FriendsPhotosCollectionViewController {
                destination.friend = chosenUser
            }
        }
    }
}

// MARK: - Table view data source

extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FriendsTableViewCell {
            cell.contentView.alpha = 0
            UIView.animate(withDuration: 1,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.3,
                           options: [],
                           animations: {
                            cell.frame.origin.x -= 80
                           })
            
            let user = sections[indexPath.section].items[indexPath.row]
            cell.userModel = user
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! FriendsTableViewCell
        UIView.animate(withDuration: 1, animations: {
            cell.contentView.alpha = 1
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenUser = sections[indexPath.section].items[indexPath.row]
        performSegue(withIdentifier: "to_collection", sender: self)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as? HeaderView {
            header.headerLabel.text = sections[section].title
            header.tintColor = UIColor.systemPink.withAlphaComponent(0.3)
            return header
        }
        return nil
    }
}

// MARK: - Text Field extension

extension FriendsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.searchImage.tintColor = .white
            
            self.searchTextFieldLeading.constant = self.searchImage.frame.width + 3 + 3
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.2,
                       options: [],
                       animations: {
                        self.searchImageCenterX.constant = -((self.view.frame.width / 2) - (self.searchImage.frame.width / 2) - 3)
                        self.searchCancelButtonLeading.constant = -(self.searchCancelButton.frame.width + 5)
                        self.view.layoutIfNeeded()
                       })
    }
    
    //какой из методов лучше читается?
    // 1
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = self.searchTextField.text {
            if text == "" {
                switch self.friendsFilterControl.selectedSegmentIndex {
                case 0:
                    groupUsersForTable(users: self.users)
                default:
                    let filteredUsers = users.filter({$0.isOnline == true})
                    self.groupUsersForTable(users: filteredUsers)
                }
            } else {
                switch self.friendsFilterControl.selectedSegmentIndex {
                case 0:
                    let filteredUsers = users.filter({($0.name + $0.surname).lowercased().contains(text.lowercased())})
                    groupUsersForTable(users: filteredUsers)
                default:
                    let filteredUsers = users
                        .filter({$0.isOnline == true})
                        .filter({($0.name + $0.surname).lowercased().contains(text.lowercased())})
                    self.groupUsersForTable(users: filteredUsers)
                    groupUsersForTable(users: filteredUsers)
                }
            }
            tableView.reloadData()
        }
    }
    
    // 2
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = self.searchTextField.text {
            
            if self.friendsFilterControl.selectedSegmentIndex == 0 && text == "" {
                groupUsersForTable(users: self.users)
            } else if self.friendsFilterControl.selectedSegmentIndex == 0 {
                let filteredUsers = users.filter({($0.name + $0.surname).lowercased().contains(text.lowercased())})
                groupUsersForTable(users: filteredUsers)
            } else if text == "" {
                let filteredUsers = users.filter({$0.isOnline == true})
                self.groupUsersForTable(users: filteredUsers)
            } else {
                let filteredUsers = users
                    .filter {$0.isOnline == true}
                    .filter({($0.name + $0.surname).lowercased().contains(text.lowercased())})
                self.groupUsersForTable(users: filteredUsers)
            }
            tableView.reloadData()
        }
        return true
    }
    
    @IBAction func searchCancelPressed(_ sender: UIButton) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.searchImage.tintColor = .gray
            
            self.searchTextFieldLeading.constant = 0
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.2,
                       options: [],
                       animations: {
                        self.searchImageCenterX.constant = 0
                        self.searchCancelButtonLeading.constant = 0
                        self.view.layoutIfNeeded()
                       })
        
        searchTextField.endEditing(true)
        guard searchTextField.text != "" else { return }
        searchTextField.text = ""
        groupUsersForTable(users: self.users)
        tableView.reloadData()
    }
    
}
