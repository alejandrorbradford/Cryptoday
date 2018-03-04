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

enum TimeOptions {
    case oneHour, oneDay, sevenDays
}

class PricesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var selectedCrypto: Cryptocurrency!
    var allCryptos = [Cryptocurrency]()
    
    var currentTime: TimeOptions = .oneDay
    var timeButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Prices"
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.exitVC))
        navigationItem.leftBarButtonItem = closeButton
        timeButton = UIBarButtonItem(title: "24 Hours", style: .plain, target: self, action: #selector(self.handleTimeChange))
        navigationItem.rightBarButtonItem = timeButton
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let realm = try! Realm()
        allCryptos = (realm.objects(Cryptocurrency.self).toArray() as! [Cryptocurrency]).sorted { $0.rank < $1.rank }
        // Scroll Automaically to selected coin
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.allCryptos.index(of: self.selectedCrypto)!, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCryptos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CryptoTableViewCell", for: indexPath) as! CryptoTableViewCell
        let crypto = allCryptos[indexPath.row]
        cell.crypto = crypto
        cell.currentTime = currentTime
        return cell
    }
    
    @objc func exitVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTimeChange() {
        switch currentTime {
        case .oneHour:
            currentTime = .oneDay
            timeButton?.title = "24 Hours"
            break
        case .oneDay:
            currentTime = .sevenDays
            timeButton?.title = "7 Days"
            break
        case .sevenDays:
            currentTime = .oneHour
            timeButton?.title = "1 Hour"
            break
        }
        tableView.reloadData()
        view.layoutIfNeeded()
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
    var currentTime: TimeOptions!
    
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
            self.marketCapLabel.text = self.crypto.marketCap
            self.volumeLabel.text = self.crypto.usdVolume24h
            var percentage = self.crypto.percentageChange24h
            switch self.currentTime {
            case .oneHour:
                percentage = self.crypto.percentageChange1h
                break
            case .oneDay:
                percentage = self.crypto.percentageChange24h
                break
            case .sevenDays:
                percentage = self.crypto.percentageChange7d
                break
            default:
                break
            }
            let currentPrice = self.crypto.priceUSD
            let attributedString = NSMutableAttributedString(string:"$\(currentPrice) (\(percentage)%)")
            if let number = NumberFormatter().number(from: percentage) {
                let float = CGFloat(truncating: number)
                attributedString.setColorForText("(\(percentage)%)", with: float > 0 ? .cryptoGreen() : .red)
            }
            self.priceLabel.attributedText = attributedString
        }
    }
}
