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
    private var currentOffset = 0
    private let refreshControl = UIRefreshControl()
    private let fab = UIButton(type: .custom)
    private var isLoggingOut = false
    
    override func loadView() {
        guard let user = UserProfileService.yourAccount else {
            showErrorAndExit()
            return
        }
        homeView = HomeView(yourAccount: user)
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupRefreshControl()
        setupFloatingActionButton()
//        bindUserProfileService()
        loadInitialReviews()
    }
    
    // MARK: - Load Reviews
    private func loadInitialReviews() {
        loadReviews(offset: 0)
    }
    
    @objc private func refreshReviews() {
        loadReviews(offset: 0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func loadMoreReviews() {
        loadReviews(offset: currentOffset)
    }
    
    private func loadReviews(offset: Int, completion: (() -> Void)? = nil) {
        guard let token = UserProfileService.yourAccount?.token else { return }
        
        BookReviewService.shared.fetchBookReviews(offset: offset, token: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let newReviews):
                    if offset == 0 {
                        self.homeView?.bookReviewListView.resetReviews(newReviews)
                    } else {
                        self.homeView?.bookReviewListView.appendReviews(newReviews)
                    }
                    self.currentOffset += newReviews.count
                case .failure(let error):
                    self.showAlert(title: "エラー", message: "レビューの取得に失敗しました: \(error.localizedDescription)")
                }
                completion?()
            }
        }
    }
    
    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        title = "Book Reviewer"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.accent,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        navigationItem.hidesBackButton = true
        
        // ユーザーアイコンボタン
        let userIconButton = homeView?.createUserIconButton()
        userIconButton?.addTarget(self, action: #selector(userIconTapped), for: .touchUpInside)
        let userIconBarButtonItem = UIBarButtonItem(customView: userIconButton!)
        navigationItem.rightBarButtonItem = userIconBarButtonItem
    }
    
    @objc private func userIconTapped() {
        let userName: String = UserProfileService.yourAccount?.name ?? "Error"
        let alert = UIAlertController(title: "アカウント設定: \(userName)", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "名前を変更", style: .default, handler: { [weak self] _ in
            self?.changeUserName()
        }))
        
        alert.addAction(UIAlertAction(title: "ログアウト", style: .default, handler: { [weak self] _ in
            self?.logout()
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
                        self.hideLoading()
                        
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
    
    private func logout() {
        isLoggingOut = true
        UserProfileService.yourAccount = nil
        UserProfileService.yourAccountPublisher.send(nil)
        let _ = SecureTokenService.shared.delete()
        navigationController?.popToRootViewController(animated: true)
        print("ログアウトしました")
    }
    
    // MARK: - Refresh Control
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshReviews), for: .valueChanged)
        homeView?.bookReviewListView.refreshControl = refreshControl
    }
    
    // MARK: - Floating Action Button
    private func setupFloatingActionButton() {
        fab.setImage(UIImage(systemName: "plus"), for: .normal)
        fab.tintColor = .white
        fab.backgroundColor = .systemPink
        fab.layer.cornerRadius = 28
        fab.translatesAutoresizingMaskIntoConstraints = false
        fab.addTarget(self, action: #selector(loadMoreReviews), for: .touchUpInside)
        
        view.addSubview(fab)
        
        NSLayoutConstraint.activate([
            fab.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            fab.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            fab.widthAnchor.constraint(equalToConstant: 56),
            fab.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - UserProfile Binding
//    private func bindUserProfileService() {
//        UserProfileService.yourAccountPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] user in
//                guard let self = self else { return }
//                if self.isLoggingOut {
//                    return
//                }
//                if let user = user {
//                    self.homeView?.updateUserName(user.name)
//                } else {
//                    self.showErrorAndExit()
//                }
//            }
//            .store(in: &cancellables)
//    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
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
}
