//
//  EditBookReviewView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class EditBookReviewView: UIView, UITextViewDelegate {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    let titleTextField = TBRInputField(nil)
    private let urlLabel = UILabel()
    let urlTextField = TBRInputField(nil)
    
    private let detailLabel = UILabel()
    let detailInputField: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.cornerRadius = 5.0
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        return textView
    }()
    
    private let reviewLabel = UILabel()
    let reviewInputField: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.cornerRadius = 5.0
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        return textView
    }()
    
    
    private var reviewHeightConstraint: NSLayoutConstraint!
    private var detailHeightConstraint: NSLayoutConstraint!
    
    let compliteButton: TBRCardButton
    let clearButton: TBRCardButton
    
    init(compliteAction: @escaping () -> Void, clearAction: @escaping () -> Void) {
        self.compliteButton = TBRCardButton(title: "", action: compliteAction)
        self.clearButton = TBRCardButton(title: "", action: clearAction)
        super.init(frame: .zero)
        setupUI()
        setupDynamicHeight()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureButtons(saveButtonTitle: String, cancelButtonTitle: String) {
        compliteButton.setTitle(saveButtonTitle, for: .normal)
        clearButton.setTitle(cancelButtonTitle, for: .normal)
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        // スクロールビューとコンテンツビューの設定
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // 各ラベルの設定
        titleLabel.text = "- Title -"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .gray
        
        urlLabel.text = "- URL -"
        urlLabel.font = UIFont.boldSystemFont(ofSize: 14)
        urlLabel.textColor = .gray
        
        detailLabel.text = "- Detail -"
        detailLabel.font = UIFont.boldSystemFont(ofSize: 14)
        detailLabel.textColor = .gray
        
        reviewLabel.text = "- Review -"
        reviewLabel.font = UIFont.boldSystemFont(ofSize: 14)
        reviewLabel.textColor = .gray
        
        // 各フィールドのラベルとTextFieldのペアを作成
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, titleTextField])
        titleStack.axis = .vertical
        titleStack.spacing = 8
        
        let urlStack = UIStackView(arrangedSubviews: [urlLabel, urlTextField])
        urlStack.axis = .vertical
        urlStack.spacing = 8
        
        let detailStack = UIStackView(arrangedSubviews: [detailLabel, detailInputField])
        detailStack.axis = .vertical
        detailStack.spacing = 8
        
        let reviewStack = UIStackView(arrangedSubviews: [reviewLabel, reviewInputField])
        reviewStack.axis = .vertical
        reviewStack.spacing = 8
        
        // フォームフィールドのスタックビュー
        let inputFields: [UIView] = [titleStack, urlStack, detailStack, reviewStack]
        let stackView = UIStackView(arrangedSubviews: inputFields)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // ボタンスタックビュー（画面下部に固定）
        let buttonStackView = UIStackView(arrangedSubviews: [clearButton, compliteButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // contentViewの高さ制約
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: 300)
        ])
        
        // 動的な高さ制約の設定
        reviewHeightConstraint = reviewInputField.heightAnchor.constraint(equalToConstant: 90)
        reviewHeightConstraint.isActive = true
        
        detailHeightConstraint = detailInputField.heightAnchor.constraint(equalToConstant: 90)
        detailHeightConstraint.isActive = true
    }

    
    private func setupDynamicHeight() {
        reviewInputField.delegate = self
        detailInputField.delegate = self
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == reviewInputField {
            adjustHeight(for: textView, constraint: reviewHeightConstraint)
        } else if textView == detailInputField {
            adjustHeight(for: textView, constraint: detailHeightConstraint)
        }
    }
    
    private func adjustHeight(for textView: UITextView, constraint: NSLayoutConstraint) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        constraint.constant = max(90, size.height) // 最低高さ90を確保
    }
}
