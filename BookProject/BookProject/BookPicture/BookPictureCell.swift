//
//  BookPictureCell.swift
//  BookProject
//
//  Created by JY Jang on 10/3/25.
//

import UIKit
import SnapKit

final class BookPictureCell: UICollectionViewCell {
  
  private let bookPictureImage: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.accessibilityLabel = "책 구절의 이미지입니다."
    return imageView
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout() {
    contentView.addSubview(bookPictureImage)
    
    bookPictureImage.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  struct ViewModel: Equatable {
    let id: String
    let image: UIImage
    let memo: String
    let date: String
  }
  
  func configure(viewModel: ViewModel) {
    bookPictureImage.image = viewModel.image
  }
  
}
