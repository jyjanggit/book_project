//
//  BookPictureCell.swift
//  BookProject
//
//  Created by JY Jang on 10/3/25.
//

import UIKit

final class BookPictureCell: UICollectionViewCell {
  
  private let bookPictureImage: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "Sample2.jpg")
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
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
  
}
