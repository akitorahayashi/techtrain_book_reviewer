//
//  EditBookReviewVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class EditBookReviewViewController: UIViewController {
    private let editView: EditBookReviewView
    private let bookReviewId: String? // nilの場合は新規作成
    var onCompliteEditingCompletion: (() -> Void)?
    
    init(bookReviewId: String? = nil) {
        self.bookReviewId = bookReviewId
        self.editView = EditBookReviewView(
            compliteAction: {},
            clearAction: {}
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        view = editView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupActions()
        configureForCreation()
        setupKeyboardDismissTapGesture()
        
        // 編集の場合はデータ取得、新規作成の場合はUI設定
        if let id = bookReviewId {
            fetchBookDetails(reviewId: id)
        }
    }
    
    // MARK: - 具体的なアクションのセットアップ
    private func setupActions() {
        editView.compliteButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        editView.clearButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    private func configureForCreation() {
        // 新規作成用のボタンテキスト設定
        editView.compliteButton.setTitle(bookReviewId == nil ? "Post" : "Edit", for: .normal)
        editView.clearButton.setTitle("Clear", for: .normal)
    }
    
    // MARK: - データ取得
    private func fetchBookDetails(reviewId: String) {
        guard let token = getToken() else { return }
        // ローディング開始
        LoadingOverlayService.shared.show()
        BookReviewService.shared.fetchBookReview(id: reviewId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                // ローディング終了
                LoadingOverlayService.shared.hide()
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
    
    // MARK: - 保存/投稿処理
    @objc private func saveButtonTapped() {
        if bookReviewId == nil {
            createReview() // 新規作成
        } else {
            updateReview() // 編集
        }
    }
    
    private func createReview() {
        guard validateInputs(), let token = getToken() else { return }
        // ローディング開始
        LoadingOverlayService.shared.show()
        BookReviewService.shared.postBookReview(
            title: editView.titleTextField.text!,
            url: editView.urlTextField.text!,
            detail: editView.detailInputField.text!,
            review: editView.reviewInputField.text!,
            token: token
        ) { [weak self] result in
            DispatchQueue.main.async {
                // ローディング終了
                LoadingOverlayService.shared.hide()
                switch result {
                case .success:
                    self?.showAlert(title: "成功", message: "レビューが投稿されました", completion: {
                        self?.clearFields()
                    })
                case .failure(let error):
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func updateReview() {
        guard validateInputs(), let token = getToken(), let id = bookReviewId else { return }
        // ローディング開始
        LoadingOverlayService.shared.show()
        BookReviewService.shared.updateBookReview(
            id: id,
            title: editView.titleTextField.text!,
            url: editView.urlTextField.text!,
            detail: editView.detailInputField.text!,
            review: editView.reviewInputField.text!,
            token: token
        ) { [weak self] result in
            DispatchQueue.main.async {// ローディング終了
                LoadingOverlayService.shared.hide()
                switch result {
                case .success:
                    self?.showAlert(title: "成功", message: "レビューが更新されました", completion: {
                        self?.onCompliteEditingCompletion?()
                        self?.navigationController?.popViewController(animated: true)
                    })
                case .failure(let error):
                    self?.showError(message: "更新に失敗しました: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    // MARK: - clearボタンの処理
    @objc private func cancelButtonTapped() {
        let alert = UIAlertController(
            title: "確認",
            message: "すべての入力フィールドをクリアしますか？",
            preferredStyle: .alert
        )
        
        // 「クリア」ボタン
        alert.addAction(UIAlertAction(title: "クリア", style: .destructive, handler: { [weak self] _ in
            self?.clearFields()
        }))
        
        // 「キャンセル」ボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        
        // ダイアログを表示
        present(alert, animated: true)
    }
    
    private func clearFields() {
        editView.titleTextField.text = ""
        editView.urlTextField.text = ""
        editView.detailInputField.text = ""
        editView.reviewInputField.text = ""
    }
    
    // MARK: - 入力バリデーション
    private func validateInputs() -> Bool {
        if isBlank(text: editView.titleTextField.text) {
            showError(message: "タイトルを入力してください。")
            return false
        }
        if isBlank(text: editView.urlTextField.text) {
            showError(message: "URLを入力してください。")
            return false
        }
        if isBlank(text: editView.detailInputField.text) {
            showError(message: "詳細を入力してください。")
            return false
        }
        if isBlank(text: editView.reviewInputField.text) {
            showError(message: "レビューを入力してください。")
            return false
        }
        return true
    }
    
    private func isBlank(text: String?) -> Bool {
        guard let text = text else { return true }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - ユーティリティ
    private func showError(message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // 呼び出し元で指定された処理を実行
            completion?()
        }))
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
