import RealmSwift

// MARK: Realm
extension Results {
    func toArray() -> [Any] {
        return self.map{$0}
    }
}

// MARK: UIKit
extension UIViewController {
    func showNewsDetails(news: News) {
        guard navigationController != nil else { print("Can't push to vc"); return }
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailVC = storyBoard.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
        newsDetailVC.news = news
        navigationController?.pushViewController(newsDetailVC, animated: true)
    }
    
    func showWebViewController(url: String) {
        guard navigationController != nil else { print("Can't push to vc"); return }
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let webVC = storyBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webVC.urlString = url
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    func showBookmarks() {
        guard navigationController != nil else { print("Can't push to vc"); return }
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let bookmarksVC = storyBoard.instantiateViewController(withIdentifier: "BookmarksViewController") as! BookmarksViewController
        navigationController?.pushViewController(bookmarksVC, animated: true)
    }
    
    func showShareWithLink(link: String) {
        let activityController = UIActivityViewController(activityItems: [ URL(string: link)!, " Check this on article I saw on the Cryptoday app!" ], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view
        activityController.excludedActivityTypes = [ .addToReadingList ]
        self.present(activityController, animated: true, completion: nil)
        
    }
    
    func showPricesVC(with crypto: Cryptocurrency) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let pricesVC = storyBoard.instantiateViewController(withIdentifier: "PricesViewController") as! PricesViewController
        pricesVC.selectedCrypto = crypto
        let navigationController = UINavigationController(rootViewController: pricesVC)
        navigationController.modalTransitionStyle = .flipHorizontal
        present(navigationController, animated: true, completion: nil)
    }
}

extension UIColor {
    static func cryptoBlack() -> UIColor {
        return UIColor.init(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1)
    }
}

extension NSMutableAttributedString {
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        }
    }
}
