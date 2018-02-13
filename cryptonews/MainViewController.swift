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
        title = "Crypto News"
        refresher = UIRefreshControl()
        collectionView!.alwaysBounceVertical = true
        refresher.tintColor = .gray
        refresher.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        collectionView!.addSubview(refresher)
        
        let realm = try! Realm()
        news = (realm.objects(News.self).toArray() as! [News]).sorted { $0.creationDate < $1.creationDate }
        fetchData()
    }
    
    // MARK: Fetch
    @objc func fetchData() {
        APIEngine.getAllRecentNews { [weak self] (news, error) in
            guard let strongSelf = self else { return }
            guard let news = news else { return }
            // TODO: Error handling
            strongSelf.news = news.sorted { $0.creationDate < $1.creationDate }
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
        cell.layer.cornerRadius = 20
        let news = self.news[indexPath.row]
        cell.titleLabel.text = news.title
        cell.imageView.setImage(url: URL(string:news.imageUrl)!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width-34, height: 380)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 4, bottom: 24, right: 4)
    }
}

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    override func draw(_ rect: CGRect) {
        titleLabel.textDropShadow()
    }
    
}
