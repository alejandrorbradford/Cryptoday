//
//  PricesViewController.swift
//  cryptonews
//
//  Created by Alejandro Reyes on 3/1/18.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class PricesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var selectedCrypto: Cryptocurrency!
    var allCryptos = [Cryptocurrency]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Prices"
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.exitVC))
        navigationItem.leftBarButtonItem = closeButton
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let realm = try! Realm()
        allCryptos = (realm.objects(Cryptocurrency.self).toArray() as! [Cryptocurrency]).sorted { $0.rank < $1.rank }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCryptos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CryptoTableViewCell", for: indexPath) as! CryptoTableViewCell
        let crypto = allCryptos[indexPath.row]
        cell.crypto = crypto
        return cell
    }
    
    @objc func exitVC() {
        dismiss(animated: true, completion: nil)
    }
    
}

class CryptoTableViewCell: UITableViewCell {
    @IBOutlet var cryptImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var marketCapLabel: UILabel!
    @IBOutlet var volumeLabel: UILabel!
    @IBOutlet var innerContentView: UIView!
    
    var crypto: Cryptocurrency! { didSet { updateUI() } }
    
    override func draw(_ rect: CGRect) {
        self.innerContentView.layer.shadowColor = UIColor.black.cgColor
        self.innerContentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.innerContentView.layer.shadowOpacity = 0.2
        self.innerContentView.layer.shadowRadius = 4.0
        self.innerContentView.layer.masksToBounds = false
    }
    
    override func prepareForReuse() {
        updateUI()
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            if let url = URL(string: self.crypto.imageUrl) { self.cryptImageView.setImage(url: url) }
            self.nameLabel.text = self.crypto.name
            self.priceLabel.text = self.crypto.priceUSD
            self.marketCapLabel.text = self.crypto.marketCap
            self.volumeLabel.text = self.crypto.usdVolume24h
        }
    }
}
