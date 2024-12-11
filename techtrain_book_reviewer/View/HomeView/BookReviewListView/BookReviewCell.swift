//
//  BookReviewCell.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class BookReviewCell: UITableViewCell {
    private let bookImageView = UIImageView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let reviewerLabel = UILabel()
    private let reviewTextLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // ImageViewの設定
        bookImageView.contentMode = .scaleAspectFill
        bookImageView.clipsToBounds = true
        bookImageView.layer.cornerRadius = 8
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title Labelの設定
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Detail Labelの設定
        detailLabel.font = UIFont.systemFont(ofSize: 14)
        detailLabel.textColor = .gray
        detailLabel.numberOfLines = 2
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Reviewer Labelの設定
        reviewerLabel.font = UIFont.systemFont(ofSize: 14)
        reviewerLabel.textColor = .systemBlue
        reviewerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Review Text Labelの設定
        reviewTextLabel.font = UIFont.systemFont(ofSize: 14)
        reviewTextLabel.numberOfLines = 3
        reviewTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // サブビューとして追加
        contentView.addSubview(bookImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(reviewerLabel)
        contentView.addSubview(reviewTextLabel)
        
        // レイアウト制約
        NSLayoutConstraint.activate([
            bookImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            bookImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            bookImageView.widthAnchor.constraint(equalToConstant: 60),
            bookImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            detailLabel.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 10),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            
            reviewerLabel.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 10),
            reviewerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            reviewerLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 5),
            
            reviewTextLabel.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 10),
            reviewTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            reviewTextLabel.topAnchor.constraint(equalTo: reviewerLabel.bottomAnchor, constant: 5),
            reviewTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with review: BookReview) {
        titleLabel.text = review.title
        detailLabel.text = review.detail
        reviewerLabel.text = "Reviewer: \(review.reviewer)"
        reviewTextLabel.text = review.review
        
        // 画像の読み込み
        if let urlString = review.url, let url = URL(string: urlString) {
            loadImage(from: url, for: review.title)
        } else {
            // URLがない場合
            print("画像URLが存在しません: \(review.title)")
            bookImageView.image = UIImage(named: "DefaultBookImage")
        }
    }

    private func loadImage(from url: URL, for title: String) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("画像の読み込みエラー (\(title)): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.bookImageView.image = UIImage(named: "DefaultBookImage")
                }
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.bookImageView.image = image
                }
            } else {
                print("画像データが無効: \(title)")
                DispatchQueue.main.async {
                    self.bookImageView.image = UIImage(named: "DefaultBookImage")
                }
            }
        }
        task.resume()
    }

}

