//
//  TBRInputField.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class TBRInputField: UITextField {
    let verticalPadding: CGFloat = 20
    let horizontalPadding: CGFloat = 10

    init(placeholder: String? = nil, isSecure: Bool = false) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.isSecureTextEntry = isSecure
        self.borderStyle = .roundedRect
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // テキストが表示される領域を調整
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let inset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        return bounds.inset(by: inset)
    }

    // 編集中のテキスト領域を調整
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let inset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        return bounds.inset(by: inset)
    }
}
