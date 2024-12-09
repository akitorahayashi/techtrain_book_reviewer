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
        view.backgroundColor = .white
        title = "ホーム"
        
        // 左端にユーザー名を表示
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: tbrUser.name, style: .plain, target: nil, action: nil)
        
        // 右端に「Account設定」ボタンを追加
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Account設定", style: .plain, target: self, action: #selector(accountSettingsTapped))
    }
    
    @objc private func accountSettingsTapped() {
        // アラートを表示
        let alert = UIAlertController(title: "Account設定", message: "アカウントの操作を選択してください", preferredStyle: .actionSheet)
        
        // 名前変更の選択肢
        alert.addAction(UIAlertAction(title: "名前を変更する", style: .default, handler: { [weak self] _ in
            self?.changeUserName()
        }))
        
        // ログアウトの選択肢
        alert.addAction(UIAlertAction(title: "ログアウト", style: .default, handler: { [weak self] _ in
            self?.logout()
        }))
        
        // アカウント削除の選択肢
        alert.addAction(UIAlertAction(title: "アカウントを削除する", style: .destructive, handler: { [weak self] _ in
            self?.deleteAccount()
        }))
        
        // キャンセルボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        // アラートを表示
        present(alert, animated: true, completion: nil)
    }
    
    private func changeUserName() {
        // 名前変更のためのアラート
        let alert = UIAlertController(title: "名前を変更", message: "新しい名前を入力してください", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "新しい名前"
        }
        alert.addAction(UIAlertAction(title: "変更", style: .default, handler: { [weak self] _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                // 名前変更のロジックを追加
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func logout() {
        // ログアウト処理（仮）
        print("ログアウトしました")
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func deleteAccount() {
        // アカウント削除の確認
        let alert = UIAlertController(title: "アカウント削除", message: "本当にアカウントを削除しますか？この操作は取り消せません。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { [weak self] _ in
            // アカウント削除処理（仮）
            print("アカウントを削除しました")
            self?.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
