import Foundation
import Alamofire
import Kanna
import RealmSwift

class APIEngine {
    
    //Sentiment API
    static let textProcessingUrl = "http://text-processing.com/api/sentiment/"
    
    //News API
    static let ccnNewsUrl = "https://newsapi.org/v2/everything?sources=crypto-coins-news&apiKey=748b1a2bac844dfcb536e8d2cd888c43"
    static let coinMarketCapUrl = "https://api.coinmarketcap.com/v1/ticker/"
    static let coinAdditionalData = "https://www.cryptocompare.com/api/data/coinlist/"
    static let headlinesUrl1 = "https://newsapi.org/v2/everything?q=bitcoin&sources=google-news,abc-news,bloomberg,cnn,financial-times,techradar,the-wall-street-journal,vice-news,fox-news,the-telegraph,the-washington-post,wired,business-insider,cbs-news,nbc-news,techcrunch,the-new-york-times,time,bbc-news,financial-post,fortune,the-verge,the-next-web,the-huffington-post&apiKey=748b1a2bac844dfcb536e8d2cd888c43"
    static let headlinesUrl2 = "https://newsapi.org/v2/everything?q=blockchain&sources=google-news,abc-news,bloomberg,cnn,financial-times,techradar,the-wall-street-journal,vice-news,fox-news,the-telegraph,the-washington-post,wired,business-insider,cbs-news,nbc-news,techcrunch,the-new-york-times,time,bbc-news,financial-post,fortune,the-verge,the-next-web,the-huffington-post&apiKey=748b1a2bac844dfcb536e8d2cd888c43"
    static let headlinesUrl3 = "https://newsapi.org/v2/everything?q=cryptocurrency&sources=google-news,abc-news,bloomberg,cnn,financial-times,techradar,the-wall-street-journal,vice-news,fox-news,the-telegraph,the-washington-post,wired,business-insider,cbs-news,nbc-news,techcrunch,the-new-york-times,time,bbc-news,financial-post,fortune,the-verge,the-next-web,the-huffington-post&apiKey=748b1a2bac844dfcb536e8d2cd888c43"
    static let headlinesUrl4 = "https://newsapi.org/v2/everything?q=Vitalik Buterin&sources=google-news,abc-news,bloomberg,cnn,financial-times,techradar,the-wall-street-journal,vice-news,fox-news,the-telegraph,the-washington-post,wired,business-insider,cbs-news,nbc-news,techcrunch,the-new-york-times,time,bbc-news,financial-post,fortune,the-verge,the-next-web,the-huffington-post&apiKey=748b1a2bac844dfcb536e8d2cd888c43"
    static let headlinesUrl5 = "https://newsapi.org/v2/everything?q=decentralized&sources=abc-news,bloomberg,cnn,financial-times,techradar,the-wall-street-journal,vice-news,fox-news,the-telegraph,the-washington-post,wired,business-insider,cbs-news,nbc-news,techcrunch,the-new-york-times,time,bbc-news,financial-post,fortune,the-verge,the-next-web,the-huffington-post&apiKey=748b1a2bac844dfcb536e8d2cd888c43"
    
    static func getAllNews(completion: @escaping (_ news: [News]?, _ error: Error?) -> Void) {
        let urls = [ ccnNewsUrl, headlinesUrl1, headlinesUrl2, headlinesUrl3, headlinesUrl4, headlinesUrl5 ]
        let dispatchGroup = DispatchGroup()
        var news = [News]()
        for url in urls {
            dispatchGroup.enter()
            Alamofire.request(url, method: .get).responseJSON { response in
                switch response.result {
                case .success:
                    let value = response.value as! [String:Any]
                    let fetchedNews = News.importNewsFromDictionaryArray(dictionaries: value["articles"] as! [[String:Any]])
                    news.append(contentsOf: fetchedNews)
                case .failure(let error): completion(nil, error)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            let removeDuplicates = Array(Set(news))
            completion(removeDuplicates, nil)
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
    
    static func getCryptoCurrencyData(completion: @escaping (_ crypto: [Cryptocurrency]?, _ error: Error?) -> Void) {
        Alamofire.request(coinMarketCapUrl, method: .get).responseJSON { response in
            switch response.result {
            case .success:
                let value = response.value as! [[String:Any]]
                let cryptos = Cryptocurrency.importCryptosFromDictionaryArray(dictionaries: value)
                completion(cryptos, nil)
            case .failure(let error): completion(nil, error)
            }
        }
    }
    
    static func updateCryptoCurrencyAdditionalData(completion: @escaping (_ crypto: [Cryptocurrency]?, _ error: Error?) -> Void) {
        Alamofire.request(coinAdditionalData, method: .get).responseJSON { response in
            switch response.result {
            case .success:
                let value = response.value as! [String:Any]
                let data = value["Data"] as! [String:Any]
                var parsedData = [[String:Any]]()
                data.values.forEach {
                    parsedData.append($0 as! [String:Any])
                }
                let cryptos = Cryptocurrency.updateCryptoDataFromArray(dictionaries: parsedData)
                completion(cryptos, nil)
            case .failure(let error): completion(nil, error)
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

    static func getSentiment(for text: String, completion: @escaping (Sentiment?, Error?) -> ()) {
        guard let url = URL(string: textProcessingUrl) else { completion(nil, nil); return }
        let formattedText = text.replacingOccurrences(of: "\n", with: "")
        Alamofire.request(url, method: .post, parameters: ["text":formattedText], encoding: URLEncoding.default, headers: nil).responseString { (response) in
            response.result
            .ifSuccess {
                do {
                    guard let dict = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String: AnyObject] else { completion(nil, nil); return; }
                    completion(Sentiment().importFromDictionary(dict: dict) as! Sentiment, nil)
                } 
            }
            .ifFailure {
                completion(nil,response.result.error)
            }
        }
    }
    
}
