//
//  HomeVC.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/09.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    private var homeView: HomeView?
    private var cancellables = Set<AnyCancellable>()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        guard let user = UserProfileService.yourAccount else {
            showErrorAndExit()
            return
        }
        homeView = HomeView(yourAccount: user)
        view = homeView
    }
    
    
    private func showErrorAndExit() {
        let alert = UIAlertController(
            title: "エラー",
            message: "ユーザー情報を取得できませんでした。ログインし直してください。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }))
        present(alert, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        bindUserProfileService()
    }

    private func setupNavigationBar() {
        title = "Book Reviewer"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.accent,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        // 左側のBackするためのボタンを消す
        navigationItem.hidesBackButton = true
        
        // 右側のアカウント管理のボタンを設定する
        let userIconButton = homeView?.createUserIconButton()
        userIconButton?.addTarget(self, action: #selector(userIconTapped), for: .touchUpInside)

        let userIconBarButtonItem = UIBarButtonItem(customView: userIconButton!)
        navigationItem.rightBarButtonItem = userIconBarButtonItem
    }

    private func bindUserProfileService() {
        UserProfileService.yourAccountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self else { return }
                if let user = user {
                    // HomeViewのnameLabelを更新
                    self.homeView?.updateUserName(user.name)
                } else {
                    self.showErrorAndExit()
                }
            }
            .store(in: &cancellables)
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
            guard let self = self else { return }
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                // 名前をバリデーション
                guard let cleanedName = UserProfileService().validateAndCleanName(newName) else {
                    self.showAlert(title: "エラー", message: "無効な名前です。再度入力してください。")
                    return
                }
                
                // ローディング表示
                self.showLoading()
                
                // トークン取得
                guard let token = UserProfileService.yourAccount?.token else {
                    self.hideLoading()
                    self.showAlert(title: "エラー", message: "認証情報が無効です。ログインし直してください。")
                    self.logout()
                    return
                }
                
                // サーバーに名前変更リクエストを送信
                UserProfileService().updateUserName(withToken: token, newName: cleanedName) { result in
                    DispatchQueue.main.async {
                        self.hideLoading() // ローディングを非表示
                        
                        switch result {
                        case .success:
                            print("名前の変更に成功しました")
                            UserProfileService.yourAccount?.name = cleanedName
                            UserProfileService.yourAccountPublisher.send(UserProfileService.yourAccount)
                            self.showAlert(title: "成功", message: "名前が変更されました。")
                        case .failure(let error):
                            print("名前の変更に失敗しました: \(error.localizedDescription)")
                            self.showAlert(title: "エラー", message: "名前の変更に失敗しました。再度お試しください。")
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    private func logout() {
        print("ログアウトしました")
        UserProfileService.yourAccount = nil
        UserProfileService.yourAccountPublisher.send(nil)
        navigationController?.popToRootViewController(animated: true)
    }

    private func deleteAccount() {
        let alert = UIAlertController(title: "アカウント削除", message: "本当にアカウントを削除しますか？この操作は取り消せません。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { [weak self] _ in
            print("アカウントを削除しました")
            UserProfileService.yourAccount = nil
            UserProfileService.yourAccountPublisher.send(nil)
            self?.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}


