//
//  BookReviewListVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookReviewListVC: UIViewController, UserNameChangeDelegate {
    weak var userNameChangeDelegate: UserNameChangeDelegate?
    
    private var bookReviewListView: BookReviewListView?
    private let refreshControl = UIRefreshControl()
    var shouldRefreshOnReturn: Bool = false
    
    override func loadView() {
        let reviewList = BookReviewListView()
        self.bookReviewListView = reviewList
        view = reviewList
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        loadInitialReviewsAsync()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldRefreshOnReturn {
            refreshReviews()
            shouldRefreshOnReturn = false // フラグをリセット
        }
    }
    
    // MARK: - UserNameChangeDelegate
    func didChangeUserName() async {
        await MainActor.run { [weak self] in
            self?.refreshReviews()
        }
    }
    
    // MARK: - Local Methods
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshReviews), for: .valueChanged)
        bookReviewListView?.tableView.refreshControl = refreshControl
    }
    
    private func loadInitialReviewsAsync() {
        Task {
            await loadReviews(offset: 0)
        }
    }
    
    @objc private func refreshReviews() {
        Task {
            await loadReviews(offset: 0) { [weak self] in
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func loadReviews(offset: Int, completion: (() -> Void)? = nil) async {
        await bookReviewListView?.loadBookReviews(offset: offset, completion: completion)
    }
}
