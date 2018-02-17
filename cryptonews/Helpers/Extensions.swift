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
}

extension UIColor {
    static func cryptoBlack() -> UIColor {
        return UIColor.init(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1)
    }
}
