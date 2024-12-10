//
//  HomeVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/09.
//

import UIKit

class HomeViewController: UIViewController {
    private var tbrUser: TBRUser
    
    init(tbrUser: TBRUser) {
        self.tbrUser = tbrUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Book Reviewer"
        
        // NavigationBarのタイトルの色を.accentに設定
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.accent,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        // 左のBackボタンを非表示
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
        
        navigationItem.rightBarButtonItem = setupUserIcon()
        
        
        // ユーザー名を左上に表示
        let titleLabel = UILabel()
        titleLabel.text = tbrUser.name
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .accent
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }
    
    private func setupUserIcon() -> UIBarButtonItem {
        // UIButtonを作成
        let button = UIButton(type: .custom)

        // アイコン画像を設定
        if let iconUrlString = tbrUser.iconUrl, let iconUrl = URL(string: iconUrlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: iconUrl), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        button.setImage(image, for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
                        button.tintColor = .accent
                    }
                }
            }
        } else {
            button.setImage(UIImage(systemName: "person.circle"), for: .normal)
            button.tintColor = .accent
        }
        
        button.layer.cornerRadius = 18
        button.clipsToBounds = true

        // タップイベントを追加
        button.addTarget(self, action: #selector(userIconTapped), for: .touchUpInside)

        // UIButtonをUIBarButtonItemにラップして返す
        return UIBarButtonItem(customView: button)
    }

    
    
    @objc private func userIconTapped() {
        // ドロワーを表示
        let alert = UIAlertController(title: "アカウント設定", message: nil, preferredStyle: .actionSheet)
        
        // 名前変更
        alert.addAction(UIAlertAction(title: "名前を変更", style: .default, handler: { [weak self] _ in
            self?.changeUserName()
        }))
        
        // ログアウト
        alert.addAction(UIAlertAction(title: "ログアウト", style: .default, handler: { [weak self] _ in
            self?.logout()
        }))
        
        // アカウント削除
        alert.addAction(UIAlertAction(title: "アカウントを削除", style: .destructive, handler: { [weak self] _ in
            self?.deleteAccount()
        }))
        
        // キャンセル
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    private func changeUserName() {
        let alert = UIAlertController(title: "名前を変更", message: "新しい名前を入力してください", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "新しい名前"
        }
        alert.addAction(UIAlertAction(title: "変更", style: .default, handler: { [weak self] _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                self?.tbrUser.name = newName
                self?.setupUI()
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func logout() {
        print("ログアウトしました")
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func deleteAccount() {
        let alert = UIAlertController(title: "アカウント削除", message: "本当にアカウントを削除しますか？この操作は取り消せません。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { [weak self] _ in
            print("アカウントを削除しました")
            self?.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
