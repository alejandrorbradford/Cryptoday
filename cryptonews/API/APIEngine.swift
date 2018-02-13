import Foundation
import Alamofire

class APIEngine {
    
    static let apiUrl = "https://newsapi.org/v2/everything?sources=crypto-coins-news&apiKey=748b1a2bac844dfcb536e8d2cd888c43"
    
    static func getAllRecentNews(completion: @escaping (_ news: [News]?, _ error: Error?) -> Void) {
        Alamofire.request(apiUrl, method: .get).responseJSON { response in
            switch response.result {
            case .success:
                let value = response.value as! [String:Any]
                let news = News.importNewsFromDictionaryArray(dictionaries: value["articles"] as! [[String:Any]])
                completion(news, nil)
            case .failure(let error): completion(nil, error)
            }
        }
    }
}
