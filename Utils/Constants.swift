//
//  Constants.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 21.03.2021.
//

import UIKit

class Constants {
    
    //Cells
    static let newsCellIdentifier = "NewsCell"
    static let groupCellIdentifier = "GroupCell"
    static let friendCellIdentifier = "FriendCell"
    static let photoCellIdentifier = "PhotoCell"
    
    //Headers
    static let friendsSectionHeader = "HeaderView"
    
    //Segue identifiers
    static let photoVCIdentifier = "to_photoScene"
    static let photoCollectionVCIdentifier = "to_collection"
    static let VKtabBarVC = "to_tabBarControllerVK"
    static let tabBarVC = "to_tabBarController"
    static let vkLoginWebView = "VKlogin"
    
    //Companies
    static let vkConstant = "vk.com"
    static let mailRUConstant = "mail.ru"
    
    //SessionConst
    static let clientId = "7757892"
    static let scope = "270342"

    //URLS method
    static let vkMethodGet = ".get"
    static let vkMethodSearch = ".search"
    
    // VKRequests
    static let vkGroupSearchRequest = "Swift"
    static let vkAuthViewRequest: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.vk.com"
        components.path = "/authorize"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Session.shared.clientId),
            URLQueryItem(name: "scope", value: Session.shared.scope),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.92")
        ]
        return components
    }()
    
    //URLS
    static let vkGroupsURL = "https://api.vk.com/method/groups"
    static let vkFriendsURL = "https://api.vk.com/method/friends"
    static let vkUsersURL = "https://api.vk.com/method/users"
    static let vkPhotosURL = "https://api.vk.com/method/photos"
    static let vkNewsURL = "https://api.vk.com/method/newsfeed"
    static let vkNonexistentPhotoURL = "https://vk.com/images/camera_100.png"
    static let vkNonexistentGroupPhotoURL = "https://vk.com/images/community_100.png"
    
    //Color
    static let greenColor = UIColor.turquoise
    static let pinkColor = UIColor.lightPink
    static let greyColor = UIColor.gray
    
    //Texts
    static let refreshTitle = "Reload"
    
    static func photosCollectionTitle(name: String) -> String {
        return "\(name)'s photos"
    }
    
    //Default image
    static let likedImage = UIImage(systemName: "heart.fill")
    static let unlikedImage = UIImage(systemName: "heart")
}
