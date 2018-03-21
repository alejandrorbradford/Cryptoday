//
//  News.swift
//  cryptonews
//
//  Created by Alejandro Reyes on 2/13/18.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import RealmSwift
import Branch

class News: Object {
    @objc dynamic var publishedDate = Date(timeIntervalSince1970: 1)
    @objc dynamic var author = ""
    @objc dynamic var title = ""
    @objc dynamic var source = ""
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
        let title = dictionary["title"] as! String
        guard let news = getOrCreateNewsWithID(newsID: title) else { preconditionFailure() }
        do {
            let realm = try Realm()
            realm.beginWrite()
            news.title = title
            if let author = dictionary["author"] as? String { news.author = author }
            if let shortDescription = dictionary["description"] as? String { news.shortDescription = shortDescription }
            if let newsUrl = dictionary["url"] as? String { news.url = newsUrl }
            if let imageUrl = dictionary["urlToImage"] as? String { news.imageUrl = imageUrl }
            let dateFormatter = ISO8601DateFormatter()
            let publishedDateString = dictionary["publishedAt"] as! String
            let creationDate = dateFormatter.date(from:publishedDateString)!
            news.publishedDate = creationDate
            if let source = dictionary["source"] as? [String:Any] {
                news.source = source["name"] as! String
            }
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
    
    func toDictionary() -> [String:Any] {
        var dictionary = [String:Any]()
        dictionary["author"] = self.author
        dictionary["title"] = self.title
        dictionary["description"] = self.shortDescription
        dictionary["url"] = self.url
        dictionary["urlToImage"] = self.imageUrl
        let dateFormatter = ISO8601DateFormatter()
        let creationDate = dateFormatter.string(from:self.publishedDate)
        dictionary["publishedAt"] = creationDate
        return dictionary
    }
    
    func bookmark() {
        do {
            let realm = try Realm()
            try realm.write { self.isBookmarked = !self.isBookmarked; realm.add(self, update: true) }
        } catch {
            print(error)
        }
    }
    
    func generateBranchIOLink() -> String? {
        let branch = Branch.getInstance()
        let wrapper = [ "news_object" : self.toDictionary() ]
        if let shortLink = branch?.getShortURL(withParams: wrapper) {
            return shortLink
        }
        return nil
    }
}
