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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10
    }
}
