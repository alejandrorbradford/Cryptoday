//
//  MainViewController+Prices.swift
//  cryptonews
//
//  Created by Alejandro Reyes on 2/21/18.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import UIKit

class CoinCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var symbolLabel: UILabel!
    var crypto: Cryptocurrency! { didSet { updateUI() }}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10
    }
    
    func updateUI() {
        symbolLabel.text = crypto.symbol
        priceLabel.text = crypto.priceUSD
    }
}
