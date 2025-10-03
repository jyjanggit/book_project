//
//  BookPictureDetailViewController.swift
//  BookProject
//
//  Created by JY Jang on 10/3/25.
//

import UIKit
import SnapKit

final class BookPictureDetailViewController: UIViewController {
  
  private let scrollView = UIScrollView()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.backgroundColor = .systemGray5
    return imageView
  }()
  
  private let memoLabel: UILabel = {
    let label = UILabel()
    label.text = "메모하거나 제목을 쓰거나 둘중하나 하시면 됩니다 아마 제목쓰거나 이북이면 캡처할때 제목도 나오니까 상관없을듯 메모하거나 제목을 쓰거나 둘중하나 하시면 됩니다 아마 제목쓰거나 이북이면 캡처할때 제목도 나오니까 상관없을듯메모하거나 제목을 쓰거나 둘중하나 하시면 됩니다 아마 제목쓰거나 이북이면 캡처할때 제목도 나오니까 상관없을듯"
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.applyBoldCommonStyle()
    label.textAlignment = .left
    return label
  }()
  
  private let dateLabel: UILabel = {
    let label = UILabel()
    label.text = "2025-02-24"
    label.numberOfLines = 1
    label.applyCommonStyle16()
    label.textAlignment = .left
    return label
  }()
  
  private lazy var mainStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [imageView, subStackView])
    stack.axis = .vertical
    stack.spacing = 20
    stack.alignment = .fill
    return stack
  }()
  
  private lazy var subStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [memoLabel, dateLabel])
    stack.axis = .vertical
    stack.spacing = 20
    stack.alignment = .fill
    return stack
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    
    setupLayout()
    setupNavigationBar()
    
  }
  
  private func setupLayout() {
    view.addSubview(scrollView)
    scrollView.addSubview(mainStackView)
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    mainStackView.snp.makeConstraints { make in
      make.top.equalTo(scrollView.contentLayoutGuide.snp.top).offset(16)
      make.leading.equalTo(scrollView.contentLayoutGuide.snp.leading).offset(16)
      make.width.equalTo(scrollView.frameLayoutGuide).offset(-32)
      make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom).offset(-16)
    }
    

    imageView.snp.makeConstraints { make in
      make.height.equalTo(imageView.snp.width)
    }
    

  }
  
  private func setupNavigationBar() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "ellipsis.circle"),
      style: .plain,
      target: self,
      action: #selector(moreButtonTapped)
    )
  }
  
  @objc private func moreButtonTapped() {
    let alert = UIAlertController(
      title: nil,
      message: nil,
      preferredStyle: .actionSheet
    )
    
    let editAction = UIAlertAction(
      title: "수정",
      style: .default
    ) { _ in
      self.pictureUpdateButtonTapped()
    }
    
    let deleteAction = UIAlertAction(
      title: "삭제",
      style: .destructive
    ) { _ in
      self.pictureDeleteButtonTapped()
      
    }
    
    let cancelAction = UIAlertAction(
      title: "취소",
      style: .cancel
    )
    
    alert.addAction(editAction)  // 수정
    alert.addAction(deleteAction)  // 삭제
    alert.addAction(cancelAction)  // 취소
    
    present(alert, animated: true)
  }
  

  
  @objc private func pictureUpdateButtonTapped() {

  }
  
  @objc private func pictureDeleteButtonTapped() {

    
  }
  
  
  
}



