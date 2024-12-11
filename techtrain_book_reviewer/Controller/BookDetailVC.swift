//
//  BookDetailVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookDetailViewController: UIViewController {
    private let book: BookReview
    private var detailView: BookDetailView?
    
    init(book: BookReview) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        detailView = BookDetailView(
            title: book.title,
            detail: book.detail,
            review: book.review,
            url: book.url,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        )
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        
        // Backボタンを非表示
        navigationItem.hidesBackButton = true
    }
    
    private func setupActions() {
        detailView?.openUrlButton.addTapGesture { [weak self] in
            self?.openInBrowserTapped()
        }
        detailView?.backButton.addTapGesture { [weak self] in
            self?.backToListTapped()
        }
    }
    
    @objc private func openInBrowserTapped() {
        guard let urlString = book.url, let url = URL(string: urlString) else {
            showAlert(title: "エラー", message: "URLが無効です。")
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc private func backToListTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
