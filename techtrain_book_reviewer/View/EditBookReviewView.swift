//
//  EditBookReviewView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class EditBookReviewView: UIView {
    let titleTextField = TBRInputField(placeholder: "タイトル")
    let urlTextField = TBRInputField(placeholder: "URL")
    let detailTextField = TBRInputField(placeholder: "詳細")
    let reviewTextField = TBRInputField(placeholder: "レビュー")
    
    let saveButton: TBRCardButton
    let cancelButton: TBRCardButton
    
    init(saveAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        self.saveButton = TBRCardButton(title: "保存", action: saveAction)
        self.cancelButton = TBRCardButton(title: "キャンセル", action: cancelAction)
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        // ボタンスタックビュー
        let buttonStackView = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        
        // フィールドとボタンを含むスタックビュー
        let inputFields: [UIView] = [titleTextField, urlTextField, detailTextField, reviewTextField]
        
        let stackView = UIStackView(arrangedSubviews: inputFields + [buttonStackView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}
