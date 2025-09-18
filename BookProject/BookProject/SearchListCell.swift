import UIKit

final class SearchListCell: UICollectionViewCell {
  
  let bookImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "Sample2.jpg")
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.applyBoldCommonStyle16()
    label.numberOfLines = 1
    //label.text = "여기는 책 제목을 받아오는 칸입니다"
    return label
  }()
  
  let descLabel: UILabel = {
    let label = UILabel()
    label.applyCommonStyle16()
    label.numberOfLines = 1
    //label.text = "여기는 저자의 이름을 받아오는 칸입니다"
    return label
  }()
  
  lazy var textStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [titleLabel, descLabel])
    stack.axis = .vertical
    stack.spacing = 12
    stack.alignment = .leading
    stack.distribution = .equalSpacing
    return stack
  }()
  
  lazy var searchCellStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [bookImageView, textStackView])
    stack.axis = .horizontal
    stack.spacing = 12
    stack.alignment = .center
    stack.distribution = .equalSpacing
    return stack
  }()
  
  
  
  private func setupLayout() {
    contentView.addSubview(searchCellStackView)
    
    
    searchCellStackView.translatesAutoresizingMaskIntoConstraints = false
  
    
    NSLayoutConstraint.activate([
      searchCellStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      searchCellStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      searchCellStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      searchCellStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      
      bookImageView.widthAnchor.constraint(equalToConstant: 80),
      bookImageView.heightAnchor.constraint(equalToConstant: 100),
      
      textStackView.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 16)
    ])
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  
  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    
    let targetSize = CGSize(width: layoutAttributes.size.width, height: 0.0)
    
    let size = contentView.systemLayoutSizeFitting(targetSize,
                                                   withHorizontalFittingPriority: .required,
                                                   verticalFittingPriority: .fittingSizeLevel)
    
    let newLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
    newLayoutAttributes.size = CGSize(width: layoutAttributes.size.width, height: ceil(size.height))
    return newLayoutAttributes
  }
  
}
