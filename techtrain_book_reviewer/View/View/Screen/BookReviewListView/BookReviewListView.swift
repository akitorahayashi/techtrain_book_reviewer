//
//  BookReviewListView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookReviewListView: UIView {
    let tableView = UITableView() // 外部からアクセス可能に
    private var bookReviews: [BookReview] = []
    private var isLoading = false
    private var currentOffset = 0
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BookReviewCell.self, forCellReuseIdentifier: "BookReviewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func resetReviews(_ reviews: [BookReview]) {
        bookReviews = reviews
        tableView.reloadData()
    }
    
    func appendReviews(_ reviews: [BookReview]) {
        bookReviews.append(contentsOf: reviews)
        tableView.reloadData()
    }
    
    func loadBookReviews(offset: Int, completion: (() -> Void)? = nil) async {
        guard !isLoading, let token = UserProfileService.yourAccount?.token else {
            completion?()
            return
        }
        
        isLoading = true
        
        do {
            self.isLoading = false
            if offset == 0 {
                // リセットする
                self.currentOffset = 0
                let bookReviewList = try await BookReviewService.shared.fetchAndReturnBookReviews(offset: currentOffset, token: token)
                self.resetReviews(bookReviewList)
            } else {
                // 追加で過去のものを表示する
                let bookReviewList = try await BookReviewService.shared.fetchAndReturnBookReviews(offset: currentOffset, token: token)
                self.appendReviews(bookReviewList)
            }
            self.currentOffset = offset + currentOffset
        } catch let serviceError {
            print("書籍レビューの取得失敗: \(serviceError.localizedDescription)")
        }
        completion?()
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
        cell.configure(with: bookReviews[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let review = bookReviews[indexPath.row]
        parentViewController?.navigationController?.pushViewController(BookDetailVC(book: review), animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        Task {
            if indexPath.row == bookReviews.count - 1 { // 最後のセルが表示されたら次をロード
                await loadBookReviews(offset: 10)
            }
        }
    }
}
