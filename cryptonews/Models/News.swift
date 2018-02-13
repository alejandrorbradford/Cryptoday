//
//  News.swift
//  cryptonews
//
//  Created by Alejandro Reyes on 2/13/18.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import RealmSwift

class News: Object {
    @objc dynamic var creationDate = Date(timeIntervalSince1970: 1)
    @objc dynamic var author = ""
    @objc dynamic var title = ""
    @objc dynamic var shortDescription = ""
    @objc dynamic var url = ""
    @objc dynamic var imageUrl = ""
    @objc dynamic var newsID = ""
    
    override static func primaryKey() -> String? {
        return "newsID"
    }
    
    static func importNewsFromDictionaryArray(dictionaries: [[String:Any]]) -> [News] {
        var newsArray = [News]()
        for dictionary in dictionaries {
            let news = createNewsFromDictionary(dictionary: dictionary)
            newsArray.append(news)
        }
        let realm = try! Realm()
        try! realm.write { realm.add(newsArray, update: true) }
        return newsArray
    }
    
    static func createNewsFromDictionary(dictionary: [String:Any]) -> News {
        let news = News()
        news.author = dictionary["author"] as! String
        news.title = dictionary["title"] as! String
        news.shortDescription = dictionary["description"] as! String
        news.url = dictionary["url"] as! String
        news.imageUrl = dictionary["urlToImage"] as! String
        let creationDateString = dictionary["publishedAt"] as! String
        news.newsID = creationDateString
        let dateFormatter = ISO8601DateFormatter()
        let creationDate = dateFormatter.date(from:creationDateString)!
        news.creationDate = creationDate
        return news
    }
    
}
