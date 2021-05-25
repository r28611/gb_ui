//
//  NewsPostViewModelFactory.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 24.05.2021.
//

import UIKit

final class NewsPostViewModelFactory {
    
    func constructViewModels(from news: [NewsPost], users: [Int: User], groups: [Int: Group]) -> [NewsPostViewModel] {
        
        return news.compactMap() { newsPost in
            var authorName: String
            var authorAvatar: String
            if newsPost.sourceID > 0 {
                authorName = users[newsPost.sourceID]!.name
                authorAvatar = users[newsPost.sourceID]!.avatarURL
            } else {
                authorName = groups[-newsPost.sourceID]!.name
                authorAvatar = groups[-newsPost.sourceID]!.avatarURL
            }
            return self.viewModel(from: newsPost, authorName: authorName, authorAvatarURL: authorAvatar) }
    }
    
    private func viewModel(from newsPost: NewsPost, authorName: String, authorAvatarURL: String) -> NewsPostViewModel {
        let avatar = UIImageView()

            avatar.load(url: URL(string: authorAvatarURL)!)
        
        let newsText = newsPost.text
        let date = NewsPostViewModelFactory.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(newsPost.date)))
        
        return NewsPostViewModel(authorName: authorName,
                                 authorAvatar: avatar,
                                 date: date,
                                 newsText: newsText,
                                 attachment: newsPost.attachments,
                                 likes: newsPost.likes,
                                 views: newsPost.views,
                                 reposts: newsPost.reposts,
                                 comments: newsPost.comments)
    }
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH.mm"
        return dateFormatter
    }()
}
