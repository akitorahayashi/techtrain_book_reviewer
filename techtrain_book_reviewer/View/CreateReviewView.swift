//
//  CreateReviewView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class CreateReviewView: UIView {
    
    // UI Elements
    let titleInputField = TBRInputField(placeholder: "タイトルを入力してください")
    let urlInputField = TBRInputField(placeholder: "書籍のURLを入力してください")
    
    let detailInputField: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.cornerRadius = 5.0
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return textView
    }()
    
    let reviewInputField: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.cornerRadius = 5.0
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return textView
    }()
    
    let submitButton = TBRCardButton(title: "レビューを投稿") {}
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Add subviews to stackView
        stackView.addArrangedSubview(titleInputField)
        stackView.addArrangedSubview(urlInputField)
        stackView.addArrangedSubview(detailInputField)
        stackView.addArrangedSubview(reviewInputField)
        stackView.addArrangedSubview(submitButton)
        
        // Add stackView to main view
        addSubview(stackView)
        
        // Set up constraints for stackView
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        // Set fixed heights for UITextView
        detailInputField.heightAnchor.constraint(equalToConstant: 90).isActive = true
        reviewInputField.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        // Set fixed height for submitButton
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
