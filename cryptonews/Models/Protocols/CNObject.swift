//
//  CNObject.swift
//  cryptonews
//
//  Created by Miguel Alcantara on 21/03/2018.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import RealmSwift

@objc protocol CNObject {
    @objc optional func importDataFromDictionaryArray(dictArray: [[String: AnyObject]]) -> Object
    @objc optional func updateDataFromDictionaryArray(dictArray: [[String: AnyObject]]) -> Object
    func importFromDictionary(dict: [String: AnyObject]) -> Object
}
