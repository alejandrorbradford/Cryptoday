//
//  Sentiment.swift
//  cryptonews
//
//  Created by Miguel Alcantara on 21/03/2018.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import RealmSwift

enum SentimentLabel: String {
    case none = "none"
    case negative = "neg"
    case neutral = "neutral"
    case positive = "pos"
    func description() -> String {
        switch self {
        case .negative:
            return "Negative";
        case .neutral:
            return "Neutral";
        case .positive:
            return "Positive";
        default:
            return "";
        }
    }
}

class Sentiment: Object {
    
    @objc dynamic var negativeValue: Float = 0
    @objc dynamic var neutralValue: Float = 0
    @objc dynamic var positiveValue: Float = 0
    var label: SentimentLabel = .none
    
}

extension Sentiment: CNObject {
    
    func importFromDictionary(dict: [String : AnyObject]) -> Object {
        guard dict.count > 0 else { return self; }
        if let label = dict["label"] as? String, let sentimentLabel = SentimentLabel(rawValue: label) { self.label = sentimentLabel }
        if let probabilities = dict["probability"] as? [String: AnyObject] {
            guard
                let negativeValue = probabilities["neg"] as? Float,
                let neutralValue = probabilities["neutral"] as? Float,
                let positiveValue = probabilities["pos"] as? Float
                else { return self; }
            self.negativeValue = negativeValue
            self.neutralValue = neutralValue
            self.positiveValue = positiveValue
        }
        return self;
    }
    
    func getAttributedTextForSentiment() -> NSAttributedString {
        var attributes = [NSAttributedStringKey: UIColor]()
        switch label {
            case .negative:
                attributes[NSAttributedStringKey.foregroundColor] = UIColor.red
            case .neutral:
                attributes[NSAttributedStringKey.foregroundColor] = UIColor.lightGray
            case .positive:
                attributes[NSAttributedStringKey.foregroundColor] = UIColor.green
            default:
                attributes[NSAttributedStringKey.foregroundColor] = UIColor.cryptoBlack()
        }
        return NSAttributedString(string: self.label.description(), attributes: attributes)
    }
    
    func toDictionary() -> [String: Any] {
        var dict = [String:Any]()
        dict["probability"] = [SentimentLabel.negative:negativeValue, SentimentLabel.neutral:neutralValue, SentimentLabel.positive:positiveValue]
        dict["label"] = self.label
        return dict
    }
}
