//
//  EditBookReviewVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class EditBookReviewViewController: UIViewController {
    private let editView: EditBookReviewView
    private let bookReviewId: String
    var onSaveCompletion: (() -> Void)?
    
    init(bookReviewId: String) {
        self.bookReviewId = bookReviewId
        self.editView = EditBookReviewView(
            saveAction: { /* 保存 */ },
            cancelAction: { /* キャンセル */ }
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = editView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        fetchBookDetails()
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        editView.saveButton.addTapGesture { [weak self] in
            self?.saveReview()
        }
        editView.cancelButton.addTapGesture { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Fetch Book Details
    private func fetchBookDetails() {
        guard let token = UserProfileService.yourAccount?.token else {
            showError(message: "認証情報が見つかりません。再度ログインしてください。")
            return
        }
        
        BookReviewService.shared.fetchBookReview(id: bookReviewId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let bookReview):
                    self?.populateFields(with: bookReview)
                case .failure(let error):
                    self?.showError(message: "データ取得に失敗しました。エラー: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func populateFields(with bookReview: BookReview) {
        editView.titleTextField.text = bookReview.title
        editView.urlTextField.text = bookReview.url
        editView.detailInputField.text = bookReview.detail
        editView.reviewInputField.text = bookReview.review
    }
    
    // MARK: - Save Review
    private func saveReview() {
        guard let token = UserProfileService.yourAccount?.token else {
            showError(message: "認証情報が見つかりません。再度ログインしてください。")
            return
        }
        
        guard let title = editView.titleTextField.text,
              let url = editView.urlTextField.text,
              let detail = editView.detailInputField.text,
              let review = editView.reviewInputField.text else {
            showError(message: "全てのフィールドを正しく入力してください。")
            return
        }
        
        // 入力値のバリデーション
        if isBlank(text: title) {
            showError(message: "タイトルを入力してください。")
            return
        }
        if isBlank(text: url) {
            showError(message: "URLを入力してください。")
            return
        }
        if isBlank(text: detail) {
            showError(message: "詳細を入力してください。")
            return
        }
        if isBlank(text: review) {
            showError(message: "レビューを入力してください。")
            return
        }
        
        BookReviewService.shared.updateBookReview(
            id: bookReviewId,
            title: title,
            url: url.isEmpty ? nil : url,
            detail: detail,
            review: review,
            token: token
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.onSaveCompletion?() // 保存成功後のコールバック
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self?.showError(message: "保存に失敗しました。エラー: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - バリデーション用ヘルパー
    private func isBlank(text: String?) -> Bool {
        guard let text = text else { return true }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    
    // MARK: - Show Error
    private func showError(message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

