//
//  CreateReviewController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class CreateReviewViewController: UIViewController {
    override func loadView() {
        view = CreateReviewView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Review"
    }
}
