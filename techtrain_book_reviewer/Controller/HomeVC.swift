//
//  HomeVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/09.
//

import UIKit

class HomeViewController: UIViewController {
    private var tbrUser: TBRUser
    private var homeView: HomeView!
    
    init(tbrUser: TBRUser) {
        self.tbrUser = tbrUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        homeView = HomeView(tbrUser: tbrUser)
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
    }
    
    private func setupNavigationBar() {
        title = "Book Reviewer"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.accent,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
    }
    
    private func setupActions() {
        homeView.userIconButton.addTarget(self, action: #selector(userIconTapped), for: .touchUpInside)
    }
    
    @objc private func userIconTapped() {
        let alert = UIAlertController(title: "アカウント設定", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "名前を変更", style: .default, handler: { [weak self] _ in
            self?.changeUserName()
        }))
        
        alert.addAction(UIAlertAction(title: "ログアウト", style: .default, handler: { [weak self] _ in
            self?.logout()
        }))
        
        alert.addAction(UIAlertAction(title: "アカウントを削除", style: .destructive, handler: { [weak self] _ in
            self?.deleteAccount()
        }))
        
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
                self?.homeView.updateUserName(newName)
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
