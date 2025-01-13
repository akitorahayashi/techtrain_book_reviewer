//
//  MainTabBarController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    private weak var mainTabBarCoordinator: MainTabBarCoordinator?
    private weak var bookReviewListCoordinator: BookReviewListCoordinator?
    private var bookReviewListVC: BookReviewListVC
    private var createReviewVC: EditBookReviewVC
    
    init(
        mainTabBarCoordinator: MainTabBarCoordinator,
        bookReviewListCoordinator: BookReviewListCoordinator
    ) {
        self.mainTabBarCoordinator = mainTabBarCoordinator
        self.bookReviewListCoordinator = bookReviewListCoordinator
        bookReviewListVC = BookReviewListVC(bookReviewListCoordinator: bookReviewListCoordinator)
        createReviewVC = EditBookReviewVC()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle メソッド
    override func loadView() {
        super.loadView()
        setupTopNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        // UITabBarControllerDelegateのデリゲートを設定
        self.delegate = self
        
        // tabBarItemの設定
        bookReviewListVC.tabBarItem = UITabBarItem(title: "Book List", image: UIImage(systemName: "books.vertical"), tag: 0)
        createReviewVC.tabBarItem = UITabBarItem(title: "Create Review", image: UIImage(systemName: "square.and.pencil"), tag: 1)
        viewControllers = [bookReviewListVC, createReviewVC]
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
    
    // MARK: - UIのセットアップ
    
    // ナビゲーションバーを設定するメソッド
    private func setupTopNavigationBar() {
        // 中央のタイトル設定
        navigationItem.titleView = TBRNavigationBarTitle(title: "Book Reviewer")
        
        // ナビゲーションバーのbackボタンを消す
        navigationItem.hidesBackButton = true
        
        // ユーザーアイコンボタン
        let userIconButton = createUserIconButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userIconButton)
    }
    
    // ユーザーアイコンボタンを作成するメソッド
    func createUserIconButton() -> UIButton {
        let userIconButton = UIButton()
        userIconButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        userIconButton.tintColor = .accent
        userIconButton.addTarget(self, action: #selector(userIconTappedAction), for: .touchUpInside)
        userIconButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userIconButton.widthAnchor.constraint(equalToConstant: 36),
            userIconButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        return userIconButton
    }
    
    // MARK: - Button Actions
    /// ユーザーアイコンがタップされた際に呼び出されるメソッド
    @objc private func userIconTappedAction() {
        Task {
            let userName: String = await UserProfileService().getAccountData()?.name ?? "Unknown"
            let alert = UIAlertController(title: "アカウント設定: \(userName)", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "名前を変更", style: .default, handler: { [weak self] _ in
                self?.changeUserName()
            }))
            
            alert.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { [weak self] _ in
                Task {
                    await self?.mainTabBarCoordinator?.logoutToSelectAuthVC()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
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
                    let userProfileService = UserProfileService()
                    // トークン取得
                    guard let token = await userProfileService.getAccountData()?.token else {
                        // ローディング終了
                        LoadingOverlay.shared.hide()
                        TBRAlertHelper.showSingleOKOptionAlert(on: self, title: "エラー", message: "認証情報が無効です。ログインし直してください")
                        return
                    }
                    
                    // サーバーに名前変更リクエストを送信
                    do {
                        try await userProfileService.updateAndSetUserName(withToken: token, enteredNewName: newName)
                        // リフレッシュする
                        bookReviewListVC.loadReviews(offset: 0)
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
