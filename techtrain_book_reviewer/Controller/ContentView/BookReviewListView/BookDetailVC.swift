//
//  BookDetailVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookDetailVC: UIViewController {
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
        loadBookDetail()
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        navigationItem.hidesBackButton = true
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if let parent = navigationController?.viewControllers.last as? BookReviewListVC {
//            parent.shouldRefreshOnReturn = isUpdated // 親にフラグを渡す
//        }
//    }
    
    // MARK: - Setup View
    private func loadBookDetail() {
        guard let token = SecureTokenService.shared.getTokenAfterLoad(on: self) else { return }
        // ローディング開始
        LoadingOverlay.shared.show()
        Task {
            do {
                let bookDetail = try await BookReviewService.shared.fetchAndReturnBookReviewDetail(id: bookId, token: token)
                self.updateUI(with: bookDetail)
            } catch let serviceError {
                TBRAlertHelper.showErrorAlert(on: self, message: serviceError.localizedDescription)
            }
        }
        // ローディング終了
        LoadingOverlay.shared.hide()
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
    
    // MARK: - Setup Actions
    private func setupActions() {
        detailView?.openUrlButton.addTarget(self, action: #selector(openInBrowserTapped), for: .touchUpInside)
        detailView?.backButton.addTarget(self, action: #selector(backToListTapped), for: .touchUpInside)
        detailView?.editButton.addTarget(self, action: #selector(navigateToEditView), for: .touchUpInside)
        detailView?.deleteButton.addTarget(self, action: #selector(confirmAndDeleteBookReview), for: .touchUpInside)
    }
    
    
    // MARK: - User Actions
    @objc private func openInBrowserTapped() {
        guard let urlString = detailView?.bookUrl, let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            TBRAlertHelper.showSingleOKOptionAlert(on: self, title: "エラー", message: "URLが無効です")
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc private func backToListTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func navigateToEditView() {
        guard SecureTokenService.shared.getTokenAfterLoad(on: self) != nil else { return }
        
        let editVC = EditBookReviewVC(bookReviewId: bookId)
        editVC.onCompliteEditingCompletion = { [weak self] in
            print("Editing completed, refreshing data...")
            self?.isUpdated = true
            self?.loadBookDetail()
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
        guard let token = SecureTokenService.shared.getTokenAfterLoad(on: self) else { return }
        // ローディング開始
        LoadingOverlay.shared.show()
        Task {
            do {
                try await BookReviewService.shared.deleteBookReview(id: bookId, token: token)
                self.isUpdated = true
                self.navigationController?.popViewController(animated: true)
                TBRAlertHelper.showSingleOKOptionAlert(on: self, title: "成功", message: "削除されました！")
            } catch let serviceError {
                TBRAlertHelper.showErrorAlert(on: self, message: serviceError.localizedDescription)
            }
            // ローディング終了
            LoadingOverlay.shared.hide()
        }
    }
}
