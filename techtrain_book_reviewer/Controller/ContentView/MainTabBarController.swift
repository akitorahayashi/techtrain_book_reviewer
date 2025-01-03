//
//  MainTabBarController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    weak var coordinator: MainTabBarCoordinatorProtocol?
    private var bookListVC = BookReviewListVC()
    private var createReviewVC = EditBookReviewVC()
    
    init(coordinator: MainTabBarCoordinatorProtocol?) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopNavigationBar()
        
        // UITabBarControllerDelegateのデリゲートを設定
        self.delegate = self
        
        // tabBarItemの設定
        bookListVC.tabBarItem = UITabBarItem(title: "Book List", image: UIImage(systemName: "books.vertical"), tag: 0)
        createReviewVC.tabBarItem = UITabBarItem(title: "Create Review", image: UIImage(systemName: "square.and.pencil"), tag: 1)
        viewControllers = [bookListVC, createReviewVC]
        tabBar.tintColor = .accent
    }
    
    // MARK: - UITabBarControllerDelegate
    /// タブが選択された際に呼び出されるメソッド
    /// "Book List" タブを選択したときにリフレッシュ
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController,
           let bookListVC = navController.viewControllers.first as? BookReviewListVC {
            bookListVC.loadReviews(offset: 0)
        }
    }
    
    // MARK: - UserNameChangeDelegate
    /// UserNameChangeDelegateプロトコルのメソッド
    /// ユーザー名が変更された際に呼び出される
//    func didChangeUserName() async {
//        if let bookListNavVC = viewControllers?.first(where: { $0 is UINavigationController }) as? UINavigationController,
//           let bookListVC = bookListNavVC.viewControllers.first as? BookReviewListVC {
//            await bookListVC.didChangeUserName()
//        }
//    }
    
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
    private func setupTopNavigationBar() {
        // 中央のタイトル設定
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
                Task {
                    await self?.coordinator?.logout()
                }
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
        alert.addAction(UIAlertAction(title: "変更", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let newName = alert.textFields?.first?.text {
                // 名前をバリデーション
                guard TBRAuthInputValidator.isValidName(newName) else { // 名前の長さが10文字以下であることを確認
                    TBRAlertHelper.showSingleOKOptionAlert(on: self, title: "エラー", message: "名前は10文字以下で空白以外の文字を含めてください。")
                    return
                }
                
                // ローディング開始
                LoadingOverlay.shared.show()
                
                Task {
                    // トークン取得
                    guard let token = UserProfileService.yourAccount?.token else {
                        // ローディング終了
                        LoadingOverlay.shared.hide()
                        TBRAlertHelper.showSingleOKOptionAlert(on: self, title: "エラー", message: "認証情報が無効です。ログインし直してください")
                        return
                    }
                    
                    // サーバーに名前変更リクエストを送信
                    do {
                        try await UserProfileService.updateUserName(withToken: token, newName: newName)
                        // リフレッシュする
                        bookListVC.loadReviews(offset: 0)
                        TBRAlertHelper.showSingleOKOptionAlert(on: self, title: "成功", message: "名前が変更されました")
                    } catch let serviceError {
                        TBRAlertHelper.showErrorAlert(on: self, message: serviceError.localizedDescription)
                    }
                }
                // ローディング終了
                LoadingOverlay.shared.hide()
                
            }
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
