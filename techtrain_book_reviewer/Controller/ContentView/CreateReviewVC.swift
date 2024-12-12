//
//  CreateReviewVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/12.
//

import UIKit

class CreateReviewViewController: UIViewController {
    
    private var createReviewView: CreateReviewView!
    
    override func loadView() {
        createReviewView = CreateReviewView()
        view = createReviewView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    private func setupActions() {
        // Submitボタンのアクションを設定
        createReviewView.submitButton.addTapGesture(action: { [weak self] in
            self?.submitButtonTapped()
        })
    }
    
    @objc private func submitButtonTapped() {
        guard
            let title = createReviewView.titleInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty,
            let url = createReviewView.urlInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !url.isEmpty,
            let detail = createReviewView.detailInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !detail.isEmpty,
            let review = createReviewView.reviewInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !review.isEmpty
        else {
            showAlert(title: "エラー", message: "すべてのフィールドに有効な値を入力してください。")
            return
        }
        
        guard let token = UserProfileService.yourAccount?.token else {
            showAlert(title: "エラー", message: "認証情報がありません。ログインし直してください。")
            return
        }
        
        BookReviewService.shared.postBookReview(
            title: title,
            url: url,
            detail: detail,
            review: review,
            token: token
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.clearAllFields() // 成功した場合に入力欄をクリア
                    self?.showAlert(title: "成功", message: "レビューが投稿されました。")
                case .failure(let error):
                    self?.showAlert(title: "エラー", message: "レビューの投稿に失敗しました: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func clearAllFields() {
        createReviewView.titleInputField.text = ""
        createReviewView.urlInputField.text = ""
        createReviewView.detailInputField.text = ""
        createReviewView.reviewInputField.text = ""
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
