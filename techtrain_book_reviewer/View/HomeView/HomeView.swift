//
//  HomeView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/10.
//

import UIKit

class HomeView: UIView {
    let yourAccount: TBRUser
    let bookReviewListView = BookReviewListView()
    
    init(yourAccount: TBRUser) {
        self.yourAccount = yourAccount
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        
        // BookReviewListView を追加
        addSubview(bookReviewListView)
        
        // レイアウト設定
        NSLayoutConstraint.activate([
            
            bookReviewListView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            bookReviewListView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bookReviewListView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            bookReviewListView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // NavigationBarの右上のボタンを提供
    func createUserIconButton() -> UIButton {
        let userIconButton = UIButton(type: .custom)
        
        if let iconUrlString = yourAccount.iconUrl, let iconUrl = URL(string: iconUrlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: iconUrl), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        userIconButton.setImage(image, for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        userIconButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
                        userIconButton.tintColor = .accent
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
        userIconButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        userIconButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        return userIconButton
    }
}
