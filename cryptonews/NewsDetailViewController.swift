//
//  NewsDetailViewController.swift
//  cryptonews
//
//  Created by Alejandro Reyes on 2/17/18.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import UIKit

class NewsDetailViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    var news: News!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = news.title
        title = "Techcrunch.com"
        setUpGUI()
        fetchDataIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true

    }
    
    func fetchDataIfNeeded() {
        guard news.paragraphs.count == 0 else { return }
        APIEngine.getNewsBodyForNews(news: news, completion: { [weak self] (news, error) in
            guard error == nil else { /* handle error */ return; }
            self?.setUpGUI()
        })
    }
    
    func setUpGUI() {
        news.paragraphs.forEach {
            let index = news.paragraphs.index(of: $0)
            var formattedParagraph = index != 0 ? "\n\n" : ""
            formattedParagraph.append($0)
            textView.text.append(formattedParagraph)
        }
        DispatchQueue.main.async { self.view.layoutIfNeeded() }
    }
}
