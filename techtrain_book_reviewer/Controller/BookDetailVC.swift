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
    
    init(book: BookReview) {
        self.bookId = book.id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private func setupActions() {
        detailView?.openUrlButton.addTapGesture { [weak self] in
            self?.openInBrowserTapped()
        }
        
        detailView?.backButton.addTapGesture { [weak self] in
            self?.backToListTapped()
        }
        
        detailView?.editButton.addTapGesture { [weak self] in
            guard let self = self else { return }
            self.navigateToEditView()
        }
    }
    
    private func fetchBookDetails() {
        guard let token = UserProfileService.yourAccount?.token else {
            showError(message: "認証情報が見つかりません。再度ログインしてください。")
            return
        }
        
        BookReviewService.shared.fetchBookReview(
            id: bookId,
            token: token
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let bookReview):
                    self?.updateUI(with: bookReview)
                case .failure(let error):
                    self?.showError(message: "データ取得に失敗しました。エラー: \(error.localizedDescription)")
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
    }
    
    private func openInBrowserTapped() {
        guard let urlString = detailView?.bookUrl, let url = URL(string: urlString) else {
            showError(message: "URLが無効です。")
            return
        }
        UIApplication.shared.open(url)
    }
    
    private func backToListTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func navigateToEditView() {
        guard let token = UserProfileService.yourAccount?.token else {
            showError(message: "認証情報が見つかりません。再度ログインしてください。")
            return
        }
        
        // 編集画面へ遷移
        let editVC = EditBookReviewViewController(bookReviewId: bookId)
        editVC.onSaveCompletion = { [weak self] in
            self?.fetchBookDetails() // 編集後にデータをリフレッシュ
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
