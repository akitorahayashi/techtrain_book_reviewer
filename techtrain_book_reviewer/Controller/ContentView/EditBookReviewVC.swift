//
//  EditBookReviewVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class EditBookReviewVC: UIViewController {
    private weak var editBookReviewCoordinator: EditBookReviewCoordinatorProtocol?
    private let editView: EditBookReviewView
    private let corrBookReview: BookReview? // nilの場合は新規作成
    
    init(corrBookReview: BookReview? = nil) {
        self.corrBookReview = corrBookReview
        self.editView = EditBookReviewView(corrBookReview: corrBookReview)
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
        setupEditBookReviewViewButtonAction()
        setupKeyboardDismissTapGesture()
        
        // 編集の場合はデータ取得、新規作成の場合はUI設定
        if let review = self.corrBookReview {
            self.populateFields(with: review)
        }
    }
    
    // MARK: - EditBookReviewViewのボタンのセットアップ
    private func setupEditBookReviewViewButtonAction() {
        editView.compliteButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        editView.clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - 編集時データ取得
    private func fetchBookDetailsForEdit(reviewId: String) async {
        guard let token = await SecureTokenService.shared.getTokenAfterLoad(on: self) else { return }
        // ローディング開始
        LoadingOverlay.shared.show()
        do {
            let fetchedBookReviewDetail = try await BookReviewService.shared.fetchAndReturnBookReviewDetail(id: reviewId, token: token)
            await MainActor.run { [weak self] in
                self?.populateFields(with: fetchedBookReviewDetail)
            }
        } catch let serviceError {
            TBRAlertHelper.showErrorAlert(on: self, message: serviceError.localizedDescription)
        }
        // ローディング終了
        LoadingOverlay.shared.hide()
    }
    
    private func populateFields(with bookReview: BookReview) {
        editView.titleTextField.text = bookReview.title
        editView.urlTextField.text = bookReview.url
        editView.detailInputField.text = bookReview.detail
        editView.reviewInputField.text = bookReview.review
    }
    
    // MARK: - 保存/投稿処理
    @objc private func saveButtonTapped() {
        Task {
            if corrBookReview == nil {
                await createReviewAsync() // 新規作成
            } else {
                await updateReviewAsync() // 編集
            }
        }
    }
    
    private func createReviewAsync() async {
        guard validateInputs(),
              let token = await SecureTokenService.shared.getTokenAfterLoad(on: self),
              let title = editView.titleTextField.text,
              let url = editView.urlTextField.text,
              let detail = editView.detailInputField.text,
              let review = editView.reviewInputField.text else { return }
        // ローディング開始
        LoadingOverlay.shared.show()
        do {
            // A successful response. が返ってきただけなので使わない
            let _  = try await BookReviewService.shared.postBookReview(
                title: title,
                url: url,
                detail: detail,
                review: review,
                token: token
            )
            TBRAlertHelper.showSingleOKOptionAlert(on: self, title: "成功", message: "レビューが投稿されました") { [weak self] _ in
                self?.clearFields()
            }
        } catch let serviceError {
            TBRAlertHelper.showErrorAlert(on: self, message: serviceError.localizedDescription)
        }
        LoadingOverlay.shared.hide()
    }
    
    private func updateReviewAsync() async {
        guard validateInputs(),
              let token = await SecureTokenService.shared.getTokenAfterLoad(on: self),
              let title = editView.titleTextField.text,
              let url = editView.urlTextField.text,
              let detail = editView.detailInputField.text,
              let review = editView.reviewInputField.text, let id = corrBookReview?.id else { return }
        // ローディング開始
        LoadingOverlay.shared.show()
        do {
            let updatedBookReview = try await BookReviewService.shared.updateAndReturnBookReview(
                id: id,
                title: title,
                url: url,
                detail: detail,
                review: review,
                token: token
            )
            LoadingOverlay.shared.hide()
            TBRAlertHelper.showSingleOKOptionAlert(on: self, title: "成功", message: "レビューが更新されました") { [weak self] _ in
                self?.editBookReviewCoordinator?.navigateBookDetailAfterEditing(corrBookReview: updatedBookReview)
            }
        } catch let serviceError {
            LoadingOverlay.shared.hide()
            TBRAlertHelper.showErrorAlert(on: self, message: serviceError.localizedDescription)
        }
    }
    
    
    // MARK: - clearボタンの処理
    @objc private func clearButtonTapped() {
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
            TBRAlertHelper.showErrorAlert(on: self, message: "タイトルを入力してください")
            return false
        }
        if isBlank(text: editView.urlTextField.text) {
            TBRAlertHelper.showErrorAlert(on: self, message: "URLを入力してください")
            return false
        }
        if isBlank(text: editView.detailInputField.text) {
            TBRAlertHelper.showErrorAlert(on: self, message: "詳細を入力してください")
            return false
        }
        if isBlank(text: editView.reviewInputField.text) {
            TBRAlertHelper.showErrorAlert(on: self, message: "レビューを入力してください")
            return false
        }
        return true
    }
    
    private func isBlank(text: String?) -> Bool {
        guard let text = text else { return true }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
