//
//  BookDetailVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookDetailViewController: UIViewController {
    private let bookId: String
    private var detailView: BookDetailView?
    var isUpdated: Bool = false
    
    init(book: BookReview) {
        self.bookId = book.id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        detailView = BookDetailView(
            title: "",
            detail: "",
            review: "",
            url: "",
            isMine: nil,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        )
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        fetchBookDetails()
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let parent = navigationController?.viewControllers.last as? BookReviewListViewController {
            parent.shouldRefreshOnReturn = isUpdated // 親にフラグを渡す
        }
    }
    
    // MARK: - Actions Setup
    private func setupActions() {
        detailView?.openUrlButton.addTarget(self, action: #selector(openInBrowserTapped), for: .touchUpInside)
        detailView?.backButton.addTarget(self, action: #selector(backToListTapped), for: .touchUpInside)
        detailView?.editButton.addTarget(self, action: #selector(navigateToEditView), for: .touchUpInside)
        detailView?.deleteButton.addTarget(self, action: #selector(confirmAndDeleteBookReview), for: .touchUpInside)
    }
    
    // MARK: - Fetch Data
    private func fetchBookDetails() {
        guard let token = getToken() else { return }
        BookReviewService.shared.fetchBookReview(id: bookId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let bookReview):
                    print("Fetched BookReview: \(bookReview)") // ログで確認
                    self?.updateUI(with: bookReview)
                case .failure(let error):
                    self?.showError(title: "データ取得エラー", message: "データ取得に失敗しました。エラー: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateUI(with bookReview: BookReview) {
        detailView?.updateUI(
            title: bookReview.title,
            detail: bookReview.detail,
            review: bookReview.review,
            url: bookReview.url,
            isMine: bookReview.isMine ?? false
        )
        print("UI updated with: \(bookReview.title)") // UI更新のログを追加
    }
    
    // MARK: - User Actions
    @objc private func openInBrowserTapped() {
        guard let urlString = detailView?.bookUrl, let url = URL(string: urlString) else {
            showError(title: "無効なURL", message: "URLが無効です。")
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc private func backToListTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func navigateToEditView() {
        guard getToken() != nil else { return }
        
        let editVC = EditBookReviewViewController(bookReviewId: bookId)
        editVC.onCompliteEditingCompletion = { [weak self] in
            print("Editing completed, refreshing data...")
            self?.isUpdated = true
            self?.fetchBookDetails()
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc private func confirmAndDeleteBookReview() {
        let alert = UIAlertController(
            title: "削除確認",
            message: "この書籍レビューを削除しますか？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
            print("削除キャンセル") // ログで確認
        }))
        alert.addAction(UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
            self?.deleteBookReview()
        })
        
        present(alert, animated: true)
    }
    
    private func deleteBookReview() {
        guard let token = getToken() else { return }
        
        BookReviewService.shared.deleteBookReview(id: bookId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isUpdated = true
                    self?.navigationController?.popViewController(animated: true)
                    let alert = UIAlertController(title: "成功", message: "無事削除されました！", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                case .failure(let error):
                    self?.showError(title: "削除失敗", message: "削除に失敗しました: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func showError(title: String = "エラー", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func getToken() -> String? {
        guard let token = UserProfileService.yourAccount?.token else {
            showError(message: "認証情報が見つかりません。再度ログインしてください。")
            return nil
        }
        return token
    }
}
