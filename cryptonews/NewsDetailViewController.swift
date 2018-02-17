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
    
    @IBOutlet var titleLabel: UILabel!
    var news: News!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = news.title
        title = "Techcrunch.com"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true

    }
}
