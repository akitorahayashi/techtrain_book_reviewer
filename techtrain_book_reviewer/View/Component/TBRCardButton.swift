//
//  TBRCardButton.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class TBRCardButton: UIView {
    private let titleLabel = UILabel()


    init(title: String, action: @escaping () -> Void) {
        super.init(frame: .zero)
        setupUI(title: title)
        addTapGesture(action: action)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(title: String) {
        backgroundColor = .systemGray6
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4

        titleLabel.text = title
        titleLabel.textColor = .accent
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    // メモリのアドレスをactionKeyとして使用
    private static var actionKey: Void? = nil

    private func addTapGesture(action: @escaping () -> Void) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
        // メモリアドレスをキーとして保存
        objc_setAssociatedObject(self, &TBRCardButton.actionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    @objc private func handleTap() {
        // メモリアドレスをキーとして動作を取得
        if let action = objc_getAssociatedObject(self, &TBRCardButton.actionKey) as? () -> Void {
            action()
        }
    }
}