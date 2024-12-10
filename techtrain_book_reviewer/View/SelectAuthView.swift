//
//  SelectAuthView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/10.
//

import UIKit

class SelectAuthView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Book Reviewer"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .accent
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let signUpButton: TBRCardButton
    let logInButton: TBRCardButton
    
    init(signUpAction: @escaping () -> Void, logInAction: @escaping () -> Void) {
        self.signUpButton = TBRCardButton(title: "Sign Up", action: signUpAction)
        self.logInButton = TBRCardButton(title: "Log In", action: logInAction)
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // タイトルラベルを追加
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50)
        ])
        
        // ボタンのスタックビューを作成
        let buttonStack = UIStackView(arrangedSubviews: [signUpButton, logInButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.alignment = .fill
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
