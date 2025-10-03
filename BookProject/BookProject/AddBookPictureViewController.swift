//
//  AddBookPictureViewController.swift
//  BookProject
//
//  Created by JY Jang on 10/3/25.
//

import UIKit
import SnapKit

class AddBookPictureViewController: UIViewController {
  //weak var delegate: AddBookViewControllerDelegate?
  
  var bookEdit: Book?
  var bookID: String?
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.backgroundColor = .systemGray5
    return imageView
  }()
  
  private let photoButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
    let icon = UIImage(systemName: "photo", withConfiguration: config)
    button.setImage(icon, for: .normal)
    button.tintColor = .systemBlue
    button.setContentHuggingPriority(.required, for: .horizontal)
    return button
  }()
  
  private let memoTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책 메모를 입력하세요"
    text.applyUITextField()
    return text
  }()
  
  private lazy var mainStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [imageView, subStackView])
    stack.axis = .vertical
    stack.spacing = 20
    stack.alignment = .fill
    return stack
  }()
  
  private lazy var subStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [photoButton, memoTextField])
    stack.axis = .horizontal
    stack.spacing = 12
    stack.alignment = .fill
    return stack
  }()
  
  private func setupLayout() {
    view.addSubview(mainStackView)
    
    imageView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(imageView.snp.width)
    }
    
    mainStackView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
      make.leading.equalTo(view).offset(16)
      make.trailing.equalTo(view).inset(16)
    }
  }
  
  
  
  private func naviButton() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "취소",
      style: .plain,
      target: self,
      action: #selector(cancelTapped)
    )
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "저장",
      style: .done,
      target: self,
      action: #selector(saveTapped)
    )
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    self.title = bookEdit == nil ? "책 추가" : "책 수정"
    
    if let editBook = bookEdit {
      memoTextField.text = editBook.bookTitle
    }
    
    naviButton()
    setupLayout()
  }
  
  @objc private func cancelTapped() {
    dismiss(animated: true)
  }
  
  @objc private func saveTapped() {
    
    
//    guard let title = titleTextField.text, !title.isEmpty,
//          let totalText = totalTextField.text, let total = Int(totalText),
//          let currentText = currentTextField.text, let current = Int(currentText) else
//    {
//      return
//    }
//    

    
//    let book = Book(id: bookID ?? UUID().uuidString, bookTitle: title, totalPage: total, currentPage: current)
//    
//    if let bookID = bookID {
//      delegate?.updateBookTappedButton(self, didUpdate: book, bookID: bookID)
//    } else {
//      delegate?.addBookTappedButton(self, didAdd: book)
//    }
    dismiss(animated: true)
  }
  
  
  
  
  
}
