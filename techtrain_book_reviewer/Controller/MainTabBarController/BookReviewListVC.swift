//
//  BookReviewListVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookReviewListViewController: UIViewController {
    private let bookReviewListView = BookReviewListView()
    private let refreshControl = UIRefreshControl()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        view.addSubview(bookReviewListView)
        bookReviewListView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bookReviewListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bookReviewListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bookReviewListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bookReviewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        loadInitialReviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshReviews()
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshReviews), for: .valueChanged)
        bookReviewListView.tableView.refreshControl = refreshControl
    }
    
    private func loadInitialReviews() {
        loadReviews(offset: 0)
    }
    
    @objc private func refreshReviews() {
        loadReviews(offset: 0) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func loadReviews(offset: Int, completion: (() -> Void)? = nil) {
        bookReviewListView.loadBookReviews(offset: offset, completion: completion)
    }
}
