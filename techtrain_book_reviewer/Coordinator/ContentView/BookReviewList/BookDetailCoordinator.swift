//
//  BookDetailCoordinator.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/13.
//

import UIKit

@MainActor
protocol BookDetailCoordinatorProtocol: AnyObject {
    func navigateEditBookReview(corrBookReview: BookReview)
}

@MainActor
class BookDetailCoordinator: BookDetailCoordinatorProtocol {
    private let navigationController: UINavigationController
    // child coordinator
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func navigateEditBookReview(corrBookReview: BookReview) {
        self.navigationController.pushViewController(EditBookReviewVC(corrBookReview: corrBookReview), animated: true)
    }
}
