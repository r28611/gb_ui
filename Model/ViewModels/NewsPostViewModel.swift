//
//  NewsPostViewModel.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 24.05.2021.
//

import UIKit

struct NewsPostViewModel {
    let authorName: String
    let authorAvatar: UIImageView
    let date: String
    let newsText: String
    let attachment: [Attachment]?
    let likes: Like
    let views: Views
    let reposts: Repost
    let comments: Comment
}
