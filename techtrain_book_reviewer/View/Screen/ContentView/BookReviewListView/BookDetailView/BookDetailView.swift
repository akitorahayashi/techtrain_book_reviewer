//
//  BookDetailView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookDetailView: UIView {
    // title
    private let titleHeader = UILabel()
    private let titleContent = UILabel()
    // detail
    private let detailHeader = UILabel()
    private let detailContent = UILabel()
    // review
    private let reviewHeader = UILabel()
    private let reviewContent = UILabel()
    // url
    private let urlHeader = UILabel()
    let urlContent = UILabel()
    // buttons
    let openUrlButton = TBRCardButton(title: "Browser")
    let backButton = TBRCardButton(title: "Back")
    let editButton = TBRCardButton(title: "Edit")
    let deleteButton = TBRCardButton(title: "Delete")
    
    private var onBackAction: (() -> Void)?
    private var isMine: Bool?
    
    init(title: String, detail: String, review: String, url: String, isMine: Bool?, onBack: @escaping () -> Void) {
        self.isMine = isMine
        self.onBackAction = onBack
        super.init(frame: .zero)
        setupUI()
        updateUI(title: title, detail: detail, review: review, url: url, isMine: isMine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIのセットアップ
    private func setupUI() {
        backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -200)
        ])
        
        
        // テキスト関連の設定
        setupLabels(in: containerView)
        // ボタン関連の設定
        setupButtons(in: containerView)
    }
    
    private func setupLabels(in contentView: UIView) {
        [titleHeader, titleContent, urlHeader, urlContent, detailHeader, detailContent, reviewHeader, reviewContent].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // ラベルの内容
        titleHeader.text = "- Title -"
        titleHeader.font = UIFont.boldSystemFont(ofSize: 14)
        titleHeader.textColor = .gray
        
        detailHeader.text = "- Detail -"
        detailHeader.font = UIFont.boldSystemFont(ofSize: 14)
        detailHeader.textColor = .gray
        
        reviewHeader.text = "- Review -"
        reviewHeader.font = UIFont.boldSystemFont(ofSize: 14)
        reviewHeader.textColor = .gray
        
        urlHeader.text = "- Url -"
        urlHeader.font = UIFont.boldSystemFont(ofSize: 14)
        urlHeader.textColor = .gray
        
        titleContent.font = UIFont.boldSystemFont(ofSize: 24)
        titleContent.numberOfLines = 0
        
        detailContent.font = UIFont.systemFont(ofSize: 16)
        detailContent.numberOfLines = 0
        
        reviewContent.font = UIFont.systemFont(ofSize: 16)
        reviewContent.numberOfLines = 0
        
        urlContent.font = UIFont.boldSystemFont(ofSize: 16)
        urlContent.numberOfLines = 0
        urlContent.textColor = .link
        
        // ラベルのレイアウト
        NSLayoutConstraint.activate([
            titleHeader.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            titleContent.topAnchor.constraint(equalTo: titleHeader.bottomAnchor, constant: 8),
            titleContent.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleContent.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            detailHeader.topAnchor.constraint(equalTo: titleContent.bottomAnchor, constant: 32),
            detailHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            detailContent.topAnchor.constraint(equalTo: detailHeader.bottomAnchor, constant: 8),
            detailContent.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailContent.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            reviewHeader.topAnchor.constraint(equalTo: detailContent.bottomAnchor, constant: 12),
            reviewHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            reviewContent.topAnchor.constraint(equalTo: reviewHeader.bottomAnchor, constant: 8),
            reviewContent.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewContent.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reviewContent.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            urlHeader.topAnchor.constraint(equalTo: reviewContent.bottomAnchor, constant: 12),
            urlHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            urlHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            urlContent.topAnchor.constraint(equalTo: urlHeader.bottomAnchor, constant: 8),
            urlContent.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            urlContent.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
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
        titleContent.text = title
        detailContent.text = detail
        reviewContent.text = review
        urlContent.text = url
        self.isMine = isMine
        
        // 編集ボタンの表示/非表示
        let isUserOwner = isMine ?? false
        editButton.isHidden = !isUserOwner
        deleteButton.isHidden = !isUserOwner
    }
    
//    private func findViewController() -> UIViewController? {
//        var nextResponder: UIResponder? = self
//        while let responder = nextResponder {
//            if let viewController = responder as? UIViewController {
//                return viewController
//            }
//            nextResponder = responder.next
//        }
//        return nil
//    }
}
