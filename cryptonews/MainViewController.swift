import UIKit
import RealmSwift
import Imaginary

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var refresher:UIRefreshControl!
    
    var news = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "News"
        refresher = UIRefreshControl()
        collectionView!.alwaysBounceVertical = true
        refresher.tintColor = .gray
        refresher.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        collectionView!.addSubview(refresher)
        
        
        let realm = try! Realm()
        news = (realm.objects(News.self).toArray() as! [News]).sorted { $0.publishedDate < $1.publishedDate }
        fetchData()
    }
    
    // MARK: Fetch
    @objc func fetchData() {
        APIEngine.getAllRecentNews { [weak self] (news, error) in
            guard let strongSelf = self else { return }
            guard let news = news else { return }
            // TODO: Error handling
            let newNews = news.filter { !strongSelf.news.contains($0) }
            strongSelf.news.append(contentsOf: newNews)
            strongSelf.news = strongSelf.news.sorted { $0.publishedDate < $1.publishedDate }
            strongSelf.collectionView.reloadData()
            if strongSelf.refresher.isRefreshing { strongSelf.refresher.endRefreshing() }
        }
    }
    
    // MARK: Collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return news.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        let news = self.news[indexPath.row]
        cell.titleLabel.text = news.title
        cell.publisher.text = news.author
        if let url = URL(string: news.imageUrl) { cell.imageView.setImage(url: url) }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width-34, height: 359)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 4, bottom: 24, right: 4)
    }
}

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var publisher: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        
        DispatchQueue.main.async {
        let maskPath = UIBezierPath.init(roundedRect: self.imageView.bounds, byRoundingCorners:[.bottomRight, .bottomLeft], cornerRadii: CGSize.init(width: 10.0, height: 10.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.imageView.bounds
        maskLayer.path = maskPath.cgPath
        self.imageView.layer.mask = maskLayer
        self.imageView.layer.masksToBounds = true
        }
        
        // shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 4.0
        self.layer.masksToBounds = false
    
    }
    
}
