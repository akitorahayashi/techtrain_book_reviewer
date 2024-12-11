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
        setupRefreshControl()
        loadInitialReviews()
    }
    
    
    // MARK: - Refresh Control
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshReviews), for: .valueChanged)
        homeView?.bookReviewListView.refreshControl = refreshControl
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
