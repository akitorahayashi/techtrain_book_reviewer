//
//  EditBookReviewCoordinator.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/13.
//


import UIKit

@MainActor
protocol EditBookReviewCoordinatorProtocol: AnyObject {
    func navigateBookDetailAfterEditing(corrBookReview: BookReview)
}

@MainActor
class EditBookReviewCoordinator: EditBookReviewCoordinatorProtocol {
    private let navigationController: UINavigationController
    // child coordinator
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func navigateBookDetailAfterEditing(corrBookReview: BookReview) {
        self.navigationController.popViewController(animated: true)
    }
}
