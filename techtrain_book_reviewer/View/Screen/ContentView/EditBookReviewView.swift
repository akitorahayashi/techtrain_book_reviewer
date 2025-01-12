//
//  EditBookReviewView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class EditBookReviewView: UIView, UITextViewDelegate {
    private let scrollView = UIScrollView()
    private let containerView = UIView()

    private let titleHeader = UILabel()
    let titleTextField = TBRInputField()
    private let urlHeader = UILabel()
    let urlTextField = TBRInputField()

    private let detailHeader = UILabel()
    let detailInputField = UITextView()
    private let reviewHeader = UILabel()
    let reviewInputField = UITextView()

    private var reviewHeightConstraint: NSLayoutConstraint!
    private var detailHeightConstraint: NSLayoutConstraint!

    let compliteButton = TBRCardButton()
    let clearButton = TBRCardButton()

    // 定数
    private let containerPadding: CGFloat = 20
    private let inputStackSpacing: CGFloat = 20
    private let inputFieldHeight: CGFloat = 60
    private let textViewMinHeight: CGFloat = 90
    private let spacerViewHeight: CGFloat = 300
    private let buttonHeight: CGFloat = 44

    init() {
        super.init(frame: .zero)
        reviewInputField.delegate = self
        detailInputField.delegate = self
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTextView(_ textView: UITextView) {
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.cornerRadius = 5.0
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
    }

    func configureButtons(saveButtonTitle: String, cancelButtonTitle: String) {
        compliteButton.setTitle(saveButtonTitle, for: .normal)
        clearButton.setTitle(cancelButtonTitle, for: .normal)
    }

    private func setupUI() {
        backgroundColor = .white

        // スクロールビューとコンテナビューの設定
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // 各ヘッダー設定
        setupHeader(titleHeader, text: "- Title -")
        setupHeader(urlHeader, text: "- URL -")
        setupHeader(detailHeader, text: "- Detail -")
        setupHeader(reviewHeader, text: "- Review -")

        // テキストビュー設定
        configureTextView(detailInputField)
        configureTextView(reviewInputField)

        // 入力フィールドのペアを作成
        let titleStack = createInputFormStackView(withHeader: titleHeader, inputField: titleTextField)
        let urlStack = createInputFormStackView(withHeader: urlHeader, inputField: urlTextField)
        let detailStack = createInputFormStackView(withHeader: detailHeader, inputField: detailInputField)
        let reviewStack = createInputFormStackView(withHeader: reviewHeader, inputField: reviewInputField)

        // スタックビューの配置
        let inputFieldStackView = UIStackView(arrangedSubviews: [titleStack, urlStack, detailStack, reviewStack])
        inputFieldStackView.axis = .vertical
        inputFieldStackView.spacing = inputStackSpacing
        inputFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputFieldStackView)

        NSLayoutConstraint.activate([
            inputFieldStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: inputStackSpacing),
            inputFieldStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: containerPadding),
            inputFieldStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -containerPadding)
        ])

        // Spacerの設定
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(spacerView)

        NSLayoutConstraint.activate([
            spacerView.topAnchor.constraint(equalTo: inputFieldStackView.bottomAnchor),
            spacerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            spacerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: spacerViewHeight),
            spacerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // ボタンスタックビューの配置
        let buttonStackView = UIStackView(arrangedSubviews: [clearButton, compliteButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: containerPadding),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -containerPadding),
            buttonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            buttonStackView.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
    }

    private func setupHeader(_ header: UILabel, text: String) {
        header.text = text
        header.font = UIFont.boldSystemFont(ofSize: 14)
        header.textColor = .gray
    }

    private func createInputFormStackView(withHeader header: UILabel, inputField: UIView) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [header, inputField])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        inputField.translatesAutoresizingMaskIntoConstraints = false

        if let textField = inputField as? UITextField {
            textField.heightAnchor.constraint(equalToConstant: inputFieldHeight).isActive = true
        } else if let textView = inputField as? UITextView {
            textView.heightAnchor.constraint(equalToConstant: textViewMinHeight).isActive = true
        }
        return stackView
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView == reviewInputField {
            adjustHeight(for: textView, constraint: reviewHeightConstraint)
        } else if textView == detailInputField {
            adjustHeight(for: textView, constraint: detailHeightConstraint)
        }
    }

    private func adjustHeight(for textView: UITextView, constraint: NSLayoutConstraint) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        constraint.constant = max(textViewMinHeight, size.height)
    }
}
