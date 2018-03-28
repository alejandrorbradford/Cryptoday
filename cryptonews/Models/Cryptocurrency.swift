//
//  Cryptocurrency.swift
//  cryptonews
//
//  Created by Alejandro Reyes on 2/22/18.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import RealmSwift

class Cryptocurrency: Object {
    @objc dynamic var cryptoID = ""
    @objc dynamic var name = ""
    @objc dynamic var symbol = ""
    @objc dynamic var rank = 0
    @objc dynamic var priceUSD = ""
    @objc dynamic var priceBTC = ""
    @objc dynamic var usdVolume24h = ""
    @objc dynamic var marketCap = ""
    @objc dynamic var availableSupply = ""
    @objc dynamic var totalSupply = ""
    @objc dynamic var percentageChange1h = ""
    @objc dynamic var percentageChange24h = ""
    @objc dynamic var percentageChange7d = ""
    @objc dynamic var lastUpdated = Date(timeIntervalSince1970: 1)
    @objc dynamic var imageUrl = ""
    
    override static func primaryKey() -> String? {
        return "cryptoID"
    }
    
    static func importCryptosFromDictionaryArray(dictionaries: [[String:Any]]) -> [Cryptocurrency] {
        var cryptoArray = [Cryptocurrency]()
        do {
            let realm = try Realm()
            try realm.write {
                for dictionary in dictionaries {
                    let crypto = importFromDictionary(dictionary: dictionary)
                    cryptoArray.append(crypto)
                }
                realm.add(cryptoArray, update: true)
            }
        } catch {
            print(error)
        }
        return cryptoArray
    }
    
    static func updateCryptoDataFromArray(dictionaries: [[String:Any]]) -> [Cryptocurrency] {
        var cryptoArray = [Cryptocurrency]()
        do {
            let realm = try Realm()
            try realm.write {
                for dictionary in dictionaries {
                    guard let crypto = updateAdditionalData(data: dictionary) else { continue }
                    cryptoArray.append(crypto)
                }
                realm.add(cryptoArray, update: true)
            }
        } catch {
            print(error)
        }
        return cryptoArray
    }
    
    static func importFromDictionary(dictionary: [String:Any]) -> Cryptocurrency {
        let cryptoID = dictionary["symbol"] as! String
        guard let crypto = getOrCreateCryptoWithID(cryptoID: cryptoID) else { preconditionFailure() }
        crypto.name = dictionary["name"] as! String
        crypto.symbol = cryptoID
        let rankString = dictionary["rank"] as! String
        crypto.rank = NumberFormatter().number(from: rankString)!.intValue
        crypto.priceUSD = dictionary["price_usd"] as! String
        crypto.priceBTC = dictionary["price_btc"] as! String
        crypto.usdVolume24h = dictionary["24h_volume_usd"] as! String
        crypto.marketCap = dictionary["market_cap_usd"] as! String
        crypto.availableSupply = dictionary["available_supply"] as! String
        crypto.totalSupply = dictionary["total_supply"] as! String
        if let percentage1h = dictionary["percent_change_1h"] as? String { crypto.percentageChange1h = percentage1h }
        if let percentage24h = dictionary["percent_change_24h"] as? String { crypto.percentageChange24h = percentage24h }
        if let percentage7d = dictionary["percent_change_7d"] as? String { crypto.percentageChange7d  = percentage7d }
        let lastUpdatedString = dictionary["last_updated"] as! String
        let lastUpdatedDouble = NumberFormatter().number(from: lastUpdatedString)?.doubleValue
        crypto.lastUpdated = Date(timeIntervalSince1970: lastUpdatedDouble!)
        return crypto
    }
    
    static func getOrCreateCryptoWithID(cryptoID: String, shouldCreate: Bool = true) -> Cryptocurrency? {
        do {
            let realm = try Realm()
            let query = (realm.objects(Cryptocurrency.self).toArray() as! [Cryptocurrency]).filter { $0.cryptoID == cryptoID }
            if query.count > 0 { return query.first! } else if shouldCreate { let crypto = Cryptocurrency(); crypto.cryptoID = cryptoID; return crypto } else { return nil }
        } catch {
            print(error)
            return nil
        }
    }
    
    static func updateAdditionalData(data: [String:Any]) -> Cryptocurrency? {
        let cryptoID = data["Symbol"] as! String
        guard let crypto = getOrCreateCryptoWithID(cryptoID: cryptoID, shouldCreate: false) else { return nil }
        crypto.imageUrl = "https://www.cryptocompare.com\(data["ImageUrl"] as! String)"
        return crypto
    }
}
