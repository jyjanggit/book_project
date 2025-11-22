import UIKit
import SnapKit

// MARK: - 반원 차트

final class ChartView: UIView {
  
  var readValue = CGFloat() {
    didSet {
      chart()
      self.isAccessibilityElement = true
      self.accessibilityValue = "\(Int(readValue))퍼센트 읽음"
    }
  }
  
  func chart() {
    layer.sublayers?.forEach { sublayer in
      if sublayer.name == "removableLayer" {
        sublayer.removeFromSuperlayer()
      }
    }
    
    let radius = bounds.width / 2
    let center = CGPoint(x: bounds.midX, y: radius)
    let innerRadius = radius * 0.6
    
    let startAngle = -CGFloat.pi
    let endAngle = startAngle + CGFloat.pi
    let backgroundPath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: startAngle,
                                      endAngle: endAngle,
                                      clockwise: true)
    backgroundPath.addArc(withCenter: center,
                          radius: innerRadius,
                          startAngle: endAngle,
                          endAngle: startAngle,
                          clockwise: false)
    
    let backgroundLayer = CAShapeLayer()
    backgroundLayer.name = "removableLayer"
    backgroundLayer.path = backgroundPath.cgPath
    backgroundLayer.fillColor = UIColor(hex: "#e2e4e9").cgColor
    layer.addSublayer(backgroundLayer)
    
    let value = readValue
    let currentEndAngle = startAngle + CGFloat.pi * (value / 100)
    let currentPath = UIBezierPath()
    currentPath.move(to: center)
    currentPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: currentEndAngle, clockwise: true)
    currentPath.addArc(withCenter: center, radius: innerRadius, startAngle: currentEndAngle, endAngle: startAngle, clockwise: false)
    currentPath.close()
    
    let currentLayer = CAShapeLayer()
    currentLayer.name = "removableLayer"
    currentLayer.path = currentPath.cgPath
    currentLayer.fillColor = UIColor(hex: "#a2bafb").cgColor
    layer.addSublayer(currentLayer)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    chart()
  }
}

final class BookListCell: UICollectionViewCell {
  
  weak var updateDelegate: BookListCellUpdateDelegate?
  weak var deleteDelegate: BookListCellDeleteDelegate?
  var bookID: String?
  
  struct ViewModel: Equatable {
    let id: String
    let title: String
    let currentPage: String
    let totalPage: String
    let chartReadValue: CGFloat
  }
  
  // MARK: - configure
  
  func configure(viewModel: ViewModel) {
    bookID = viewModel.id
    titleLabel.text = viewModel.title
    currentPageLabel.text = viewModel.currentPage
    currentPageLabel.accessibilityLabel = "현재 읽은 페이지: \(viewModel.currentPage) 페이지"
    totalPageLabel.text = viewModel.totalPage
    totalPageLabel.accessibilityLabel = "책의 총 페이지: \(viewModel.totalPage) 페이지"
    chartView.readValue = viewModel.chartReadValue
  }
  
  // MARK: - Life Cycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupButtonActions()
    setupLayout()
  }
  
  // MARK: - ui
  
  private let containerView: UIView = {
    let view = UIView()
    view.layer.shadowColor = UIColor(hex: "#181818").cgColor
    view.layer.shadowOpacity = 0.2
    view.layer.shadowOffset = CGSize(width: 0, height: 2)
    view.layer.shadowRadius = 4
    view.layer.masksToBounds = false
    view.backgroundColor = .white
    view.layer.cornerRadius = 10
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingTail
    label.textAlignment = .center
    label.applyBoldCommonStyle()
    label.accessibilityTraits = .header
    return label
  }()
  
  private let chartParentsView: UIView = UIView()
  
  private let chartView: ChartView = {
    let view = ChartView()
    view.accessibilityLabel = "독서 진행률 그래프입니다."
    return view
  }()
  
  private let bookImageView: UIImageView = {
    UIImageView(image: UIImage(systemName: "book"))
  }()
  
  private let currentPageLabel: UILabel = {
    let label = UILabel()
    label.applyBoldCommonStyle()
    return label
  }()
  
  private let totalPageLabel: UILabel = {
    let label = UILabel()
    label.applyCommonStyle()
    return label
  }()
  
  private lazy var pageStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [currentPageLabel, totalPageLabel])
    stack.axis = .horizontal
    stack.spacing = 0
    stack.alignment = .center
    stack.distribution = .equalSpacing
    return stack
  }()
  
  private let updateButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("수정", for: .normal)
    button.backgroundColor = UIColor(hex: "#7598fe")
    button.applyButton()
    button.accessibilityHint = "내용을 수정 할 수 있습니다."
    return button
  }()
  
  private let deleteButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("삭제", for: .normal)
    button.backgroundColor = UIColor(hex: "#FF6961")
    button.applyButton()
    button.accessibilityHint = "내용을 삭제 할 수 있습니다."
    return button
  }()
  
  private lazy var buttonStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [updateButton, deleteButton])
    stack.axis = .horizontal
    stack.spacing = 5
    stack.alignment = .center
    stack.distribution = .fillEqually
    return stack
  }()
  
  private lazy var mainStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [chartParentsView, pageStackView, buttonStackView])
    stack.axis = .vertical
    stack.spacing = 20
    stack.alignment = .fill
    stack.distribution = .equalSpacing
    return stack
  }()
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - setupButtonActions
   
   private func setupButtonActions() {
     updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
     deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
   }
  
  // MARK: - setupLayout
  
  private func setupLayout() {
    contentView.addSubview(containerView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(mainStackView)
    chartParentsView.addSubview(chartView)
    chartParentsView.addSubview(bookImageView)
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview().inset(16)
      make.bottom.equalTo(mainStackView.snp.top).offset(-16)
    }
    
    mainStackView.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(16)
      make.centerX.equalToSuperview()
    }
    
    chartParentsView.snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 250, height: 125))
      make.centerX.equalToSuperview()
    }
    
    chartView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    bookImageView.snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 40, height: 40))
      make.bottom.centerX.equalToSuperview()
    }
  }
  
  // MARK: - 버튼동작
  
  @objc private func updateButtonTapped() {
    guard let bookID else { return }
    updateDelegate?.didTapUpdateButton(bookID: bookID)
  }
  
  @objc private func deleteButtonTapped() {
    guard let bookID else { return }
    deleteDelegate?.didTapDeleteButton(bookID: bookID)
  }
  
  // MARK: - preferredLayoutAttributesFitting
  
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
