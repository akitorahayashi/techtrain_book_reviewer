//
//  EditBookReviewVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class EditBookReviewViewController: UIViewController {
    private let editView = EditBookReviewView()
    private var bookReview: BookReview
    private let token: String
    
    init(bookReview: BookReview, token: String) {
        self.bookReview = bookReview
        self.token = token
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
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        editView.titleTextField.text = bookReview.title
        editView.urlTextField.text = bookReview.url
        editView.detailTextView.text = bookReview.detail
        editView.reviewTextView.text = bookReview.review
    }
    
    private func setupActions() {
        editView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func saveButtonTapped() {
        guard let title = editView.titleTextField.text,
              let url = editView.urlTextField.text,
              let detail = editView.detailTextView.text,
              let review = editView.reviewTextView.text else { return }
        
        BookReviewService.shared.updateBookReview(
            id: bookReview.id,
            title: title,
            url: url.isEmpty ? nil : url,
            detail: detail,
            review: review,
            token: token
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedReview):
                    self?.bookReview = updatedReview
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self?.showError(error: error)
                }
            }
        }
    }
    
    private func showError(error: TechTrainAPIClient.APIError) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to update the book review.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
