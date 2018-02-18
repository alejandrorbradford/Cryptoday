//
//  BookmarksViewController.swift
//  cryptonews
//
//  Created by Alejandro Reyes on 2/18/18.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class BookmarksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var bookmarkedNews = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bookmarks"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        do {
            let realm = try Realm()
            bookmarkedNews = (realm.objects(News.self).toArray() as! [News]).filter { $0.isBookmarked == true }
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // MARK: Tableview set up
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkedNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkTableViewCell", for: indexPath) as! BookmarkTableViewCell
        let news = bookmarkedNews[indexPath.row]
        cell.newsTitleLabel.text = news.title
        cell.newsSourceLabel.text = news.author
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = bookmarkedNews[indexPath.row]
        showNewsDetails(news: news)
    }
}

class BookmarkTableViewCell: UITableViewCell {
    @IBOutlet var newsTitleLabel: UILabel!
    @IBOutlet var newsSourceLabel: UILabel!
}
