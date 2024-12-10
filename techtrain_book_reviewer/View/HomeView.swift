//
//  HomeView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/10.
//

import UIKit

class HomeView: UIView {
    private let tbrUser: TBRUser
    
    private let titleLabel = UILabel()
    let userIconButton = UIButton(type: .custom)
    
    init(tbrUser: TBRUser) {
        self.tbrUser = tbrUser
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // ユーザー名を左上に表示
        titleLabel.text = tbrUser.name
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .accent
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        // ユーザーアイコンを右上に表示
        setupUserIcon()
    }
    
    private func setupUserIcon() {
        if let iconUrlString = tbrUser.iconUrl, let iconUrl = URL(string: iconUrlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: iconUrl), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.userIconButton.setImage(image, for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.userIconButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
                        self.userIconButton.tintColor = .accent
                    }
                }
            }
        } else {
            userIconButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
            userIconButton.tintColor = .accent
        }
        
        userIconButton.layer.cornerRadius = 18
        userIconButton.clipsToBounds = true
        userIconButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(userIconButton)
        
        NSLayoutConstraint.activate([
            userIconButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            userIconButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            userIconButton.widthAnchor.constraint(equalToConstant: 36),
            userIconButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func updateUserName(_ name: String) {
        titleLabel.text = name
    }
}
