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
        setupButtonActions()
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Setup View
    private func loadBookDetail()  {
        // ローディング開始
        LoadingOverlay.shared.show()
        Task {
            guard let token = await SecureTokenService.shared.getTokenAfterLoad(on: self) else { return }
            do {
                let bookDetail = try await BookReviewService.shared.fetchAndReturnBookReviewDetail(id: bookId, token: token)
                self.updateUI(with: bookDetail)
            } catch let serviceError {
                TBRAlertHelper.showErrorAlert(on: self, message: serviceError.localizedDescription)
            }
            // ローディング終了
            LoadingOverlay.shared.hide()
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
    
    // MARK: - Setup Actions
    private func setupButtonActions() {
        detailView?.openUrlButton.addTarget(self, action: #selector(openInBrowserTapped), for: .touchUpInside)
        detailView?.backButton.addTarget(self, action: #selector(backToListTapped), for: .touchUpInside)
        detailView?.editButton.addTarget(self, action: #selector(navigateToEditView), for: .touchUpInside)
        detailView?.deleteButton.addTarget(self, action: #selector(confirmAndDeleteBookReview), for: .touchUpInside)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openInBrowserTapped))
//        detailView?.urlContent.isUserInteractionEnabled = true
//        detailView?.urlContent.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - Button Actions
    @objc private func openInBrowserTapped() {
        guard let urlString = detailView?.urlContent.text, let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            TBRAlertHelper.showSingleOKOptionAlert(on: self, title: "エラー", message: "URLが無効です")
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc private func backToListTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func navigateToEditView() {
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
    
    // レビューを削除する
    private func deleteBookReview() {
        Task {
            // ローディング開始
            LoadingOverlay.shared.show()
            guard let token = await SecureTokenService.shared.getTokenAfterLoad(on: self) else { return }
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
