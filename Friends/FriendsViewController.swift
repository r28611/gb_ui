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

final class FriendsViewController: UIViewController {
    @IBOutlet weak var friendsFilterControl: UISegmentedControl!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTextFieldLeading: NSLayoutConstraint!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchImageCenterX: NSLayoutConstraint!
    @IBOutlet weak var searchCancelButton: UIButton!
    @IBOutlet weak var searchCancelButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var charPicker: CharacterPicker!
    @IBOutlet weak var tableView: UITableView!
    private var photoService: PhotoService?
    private var sections = [FriendSection]()
    private var chosenUser: User!
    
    private let realmManager = RealmManager.shared
    private var userResults: Results<User>? {
        let users: Results<User>? = realmManager?
            .getObjects()
            .filter("name != %@", "DELETED")
        return users
    }
    private var filteredUsersNotificationToken: NotificationToken?
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Constants.greenColor
        refreshControl.attributedTitle = NSAttributedString(string: Constants.refreshTitle, attributes: [.font: UIFont.systemFont(ofSize: 12)])
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        photoService = PhotoService(container: tableView)
        setupTableView()
        setUsersRealmNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        render()
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

    private func updateFriendsData() {
        VKFriendsService().get {
            self.render()
        }
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        updateFriendsData()
        self.refreshControl.endRefreshing()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.register(UINib(nibName: Constants.friendsSectionHeader, bundle: nil), forHeaderFooterViewReuseIdentifier: Constants.friendsSectionHeader)
    }
    
    func setupSectionsChars(usersResults: Results<User>?) {
        if let users = usersResults?.toArray() as? [User] {
            let friendsDictionary = Dictionary.init(grouping: users) {$0.surname.prefix(1)}
            sections = friendsDictionary.map {FriendSection(title: String($0.key), items: $0.value)}
            sections.sort {$0.title < $1.title}
            charPicker.chars = sections.map {$0.title}
            charPicker.setupUi()
        }
    }
    
    func render() {
        switch self.friendsFilterControl.selectedSegmentIndex {
        case 0:
            setupSectionsChars(usersResults: userResults)
        default:
            setupSectionsChars(usersResults: realmManager?
                                .getObjects()
                                .filter("status == %@", 1))
            self.charPicker.isHidden = true
        }
        self.tableView.reloadData()
    }
    
    private func setUsersRealmNotification() {
        filteredUsersNotificationToken = userResults?.observe { change in
            switch change {
            case .initial(let users):
                print("Initialize \(users.count)")
                break
            case .update:
                self.render()
                break
            case .error(let error):
                let alert = Alert()
                alert.showAlert(title: "Error", message: error.localizedDescription)
                
            }
        }
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
        render()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.photoCollectionVCIdentifier {
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.friendCellIdentifier, for: indexPath) as? FriendsTableViewCell {
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
            cell.avatar.image.image = photoService?.photo(atIndexpath: indexPath, byUrl: user.avatarURL)
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
        performSegue(withIdentifier: Constants.photoCollectionVCIdentifier, sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let user = sections[indexPath.section].items[indexPath.row]
            try? realmManager?.delete(object: user)
            //реализовать удаление на api а то падает!
            sections[indexPath.section].items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if sections[indexPath.section].items.count == 0 {
                let indexSet = IndexSet(integer: indexPath.section)
                sections.remove(at: indexPath.section)
                tableView.deleteSections(indexSet, with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.friendsSectionHeader) as? HeaderView {
            header.headerLabel.text = sections[section].title
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.friendsSectionHeader) as? HeaderView {
            if section == 0 {
                header.corners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            }
        }
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
    

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = self.searchTextField.text {
            guard text != "" else {
                render()
                return
            }
            switch self.friendsFilterControl.selectedSegmentIndex {
            case 0:
                setupSectionsChars(usersResults: realmManager?
                                    .getObjects()
//добавить поиск по фамилии и сделать регистро-независимым
//let filteredUsers = users.filter({($0.name + $0.surname).lowercased().contains(text.lowercased())})
                                    .filter("name CONTAINS %@", String(text.lowercased())))
            default:
                setupSectionsChars(usersResults: realmManager?
                                    .getObjects()
                                    .filter("name CONTAINS %@", String(text.lowercased()))
                                    .filter("status == %@", 1))
                self.charPicker.isHidden = true
            }
            self.tableView.reloadData()
        }
    }

}
