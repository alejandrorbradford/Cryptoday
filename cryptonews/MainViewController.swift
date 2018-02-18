import UIKit
import RealmSwift
import Imaginary

protocol MainCollectionViewCellDelegate: class {
    func mainCelldidTappedOnBookmarks()
}

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MainCollectionViewCellDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var refresher: UIRefreshControl!
    var bookmarkButton: UIBarButtonItem!
    
    var news = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Latest News"
        refresher = UIRefreshControl()
        collectionView!.alwaysBounceVertical = true
        refresher.tintColor = .gray
        refresher.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        collectionView!.addSubview(refresher)
        
        self.bookmarkButton = UIBarButtonItem(image: #imageLiteral(resourceName: "bookmark-icon-filled"), style: .plain, target: self, action: #selector(self.handleTouchOnBookmarks))
        bookmarkButton.tintColor = UIColor.cryptoBlack()
        self.navigationItem.rightBarButtonItem = bookmarkButton
        
        let realm = try! Realm()
        news = (realm.objects(News.self).toArray() as! [News]).sorted { $0.publishedDate > $1.publishedDate }
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
            strongSelf.news = strongSelf.news.sorted { $0.publishedDate > $1.publishedDate }
            strongSelf.collectionView.reloadData()
            if strongSelf.refresher.isRefreshing { strongSelf.refresher.endRefreshing() }
        }
    }
    
    // MARK: Collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let news = self.news[indexPath.row]
        showNewsDetails(news: news)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return news.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        let news = self.news[indexPath.row]
        cell.delegate = self
        cell.news = news
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width-34, height: 380)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 4, bottom: 24, right: 4)
    }
    
    // MARK: Actions
    @objc func handleTouchOnBookmarks() {
        
    }
    
    // MARK: Delegates
    func mainCelldidTappedOnBookmarks() {
        navigationItem.rightBarButtonItem = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.navigationItem.rightBarButtonItem = self.bookmarkButton
        }
    }
}

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var publisher: UILabel!
    @IBOutlet var shadowView: UIView!
    @IBOutlet var secondShadowView: UIView!
    @IBOutlet var bookmarkButton: UIButton!

    weak var delegate: MainCollectionViewCellDelegate?
    var news: News? { didSet { self.updateUI() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 0
        self.imageView.layer.masksToBounds = true
        
        // shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 4.0
        self.layer.masksToBounds = false
        
        shadowView.layer.shadowColor = UIColor.darkGray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: -1, height: -2)
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 1.7
        
        secondShadowView.layer.shadowColor = UIColor.black.cgColor
        secondShadowView.layer.shadowOffset = CGSize(width: 1, height: 2)
        secondShadowView.layer.shadowOpacity = 0.3
        secondShadowView.layer.shadowRadius = 1.7
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func updateUI() {
        titleLabel.text = news!.title
        publisher.text = news!.author
        if let url = URL(string: news!.imageUrl) { imageView.setImage(url: url) }
        bookmarkButton.setImage(news!.isBookmarked ? #imageLiteral(resourceName: "bookmark-icon-filled") : #imageLiteral(resourceName: "bookmark-icon"), for: .normal)
    }
    
    @IBAction func didTapOnBookmark(_ sender: UIButton) {
        do {
            let realm = try Realm()
            try realm.write { news!.isBookmarked = !news!.isBookmarked; realm.add(news!, update: true) }
            updateUI()
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            delegate?.mainCelldidTappedOnBookmarks()
        } catch {
            print(error)
        }
    }
    
    @IBAction func didTapOnShare(_ sender: UIButton) {
        
    }
}
