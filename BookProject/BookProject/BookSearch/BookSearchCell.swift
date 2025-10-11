import UIKit
import SnapKit

final class BookSearchCell: UICollectionViewCell {
  
  
  struct ViewModel: Hashable {
    var itemId: String
    var cover: String
    var title: String
    var description: String
    var author: String
  }
  
  func configure(viewModel: ViewModel) {
    //bookID = viewModel.itemId
    titleLabel.text = viewModel.title
    //bookImageView.image = UIImage(named: "Sample2.jpg")
    bookImageView.imageFromURL(viewModel.cover)
    authorLabel.text = viewModel.author
  }
  
  private let bookImageView: UIImageView = {
    let imageView = UIImageView()
    //imageView.image = UIImage(named: "Sample2.jpg")
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.applyBoldCommonStyle16()
    label.numberOfLines = 1
    //label.text = "여기는 책 제목을 받아오는 칸입니다"
    return label
  }()
  
  private let authorLabel: UILabel = {
    let label = UILabel()
    label.applyCommonStyle16()
    label.numberOfLines = 1
    return label
  }()
  
  private lazy var textStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [titleLabel, authorLabel])
    stack.axis = .vertical
    stack.spacing = 12
    stack.alignment = .leading
    stack.distribution = .equalSpacing
    return stack
  }()
  
  private lazy var searchCellStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [bookImageView, textStackView])
    stack.axis = .horizontal
    stack.spacing = 12
    stack.alignment = .center
    stack.distribution = .equalSpacing
    return stack
  }()
  
  
  
  private func setupLayout() {
    contentView.addSubview(searchCellStackView)
    
    
    searchCellStackView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.leading.equalToSuperview().offset(16)
      make.bottom.equalToSuperview().offset(-16)
      make.trailing.equalToSuperview().offset(-16)
    }
    
    bookImageView.snp.makeConstraints { make in
      make.width.equalTo(60)
      make.height.equalTo(85)
    }
    
    textStackView.snp.makeConstraints { make in
      make.leading.equalTo(bookImageView.snp.trailing).offset(16)
    }
    
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


// 이미지 url로 받아오기
extension UIImageView {
  func imageFromURL(_ urlString: String) {
    // 기본 이미지
    self.image = UIImage(named: "Sample2.jpg")
    
    guard let url = URL(string: urlString) else { return }
    
    URLSession.shared.dataTask(with: url) { data, _, _ in
      if let data = data, let image = UIImage(data: data) {
        // 이미지를 받았다가 메인스레드로 다시 보내야함
        DispatchQueue.main.async {
          self.image = image
        }
      }
    }.resume()
  }
}
