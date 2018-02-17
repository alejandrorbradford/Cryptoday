//
//  WebViewController.swift
//  cryptonews
//
//  Created by Alejandro Reyes on 2/17/18.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var urlString: String!
    
    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: urlString)
        webView.load(URLRequest(url: url!))
    }
}
