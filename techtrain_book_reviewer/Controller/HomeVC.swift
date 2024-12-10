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
    private var cancellables = Set<AnyCancellable>() // Combineの購読を管理

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        // UserProfileService.yourAccountがnilの場合にエラー処理
        guard let user = UserProfileService.yourAccount else {
            showErrorAndExit()
            return
        }
        homeView = HomeView(tbrUser: user)
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        bindUserProfileService()
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
        homeView?.userIconButton.addTarget(self, action: #selector(userIconTapped), for: .touchUpInside)
    }

    private func bindUserProfileService() {
        // UserProfileService.yourAccountPublisherを監視してUIを更新
        UserProfileService.yourAccountPublisher
            .receive(on: DispatchQueue.main) // メインスレッドで受信
            .sink { [weak self] user in
                guard let self = self else { return }
                if let user = user {
                    self.homeView?.updateUserName(user.name)
                } else {
                    self.showErrorAndExit()
                }
            }
            .store(in: &cancellables)
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
                UserProfileService.yourAccount?.name = newName
                UserProfileService.yourAccountPublisher.send(UserProfileService.yourAccount)
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
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
