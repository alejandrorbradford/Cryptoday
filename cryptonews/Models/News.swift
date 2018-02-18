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
    @objc dynamic var publishedDate = Date(timeIntervalSince1970: 1)
    @objc dynamic var author = ""
    @objc dynamic var title = ""
    @objc dynamic var shortDescription = ""
    @objc dynamic var url = ""
    @objc dynamic var imageUrl = ""
    @objc dynamic var newsID = ""
    var paragraphs = List<String>()
    @objc dynamic var isBookmarked = false
    
    override static func primaryKey() -> String? {
        return "newsID"
    }
    
    static func importNewsFromDictionaryArray(dictionaries: [[String:Any]]) -> [News] {
        var newsArray = [News]()
        for dictionary in dictionaries {
            let news = createOrUpdateNewsFromDictionary(dictionary: dictionary)
            newsArray.append(news)
        }
        do {
            let realm = try Realm()
            try realm.write { realm.add(newsArray, update: true) }
        } catch {
            print(error)
        }
        return newsArray
    }
    
    static func createOrUpdateNewsFromDictionary(dictionary: [String:Any]) -> News {
        let publishedDateString = dictionary["publishedAt"] as! String
        guard let news = getOrCreateNewsWithID(newsID: publishedDateString) else { preconditionFailure() }
        do {
            let realm = try Realm()
            realm.beginWrite()
            news.author = dictionary["author"] as! String
            news.title = dictionary["title"] as! String
            news.shortDescription = dictionary["description"] as! String
            news.url = dictionary["url"] as! String
            news.imageUrl = dictionary["urlToImage"] as! String
            let dateFormatter = ISO8601DateFormatter()
            let creationDate = dateFormatter.date(from:publishedDateString)!
            news.publishedDate = creationDate
            try realm.commitWrite()
        } catch {
            print(error)
        }
        return news
    }
    
    static func getOrCreateNewsWithID(newsID: String) -> News? {
        do {
            let realm = try Realm()
            let query = (realm.objects(News.self).toArray() as! [News]).filter { $0.newsID == newsID }
            if query.count > 0 { return query.first! } else { let news = News(); news.newsID = newsID; return news }
        } catch {
            print(error)
            return nil
        }
    }
}
