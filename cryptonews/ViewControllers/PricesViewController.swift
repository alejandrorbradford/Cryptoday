//
//  PricesViewController.swift
//  cryptonews
//
//  Created by Alejandro Reyes on 3/1/18.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import UIKit

class PricesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var selectedCrypto: Cryptocurrency!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CryptoTableViewCell", for: indexPath) as! CryptoTableViewCell
        return cell
    }
}

class CryptoTableViewCell: UITableViewCell {
    @IBOutlet var cryptImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var marketCapLabel: UILabel!
    @IBOutlet var volumeLabel: UILabel!
    
}
