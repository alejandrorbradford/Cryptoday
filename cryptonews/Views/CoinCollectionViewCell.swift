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
   
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var symbolLabel: UILabel!
    var crypto: Cryptocurrency! { didSet { updateUI() }}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10
        logoImageView.layer.cornerRadius = logoImageView.frame.size.width/2
        logoImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        logoImageView.isHidden = false
    }
    
    func updateUI() {
        let attributedString = NSMutableAttributedString(string:"\(crypto.symbol) (\(crypto.percentageChange24h)%)")
        if let number = NumberFormatter().number(from: crypto.percentageChange24h) {
            let float = CGFloat(truncating: number)
            attributedString.setColorForText("(\(crypto.percentageChange24h)%)", with: float > 0 ? .green : .red)
        }
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttributes([ .font : UIFont.systemFont(ofSize: 12, weight: .bold) ], range: range)
        symbolLabel.attributedText = attributedString
        priceLabel.text = "$\(crypto.priceUSD)"
        if let url = URL(string: crypto.imageUrl) {
            logoImageView.setImage(url: url)
        } else {
            logoImageView.isHidden = true
        }
    }
}
