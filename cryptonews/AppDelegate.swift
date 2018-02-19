//
//  AppDelegate.swift
//  cryptonews
//
//  Created by Alejandro Reyes on 2/13/18.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import UIKit
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
            if error == nil {
                // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
                // params will be empty if no data found
                if let parameters = params as? [String: AnyObject] {
                    if let newsDictionary = parameters["news_object"] as? [String: AnyObject] {
                        let news = News.createOrUpdateNewsFromDictionary(dictionary: newsDictionary)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            (self.window!.rootViewController as! UINavigationController).topViewController?.showNewsDetails(news: news)
                        })
                    }
                }
            }
        })
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // pass the url to the handle deep link call
        let branchHandled = Branch.getInstance().application(application,
                                                             open: url,
                                                             sourceApplication: sourceApplication,
                                                             annotation: annotation)
        if (!branchHandled) {
            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        }
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }
}

