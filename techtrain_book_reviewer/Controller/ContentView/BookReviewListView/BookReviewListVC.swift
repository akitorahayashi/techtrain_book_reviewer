//
//  BookReviewListVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookReviewListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var bookReviewListView: BookReviewListView?
    private var bookReviews: [BookReview] = []
    private var currentOffset = 0
    private let refreshControl = UIRefreshControl()
    
    override func loadView() {
        bookReviewListView = BookReviewListView()
        view = bookReviewListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
        loadReviews(offset: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookReviewListView?.reloadData()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        bookReviewListView?.tableView.delegate = self
        bookReviewListView?.tableView.dataSource = self
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshReviews), for: .valueChanged)
        bookReviewListView?.tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data Methods
    func loadReviews(offset: Int) {
        Task {
            guard let token = await UserProfileService().getAccountData()?.token else { return }
            do {
                let fetchedReviews = try await BookReviewService.shared.fetchAndReturnBookReviews(offset: offset, token: token)
                if offset == 0 {
                    bookReviews = fetchedReviews
                } else {
                    bookReviews.append(contentsOf: fetchedReviews)
                }
                currentOffset = offset + fetchedReviews.count
                await MainActor.run {
                    self.bookReviewListView?.reloadData()
                }
            } catch {
                print("Failed to load reviews: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func refreshReviews() {
        loadReviews(offset: 0)
        refreshControl.endRefreshing()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookReviewCell", for: indexPath) as? BookReviewCell else {
            return UITableViewCell()
        }
        cell.configure(with: bookReviews[indexPath.row])
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let review = bookReviews[indexPath.row]
        navigationController?.pushViewController(BookDetailVC(book: review), animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == bookReviews.count - 1 {
            loadReviews(offset: currentOffset)
        }
    }
}
