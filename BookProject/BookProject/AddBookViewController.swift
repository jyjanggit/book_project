//
//  AddBookViewController.swift
//  BookProject
//
//  Created by JY Jang on 8/7/25.
//

import UIKit

class AddBookViewController: UIViewController {
  
  let titleTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책 제목을 입력하세요"
    text.applyUITextField()
    return text
  }()
  
  let totalTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책의 총 페이지수"
    text.keyboardType = .numberPad
    text.applyUITextField()
    return text
  }()
  
  let currentTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책의 현재 페이지수"
    text.keyboardType = .numberPad
    text.applyUITextField()
    return text
  }()
  
  lazy var textFieldStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [titleTextField, totalTextField, currentTextField])
    stack.axis = .vertical
    stack.spacing = 20
    stack.alignment = .fill
    return stack
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    self.title = "책 추가"
    
    
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
    
    setupLayout()
  }
  
  private func setupLayout() {
    view.addSubview(textFieldStackView)
    
    textFieldStackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      textFieldStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      textFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])
  }

  
  @objc private func cancelTapped() {
    dismiss(animated: true)
  }
  
  @objc private func saveTapped() {
    
    dismiss(animated: true)
  }
  

}

