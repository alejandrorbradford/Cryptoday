//
//  NewsDetailViewController.swift
//  cryptonews
//
//  Created by Alejandro Reyes on 2/17/18.
//  Copyright © 2018 Alejandro Reyes. All rights reserved.
//

import Foundation
import UIKit

class NewsDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var menuViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    var news: News!
    
    var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = news.title
        title = "Techcrunch.com"
        scrollView.delegate = self
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        setUpGUI()
        fetchDataIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true

    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // Move Up
            showButtonMenu()
        } else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // Move down
            if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
                // Reached Bottom
                showButtonMenu(); return
            }
            hideButtonMenu()
        }
        
    }
    
    func fetchDataIfNeeded() {
        guard news.paragraphs.count == 0 else { return }
        APIEngine.getNewsBodyForNews(news: news, completion: { [weak self] (news, error) in
            guard error == nil else { /* handle error */ return; }
            self?.setUpGUI()
        })
    }
    
    func setUpGUI() {
        news.paragraphs.forEach {
            let index = news.paragraphs.index(of: $0)
            var formattedParagraph = index != 0 ? "\n\n" : ""
            formattedParagraph.append($0)
            textView.text.append(formattedParagraph)
        }
        bottomView.layer.shadowColor = UIColor.darkGray.cgColor
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -1)
        bottomView.layer.shadowOpacity = 0.3
        bottomView.layer.shadowRadius = 1.0
        updateBookmarkButton()
    }
    
    func updateBookmarkButton() {
        bookmarkButton.setImage(news.isBookmarked ? #imageLiteral(resourceName: "bookmark-icon-filled") : #imageLiteral(resourceName: "bookmark-icon-bold"), for: .normal)
    }
    
    // MARK: Actions
    @IBAction func didTapVisitSite(_ sender: UIBarButtonItem) {
        showWebViewController(url: news.url)
    }
    
    @IBAction func didTapBookmark(_ sender: UIButton) {
        self.news.bookmark()
        updateBookmarkButton()
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    @IBAction func didTapShare(_ sender: UIButton) {
        if let link = news?.generateBranchIOLink() {
            showShareWithLink(link: link)
        } else {
            print("error generating link")
        }
    }
    
    // MARK: Animations
    func showButtonMenu() {
        UIView.animate(withDuration: 0.3) {
            self.menuViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func hideButtonMenu() {
        UIView.animate(withDuration: 0.3) {
            self.menuViewBottomConstraint.constant = -100
            self.view.layoutIfNeeded()
        }
    }
}
