//
//  BookReviewListView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookReviewListView: UITableView {
    private var bookReviews: [BookReview] = []
    private var isLoading = false
    private var currentOffset = 0
    
    init() {
        super.init(frame: .zero, style: .plain)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        delegate = self
        dataSource = self
        register(BookReviewCell.self, forCellReuseIdentifier: "BookReviewCell")
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func resetReviews(_ reviews: [BookReview]) {
        bookReviews = reviews
        reloadData()
    }
    
    func appendReviews(_ reviews: [BookReview]) {
        bookReviews.append(contentsOf: reviews)
        reloadData()
    }
    
    func loadBookReviews(offset: Int = 0) {
        guard !isLoading, let token = UserProfileService.yourAccount?.token else { return }
        isLoading = true
        
        BookReviewService.shared.fetchBookReviews(offset: offset, token: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let newReviews):
                    if offset == 0 {
                        self.bookReviews = newReviews
                    } else {
                        self.bookReviews.append(contentsOf: newReviews)
                    }
                    self.currentOffset += newReviews.count
                    self.reloadData()
                case .failure(let error):
                    print("書籍レビューの取得失敗: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BookReviewListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookReviewCell", for: indexPath) as? BookReviewCell else {
            return UITableViewCell()
        }
        let review = bookReviews[indexPath.row]
        cell.configure(with: review)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == bookReviews.count - 1 { // 最後のセルが表示されたら次をロード
            loadBookReviews(offset: currentOffset)
        }
    }
}
