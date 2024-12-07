//
//  TBRInputField.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class TBRInputField: UITextField {
    init(placeholder: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.isSecureTextEntry = isSecure
        self.borderStyle = .roundedRect
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
