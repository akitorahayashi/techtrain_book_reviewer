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
    let editButton = TBRCardButton()
    let deleteButton = TBRCardButton()
    
    init(corrBookReview: BookReview) {
        super.init(frame: .zero)
        setupUI()
        updateUI(title: corrBookReview.title, detail: corrBookReview.detail, review: corrBookReview.review, url: corrBookReview.url, isMine: corrBookReview.isMine)
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
        
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(spacerView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            spacerView.heightAnchor.constraint(equalToConstant: 400),
            spacerView.topAnchor.constraint(equalTo: containerView.bottomAnchor),
            spacerView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
        ])
        
        
        // テキスト関連の設定
        setupLabelsAndSpacer(in: containerView)
        // ボタン関連の設定
        setupButtons()
    }
    
    private func setupLabelsAndSpacer(in contentView: UIView) {
        // ラベルの内容
        let headers: [(label: UILabel, text: String)] = [
            (titleHeader, "- Title -"),
            (detailHeader, "- Detail -"),
            (reviewHeader, "- Review -"),
            (urlHeader, "- URL -")
        ]

        let contents: [(label: UILabel, font: UIFont, color: UIColor?, lines: Int)] = [
            (titleContent, UIFont.boldSystemFont(ofSize: 24), nil, 0),
            (detailContent, UIFont.systemFont(ofSize: 16), nil, 0),
            (reviewContent, UIFont.systemFont(ofSize: 16), nil, 0),
            (urlContent, UIFont.boldSystemFont(ofSize: 16), .link, 0)
        ]

        // ヘッダーの設定
        for (header, text) in headers {
            header.text = text
            header.font = UIFont.boldSystemFont(ofSize: 14)
            header.textColor = .gray
            header.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(header)
        }

        // コンテンツの設定
        for (content, font, color, lines) in contents {
            content.font = font
            content.translatesAutoresizingMaskIntoConstraints = false
            content.numberOfLines = lines
            if let textColor = color {
                content.textColor = textColor
            }
            contentView.addSubview(content)
        }
        
        // それぞれの要素のレイアウトをする
        let elements: [(header: UIView, content: UIView, topPadding: CGFloat)] = [
            (titleHeader, titleContent, 16),
            (detailHeader, detailContent, 32),
            (reviewHeader, reviewContent, 12),
            (urlHeader, urlContent, 12)
        ]

        var lastContent: UIView? = nil

        // 繰り返し処理で要素を配置
        for (header, content, spacing) in elements {
            NSLayoutConstraint.activate([
                // Header の制約
                header.topAnchor.constraint(equalTo: lastContent?.bottomAnchor ?? contentView.topAnchor, constant: spacing),
                header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                header.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
                // Content の制約
                content.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 8),
                content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            ])
            // 最後の要素を記録するため
            lastContent = content
        }

        // SpacerView を配置
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spacerView)

        NSLayoutConstraint.activate([
            spacerView.topAnchor.constraint(equalTo: lastContent?.bottomAnchor ?? contentView.topAnchor, constant: 16),
            spacerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            spacerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: 200),
            spacerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupButtons() {
        let bottomNavButtonStack = UIStackView(arrangedSubviews: [deleteButton, editButton])
        
        bottomNavButtonStack.axis = .horizontal
        bottomNavButtonStack.spacing = 16
        bottomNavButtonStack.alignment = .center
        bottomNavButtonStack.distribution = .fillEqually
        bottomNavButtonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomNavButtonStack)
        
        self.editButton.setTitle("Edit", for: .normal)
        self.deleteButton.setTitle("Delete", for: .normal)
        
        NSLayoutConstraint.activate([
            bottomNavButtonStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bottomNavButtonStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bottomNavButtonStack.heightAnchor.constraint(equalToConstant: 44),
            bottomNavButtonStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - UI更新
    func updateUI(title: String, detail: String, review: String, url: String, isMine: Bool?) {
        titleContent.text = title
        detailContent.text = detail
        reviewContent.text = review
        urlContent.text = url
        
        // 編集ボタンの表示/非表示
        let isUserOwner = isMine ?? false
        editButton.isHidden = !isUserOwner
        deleteButton.isHidden = !isUserOwner
    }
}
