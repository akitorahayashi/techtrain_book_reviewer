//
//  EditBookReviewView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class EditBookReviewView: UIView {
    let titleTextField = UITextField()
    let urlTextField = UITextField()
    let detailTextView = UITextView()
    let reviewTextView = UITextView()
    let saveButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Title Text Field
        titleTextField.placeholder = "Title"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // URL Text Field
        urlTextField.placeholder = "URL"
        urlTextField.borderStyle = .roundedRect
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Detail Text View
        detailTextView.layer.borderColor = UIColor.lightGray.cgColor
        detailTextView.layer.borderWidth = 1
        detailTextView.layer.cornerRadius = 8
        detailTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Review Text View
        reviewTextView.layer.borderColor = UIColor.lightGray.cgColor
        reviewTextView.layer.borderWidth = 1
        reviewTextView.layer.cornerRadius = 8
        reviewTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Save Button
        saveButton.setTitle("Save", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        addSubview(titleTextField)
        addSubview(urlTextField)
        addSubview(detailTextView)
        addSubview(reviewTextView)
        addSubview(saveButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            urlTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            urlTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            urlTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            detailTextView.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 16),
            detailTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            detailTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            detailTextView.heightAnchor.constraint(equalToConstant: 100),
            
            reviewTextView.topAnchor.constraint(equalTo: detailTextView.bottomAnchor, constant: 16),
            reviewTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            reviewTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            reviewTextView.heightAnchor.constraint(equalToConstant: 100),
            
            saveButton.topAnchor.constraint(equalTo: reviewTextView.bottomAnchor, constant: 16),
            saveButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
