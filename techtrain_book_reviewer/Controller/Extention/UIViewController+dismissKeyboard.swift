//
//  UIViewController+dismissKeyboard.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/12.
//

import UIKit

extension UIViewController {
    func setupKeyboardDismissTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
git commit -m "UIViewControllerを拡張し、setupKeyboardDismissTapGestureを行えば、その画面をタップしたときにキーボードが消滅するようになった"
