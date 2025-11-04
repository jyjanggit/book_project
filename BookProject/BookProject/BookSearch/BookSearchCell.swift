import UIKit
import SnapKit
import Alamofire

final class BookSearchCell: UICollectionViewCell {
  
  
  struct ViewModel: Hashable {
    var itemId: String
    var cover: String
    var title: String
    //var description: String
    var author: String
  }
  
  func configure(viewModel: ViewModel) {
    titleLabel.text = viewModel.title
    titleLabel.accessibilityLabel = "책 제목: \(viewModel.title)"
    bookImageView.imageFromURL(viewModel.cover)
    bookImageView.accessibilityLabel = "\(viewModel.title)책의 표지입니다."
    authorLabel.text = viewModel.author
    authorLabel.accessibilityLabel = "책 저자: \(viewModel.author)"
  }
  
  private let bookImageView: UIImageView = {
    let imageView = UIImageView()
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
    
    AF.request(url).responseData { response in
      if let error = response.error {
        print("책이미지 에러: \(error)")
        return
      }
      if let data = response.data, let image = UIImage(data: data) {
        self.image = image
      }
    }
  }
}
