//
//  MainTabBarController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

protocol UserNameChangeDelegate: AnyObject {
    func didChangeUserName()
}

class MainTabBarController: UITabBarController, UITabBarControllerDelegate, UserNameChangeDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        self.delegate = self
        
        // BookReviewListViewControllerにデリゲートを設定
        let bookListVC = BookReviewListViewController()
        bookListVC.userNameChangeDelegate = self
        
        let homeVC = UINavigationController(rootViewController: bookListVC)
        homeVC.tabBarItem = UITabBarItem(title: "Book List", image: UIImage(systemName: "books.vertical"), tag: 0)
        
        let createReviewVC = UINavigationController(rootViewController: EditBookReviewViewController())
        createReviewVC.tabBarItem = UITabBarItem(title: "Create Review", image: UIImage(systemName: "square.and.pencil"), tag: 1)
        
        viewControllers = [homeVC, createReviewVC]
        tabBar.tintColor = .accent
    }
    
    // MARK: - UITabBarControllerDelegate
    /// タブが選択された際に呼び出されるメソッド
    /// "Book List" タブを選択したときにリフレッシュ
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController,
           let bookListVC = navController.viewControllers.first as? BookReviewListViewController {
            // フラグを設定し、次回表示時にリフレッシュ
            bookListVC.shouldRefreshOnReturn = true
        }
    }
    
    // MARK: - UserNameChangeDelegate
    /// UserNameChangeDelegateプロトコルのメソッド
    /// ユーザー名が変更された際に呼び出される
    func didChangeUserName() {
        if let bookListNavVC = viewControllers?.first(where: { $0 is UINavigationController }) as? UINavigationController,
           let bookListVC = bookListNavVC.viewControllers.first as? BookReviewListViewController {
            bookListVC.didChangeUserName()
        }
    }
    
    // MARK: - Custom Methods
    /// ユーザーアイコンボタンを作成するメソッド
    func createUserIconButton() -> UIButton {
        let userIconButton = UIButton(type: .custom)
        
        if let iconUrlString = UserProfileService.yourAccount?.iconUrl, let iconUrl = URL(string: iconUrlString) {
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
    
    /// ナビゲーションバーを設定するメソッド
    private func setupNavigationBar() {
        // タイトル設定
        let titleLabel = UILabel()
        titleLabel.text = "Book Reviewer"
        titleLabel.textColor = UIColor.accent
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        navigationItem.titleView = titleLabel
        
        // ナビゲーションバーのbackボタンを消す
        navigationItem.hidesBackButton = true
        
        // ユーザーアイコンボタン
        let userIconButton = createUserIconButton()
        userIconButton.addTarget(self, action: #selector(userIconTapped), for: .touchUpInside)
        let userIconBarButtonItem = UIBarButtonItem(customView: userIconButton)
        navigationItem.rightBarButtonItem = userIconBarButtonItem
    }
    
    // MARK: - Button Actions
    /// ユーザーアイコンがタップされた際に呼び出されるメソッド
    @objc private func userIconTapped() {
        let userName: String = UserProfileService.yourAccount?.name ?? "Error"
        let alert = UIAlertController(title: "アカウント設定: \(userName)", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "名前を変更", style: .default, handler: { [weak self] _ in
            self?.changeUserName()
        }))
        
        alert.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { [weak self] _ in
            self?.logout()
        }))
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    /// ユーザー名を変更するアクション
    private func changeUserName() {
        let alert = UIAlertController(title: "名前を変更", message: "新しい名前を入力してください", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "新しい名前"
        }
        alert.addAction(UIAlertAction(title: "変更", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                // 名前をバリデーション
                let cleanedName = newName.replacingOccurrences(of: " ", with: "") // 空白を削除
                
                guard !cleanedName.isEmpty, // 空白削除後に空でないことを確認
                      newName.count <= 10 else { // 名前の長さが10文字以下であることを確認
                    self.showAlert(title: "エラー", message: "名前は10文字以下で空白以外の文字を含めてください。")
                    return
                }
                
                // ローディング開始
                LoadingOverlayService.shared.show()
                
                // トークン取得
                guard let token = UserProfileService.yourAccount?.token else {
                    // ローディング終了
                    LoadingOverlayService.shared.hide()
                    self.showAlert(title: "エラー", message: "認証情報が無効です。ログインし直してください。")
                    self.logout()
                    return
                }
                
                // サーバーに名前変更リクエストを送信
                UserProfileService().updateUserName(withToken: token, newName: newName) { result in
                    DispatchQueue.main.async {
                        // ローディング終了
                        LoadingOverlayService.shared.hide()
                        
                        switch result {
                        case .success:
                            print("名前の変更に成功しました")
                            UserProfileService.yourAccount?.name = newName
                            
                            self.showAlert(title: "成功", message: "名前が変更されました。")
                            
                            // デリゲートを利用してリフレッシュ通知を送る
                            self.didChangeUserName()
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
    
    /// ログアウトを実行するアクション
    private func logout() {
        UserProfileService.yourAccount = nil
        let _ = SecureTokenService.shared.deleteAPIToken()
        
        if let navigationController = navigationController {
            // 既存のスタックに SelectAuthVC があるか確認
            if !navigationController.viewControllers.contains(where: { $0 is SelectAuthVC }) {
                // SelectAuthVC がない場合は新規作成して表示
                let selectAuthVC = SelectAuthVC()
                navigationController.setViewControllers([selectAuthVC], animated: true)
            } else {
                // SelectAuthVC が既にスタックに存在する場合は戻る
                navigationController.popToViewController(
                    navigationController.viewControllers.first { $0 is SelectAuthVC }!,
                    animated: true
                )
            }
        }
        print("ログアウトしました")
    }
    
    /// アラートを表示する汎用メソッド
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
