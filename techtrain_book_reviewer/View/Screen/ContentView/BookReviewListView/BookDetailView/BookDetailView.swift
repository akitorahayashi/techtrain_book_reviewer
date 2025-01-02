//
//  BookDetailView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookDetailView: UIView {
    private let titleLabel = UILabel()
    private let titleDescriptionLabel = UILabel()
    private let detailLabel = UILabel()
    private let detailDescriptionLabel = UILabel()
    private let reviewLabel = UILabel()
    private let reviewDescriptionLabel = UILabel()
    let openUrlButton: TBRCardButton
    let backButton: TBRCardButton
    let editButton: TBRCardButton
    let deleteButton: TBRCardButton
    
    private var onBackAction: (() -> Void)?
    var bookUrl: String
    private var isMine: Bool?
    
    init(title: String, detail: String, review: String, url: String, isMine: Bool?, onBack: @escaping () -> Void) {
        self.openUrlButton = TBRCardButton(title: "Browser", action: {})
        self.backButton = TBRCardButton(title: "Back", action: {})
        self.editButton = TBRCardButton(title: "Edit", action: {})
        self.deleteButton = TBRCardButton(title: "Delete", action: {})
        self.bookUrl = url
        self.isMine = isMine
        self.onBackAction = onBack
        super.init(frame: .zero)
        setupUI()
        updateUI(title: title, detail: detail, review: review, url: bookUrl, isMine: isMine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIのセットアップ
    private func setupUI() {
        backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        let contentView = UIView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -200),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // テキスト関連の設定
        setupLabels(in: contentView)
        setupButtons(in: contentView)
    }
    
    private func setupLabels(in contentView: UIView) {
        [titleDescriptionLabel, titleLabel, detailDescriptionLabel, detailLabel, reviewDescriptionLabel, reviewLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // ラベルのレイアウト
        NSLayoutConstraint.activate([
            titleDescriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: titleDescriptionLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            detailDescriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            detailDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            detailLabel.topAnchor.constraint(equalTo: detailDescriptionLabel.bottomAnchor, constant: 8),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            reviewDescriptionLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 20),
            reviewDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            reviewLabel.topAnchor.constraint(equalTo: reviewDescriptionLabel.bottomAnchor, constant: 8),
            reviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        // ラベルスタイル
        titleDescriptionLabel.text = "- Title -"
        titleDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleDescriptionLabel.textColor = .gray
        
        detailDescriptionLabel.text = "- Detail -"
        detailDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 14)
        detailDescriptionLabel.textColor = .gray
        
        reviewDescriptionLabel.text = "- Review -"
        reviewDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 14)
        reviewDescriptionLabel.textColor = .gray
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        
        detailLabel.font = UIFont.systemFont(ofSize: 16)
        detailLabel.numberOfLines = 0
        
        reviewLabel.font = UIFont.systemFont(ofSize: 16)
        reviewLabel.numberOfLines = 0
    }
    
    private func setupButtons(in contentView: UIView) {
        let buttonStack = UIStackView(arrangedSubviews: [deleteButton, editButton])
        let navButtonStack = UIStackView(arrangedSubviews: [backButton, openUrlButton])
        
        [buttonStack, navButtonStack].forEach {
            $0.axis = .horizontal
            $0.spacing = 16
            $0.alignment = .center
            $0.distribution = .fillEqually
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
            
            navButtonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            navButtonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            navButtonStack.heightAnchor.constraint(equalToConstant: 44),
            navButtonStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            buttonStack.bottomAnchor.constraint(equalTo: navButtonStack.topAnchor, constant: -16)
        ])
    }
    
    // MARK: - UI更新
    func updateUI(title: String, detail: String, review: String, url: String, isMine: Bool?) {
        titleLabel.text = title
        detailLabel.text = detail
        reviewLabel.text = review
        bookUrl = url
        self.isMine = isMine
        
        // ボタンの表示/非表示
        let isUserOwner = isMine ?? false
        editButton.isHidden = !isUserOwner
        deleteButton.isHidden = !isUserOwner
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
}
