//
//  BookDetailView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookDetailView: UIView {
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let reviewLabel = UILabel()
    let openUrlButton: TBRCardButton
    let backButton: TBRCardButton
    let editButton: TBRCardButton
    let deleteButton: TBRCardButton
    
    private var onBackAction: (() -> Void)?
    var bookUrl: String
    private var isMine: Bool?
    
    init(title: String, detail: String, review: String, url: String, isMine: Bool?, onBack: @escaping () -> Void) {
        self.openUrlButton = TBRCardButton(title: "Browser", action: {})
        self.backButton = TBRCardButton(title: "List", action: {})
        self.editButton = TBRCardButton(title: "Edit", action: {})
        self.deleteButton = TBRCardButton(title: "Delete", action: {})
        self.bookUrl = url
        self.isMine = isMine
        self.onBackAction = onBack
        super.init(frame: .zero)
        setupUI()
        setupActions()
        updateUI(title: title, detail: detail, review: review, url: bookUrl, isMine: isMine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Scroll View
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        // Content View
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Detail Label
        detailLabel.font = UIFont.systemFont(ofSize: 16)
        detailLabel.numberOfLines = 0
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Review Label
        reviewLabel.font = UIFont.systemFont(ofSize: 16)
        reviewLabel.numberOfLines = 0
        reviewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(reviewLabel)
        
        // Button Stack
        let buttonStack = UIStackView(arrangedSubviews: [deleteButton, editButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.alignment = .center
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)
        
        // Navigation Buttons Stack
        let navButtonStack = UIStackView(arrangedSubviews: [backButton, openUrlButton])
        navButtonStack.axis = .horizontal
        navButtonStack.spacing = 16
        navButtonStack.alignment = .center
        navButtonStack.distribution = .fillEqually
        navButtonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navButtonStack)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Detail Label
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Review Label
            reviewLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 16),
            reviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Button Stack
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
            buttonStack.bottomAnchor.constraint(equalTo: navButtonStack.topAnchor, constant: -16),
            
            // Navigation Button Stack
            navButtonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            navButtonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            navButtonStack.heightAnchor.constraint(equalToConstant: 44),
            navButtonStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        openUrlButton.addTapGesture { [weak self] in
            self?.openUrl()
        }
        backButton.addTapGesture { [weak self] in
            self?.onBackAction?()
        }
    }
    
    private func openUrl() {
        guard let url = URL(string: bookUrl) else {
            showAlert(title: "Error", message: "Invalid or missing URL")
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { success in
            if !success {
                self.showAlert(title: "Error", message: "Unable to open the URL in the browser.")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        guard let viewController = findViewController() else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func findViewController() -> UIViewController? {
        var nextResponder: UIResponder? = self
        while let responder = nextResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            nextResponder = responder.next
        }
        return nil
    }
    
    func updateUI(title: String, detail: String, review: String, url: String, isMine: Bool?) {
        titleLabel.text = title
        detailLabel.text = detail
        reviewLabel.text = review
        self.isMine = isMine
        
        // Edit & Delete Buttons の表示/非表示
        editButton.isHidden = !(isMine ?? false)
        deleteButton.isHidden = !(isMine ?? false)
    }
}
