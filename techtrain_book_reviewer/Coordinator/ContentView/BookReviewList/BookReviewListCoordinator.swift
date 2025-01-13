//
//  BookReviewListCoordinator.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/13.
//

import UIKit

@MainActor
protocol BookReviewListCoordinatorProtocol: AnyObject {
    func navigateToBookDetailView(corrBookReview: BookReview)
}

@MainActor
class BookReviewListCoordinator: BookReviewListCoordinatorProtocol {
    private let navigationController: UINavigationController
    // child coordinator
    private var bookDetailCoordinator: BookDetailCoordinator
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.bookDetailCoordinator = BookDetailCoordinator(navigationController: self.navigationController)
    }
    
    func navigateToBookDetailView(corrBookReview: BookReview) {
        let bookDetailVC = BookDetailVC(
            bookDetailCoordinator: bookDetailCoordinator,
            corrBookReview: corrBookReview
        )
        self.navigationController.pushViewController(bookDetailVC, animated: true)
        print("navigateToBookDetailView")
    }
}
