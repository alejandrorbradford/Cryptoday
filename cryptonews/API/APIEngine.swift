import Foundation
import Alamofire
import Kanna
import RealmSwift

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
    
    
    static func getNewsBodyForNews(news: News, completion: @escaping (_ news: News?, _ error: Error?) -> Void) {
        Alamofire.request(news.url).responseString { response in
            if let html = response.result.value {
                self.parseHTML(html: html, news: news, completion: completion)
            } else {
                completion(nil, response.result.error)
            }
        }
    }
    
    private static func parseHTML(html: String, news: News, completion: @escaping (_ news: News?, _ error: Error?) -> Void)  {
        do { let doc = try HTML(html: html, encoding: .utf8)
            var paragraphsArray = [String]()
            for paragraph in doc.xpath("//p") {
                guard let text = paragraph.text, text != "" else { continue }
                paragraphsArray.append(text)
            }
            do {
                let realm = try Realm()
                do {
                        try realm.write { news.paragraphs.append(objectsIn: paragraphsArray)
                        completion(news, nil)
                    }
                }
                catch { completion(nil, error) }
            } catch { completion(nil, error) }
            
        } catch {
            completion(nil, error)
        }
        
    }
}
