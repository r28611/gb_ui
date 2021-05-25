//
//  NewsPost.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 23.03.2021.
//

import Foundation

final class NewsPost: Decodable {
    let sourceID, date: Int
    let text: String
    let attachments: [Attachment]?
    let comments: Comment
    let likes: Like
    let reposts: Repost
    let views: Views
    let postID: Int

    enum CodingKeys: String, CodingKey {
        case sourceID = "source_id"
        case date
        case text
        case attachments
        case comments, likes, reposts, views
        case postID = "post_id"
    }
}

struct Comment: Decodable {
    let count: Int

    enum CodingKeys: String, CodingKey {
        case count
    }
}

struct Repost: Decodable {
    let count: Int

    enum CodingKeys: String, CodingKey {
        case count
    }
}

struct Views: Decodable {
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case count
    }
}

struct Attachment: Decodable {
    let type: String
    let photo: Photo?

    enum CodingKeys: String, CodingKey {
        case type, photo
    }
}
