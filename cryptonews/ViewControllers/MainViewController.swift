import UIKit
import RealmSwift
import Imaginary

protocol MainCollectionViewCellDelegate: class {
    func mainCelldidTappedOnBookmarks()
    func mainCelldidTappedOnShare(link: String)
}

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MainCollectionViewCellDelegate {
    
    @IBOutlet var horizontalCollectionView: UICollectionView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var bottomView: UIView!
    
    var refresher: UIRefreshControl!
    var bookmarkButton: UIBarButtonItem!
    
    var timer: Timer?
    var news = [News]()
    var coins = [Cryptocurrency]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        horizontalCollectionView.delegate = self
        horizontalCollectionView.dataSource = self
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Latest News"
        refresher = UIRefreshControl()
        collectionView!.alwaysBounceVertical = true
        refresher.tintColor = .gray
        refresher.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        collectionView!.addSubview(refresher)
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOffset = CGSize(width: 1, height: -2)
        bottomView.layer.shadowOpacity = 0.3
        bottomView.layer.shadowRadius = 1.7
        
        self.bookmarkButton = UIBarButtonItem(image: #imageLiteral(resourceName: "bookmark-icon-filled"), style: .plain, target: self, action: #selector(self.handleTouchOnBookmarks))
        bookmarkButton.tintColor = UIColor.cryptoBlack()
        self.navigationItem.rightBarButtonItem = bookmarkButton
        
        let realm = try! Realm()
        news = (realm.objects(News.self).toArray() as! [News]).sorted { $0.publishedDate > $1.publishedDate }
        coins = (realm.objects(Cryptocurrency.self).toArray() as! [Cryptocurrency]).sorted { $0.rank < $1.rank }
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.animateHorizontalCollectionView), userInfo: nil, repeats: true)
        APIEngine.updateCryptoCurrencyAdditionalData { (cryptos, error) in
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    @objc func animateHorizontalCollectionView() {
        DispatchQueue.main.async {
            let cells = self.horizontalCollectionView.visibleCells
            guard cells.count > 0 else { return }
            var indexPath = self.horizontalCollectionView.indexPath(for: cells.first!)
            if indexPath!.row == self.coins.count-1 {
                self.horizontalCollectionView.setContentOffset(.zero, animated: false)
                self.horizontalCollectionView.reloadData()
            } else {
                indexPath!.row = indexPath!.row + 1 // Next
                self.horizontalCollectionView.scrollToItem(at: indexPath!, at: .left, animated: true)
            }
        }
    }
    
    // MARK: Fetch
    @objc func fetchData() {
        APIEngine.getCcnNews { [weak self] (news, error) in
            guard let strongSelf = self else { return }
            guard let news = news else { return }
            // TODO: Error handling
            let newNews = news.filter { !strongSelf.news.contains($0) }
            strongSelf.news.append(contentsOf: newNews)
            strongSelf.news = strongSelf.news.sorted { $0.publishedDate > $1.publishedDate }
            strongSelf.collectionView.reloadData()
            if strongSelf.refresher.isRefreshing { strongSelf.refresher.endRefreshing() }
            strongSelf.fetchCryptos()
        }
    }
    
    func fetchCryptos() {
        APIEngine.getCryptoCurrencyData { [weak self] (cryptos, error) in
            guard let strongSelf = self else { return }
            guard let cryptos = cryptos else { return }
            strongSelf.coins = cryptos.sorted { $0.rank < $1.rank }
            strongSelf.horizontalCollectionView.reloadData()
        }
    }
    
    // MARK: Collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            let news = self.news[indexPath.row]
            showNewsDetails(news: news)
        } else {
            // HANDLE PRICES
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return news.count
        } else {
            return coins.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
            let news = self.news[indexPath.row]
            cell.delegate = self
            cell.news = news
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinCollectionViewCell", for: indexPath) as! CoinCollectionViewCell
            let crypto = coins[indexPath.row]
            cell.crypto = crypto
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.collectionView {
            return 24
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: UIScreen.main.bounds.width-34, height: 380)
        } else {
            return CGSize(width: (UIScreen.main.bounds.width)/2, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView ==  self.collectionView {
            return UIEdgeInsets(top: 16, left: 4, bottom: 24, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    // MARK: Actions
    @objc func handleTouchOnBookmarks() {
        showBookmarks()
    }
    
    // MARK: Delegates
    func mainCelldidTappedOnBookmarks() {
        navigationItem.rightBarButtonItem = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.navigationItem.rightBarButtonItem = self.bookmarkButton
        }
    }
    
    func mainCelldidTappedOnShare(link: String) {
        showShareWithLink(link: link)
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
        self.layer.cornerRadius = 2
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
        if news!.paragraphs.count == 0 { APIEngine.getNewsBodyForNews(news: news!, completion: { _,_ in }) }
        self.news!.bookmark()
        updateUI()
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        delegate?.mainCelldidTappedOnBookmarks()
    }
    
    @IBAction func didTapOnShare(_ sender: UIButton) {
        if let link = news?.generateBranchIOLink() {
            delegate?.mainCelldidTappedOnShare(link: link)
        } else {
            print("error generating link")
        }
    }
}
