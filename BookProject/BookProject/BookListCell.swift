//
//  BookListCell.swift
//  BookProject
//
//  Created by JY Jang on 8/7/25.
//

import UIKit

// 차트
final class ChartView: UIView {
  
  var readValue = [(UIColor, CGFloat)]() {
    didSet {
      chart()
    }
  }
  
  func chart() {
    layer.sublayers?.forEach{ sublayer in
      if sublayer.name == "removableLayer" {
        sublayer.removeFromSuperlayer()
      }
    }
    
    
    let radius = self.bounds.width / 2
    let center = CGPoint(x: bounds.midX, y: radius)
    let innerRadius = radius * 0.6
    
    let startAngle = -CGFloat.pi
    let endAngle = startAngle + CGFloat.pi
    let backgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    backgroundPath.addArc(withCenter: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
    
    let backgroundLayer = CAShapeLayer()
    backgroundLayer.name = "removableLayer"
    backgroundLayer.path = backgroundPath.cgPath
    backgroundLayer.fillColor = UIColor(hex: "#e2e4e9").cgColor
    
    layer.addSublayer(backgroundLayer)
    
    let current: CGFloat = 100
    
    if let (color, value) = readValue.first {
      let currentEndAngle = startAngle + (CGFloat.pi) * (value / current)
      let currentPath = UIBezierPath()
      currentPath.move(to: center)
      currentPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: currentEndAngle, clockwise: true)
      
      
      currentPath.addArc(withCenter: center, radius: innerRadius, startAngle: currentEndAngle, endAngle: startAngle, clockwise: false)
      
      currentPath.close()
      
      let currentLayer = CAShapeLayer()
      currentLayer.name = "removableLayer"
      currentLayer.path = currentPath.cgPath
      currentLayer.fillColor = color.cgColor
      
      layer.addSublayer(currentLayer)
      
    }
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    chart()
  }
  
}


final class BookListCell: UICollectionViewCell {
  
  private let bookListCell = UIView()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    //label.text = "책제목쓰면되는곳책제목쓰면되는곳책제목쓰면되는곳"
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingTail
    label.textAlignment = .center
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    
    label.applyBoldCommonStyle()
    return label
  }()
  
  let chartView: ChartView = {
    let view = ChartView()
    //view.readValue = [(UIColor(hex: "#a2bafb"), 30)]
    return view
  }()
  
  let bookImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(systemName: "book"))
    return imageView
  }()
  
  //차트와 책아이콘
  let chartParentsView: UIView = {
    let view = UIView()
    return view
  }()
  
  let currentPageLabel: UILabel = {
    let label = UILabel()
    //label.text = "\(current)쪽"
    //label.text = "20쪽"
    label.applyBoldCommonStyle()
    return label
  }()
  
  
  let totalPageLabel: UILabel = {
    let label = UILabel()
    //label.text = "\(total)쪽"
    //label.text = "500쪽"
    label.applyCommonStyle()
    return label
  }()
  
  let updateButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("수정", for: .normal)
    button.backgroundColor = UIColor(hex: "#7598fe")
    button.applyButton()
    return button
  }()
  
  
  let deleteButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("삭제", for: .normal)
    button.backgroundColor = UIColor(hex: "#FF6961")
    button.applyButton()
    return button
  }()
  
  
  // 스택뷰
  lazy var pageStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [currentPageLabel, totalPageLabel])
    stack.axis = .horizontal
    stack.spacing = 0
    stack.alignment = .center
    stack.distribution = .equalSpacing
    return stack
  }()
  
  lazy var buttonStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [updateButton, deleteButton])
    stack.axis = .horizontal
    stack.spacing = 5
    stack.alignment = .center
    stack.distribution = .fillEqually
    return stack
  }()
  
  lazy var mainStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [chartParentsView, pageStackView, buttonStackView])
    stack.axis = .vertical
    stack.spacing = 20
    stack.alignment = .fill
    stack.distribution = .equalSpacing
    return stack
  }()
  
  private let containerView: UIView = {
    let view = UIView()
    view.layer.shadowColor = UIColor(hex: "#181818").cgColor
    view.layer.shadowOpacity = 0.2
    view.layer.shadowOffset = CGSize(width: 0, height: 2)
    view.layer.shadowRadius = 4
    view.layer.masksToBounds = false
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    view.layer.cornerRadius = 10
    return view
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayout()
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout() {
    
    contentView.addSubview(containerView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(mainStackView)
    chartParentsView.addSubview(chartView)
    chartParentsView.addSubview(bookImageView)
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    chartParentsView.translatesAutoresizingMaskIntoConstraints = false
    chartView.translatesAutoresizingMaskIntoConstraints = false
    bookImageView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      
      titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
      titleLabel.bottomAnchor.constraint(equalTo: mainStackView.topAnchor, constant: -16),
      titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
      
      containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
      containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      
      mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
      mainStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      
      chartParentsView.widthAnchor.constraint(equalToConstant: 250),
      chartParentsView.heightAnchor.constraint(equalToConstant: 125),
      chartParentsView.centerXAnchor.constraint(equalTo: mainStackView.centerXAnchor),
      
      chartView.topAnchor.constraint(equalTo: chartParentsView.topAnchor),
      chartView.leadingAnchor.constraint(equalTo: chartParentsView.leadingAnchor),
      chartView.bottomAnchor.constraint(equalTo: chartParentsView.bottomAnchor),
      chartView.trailingAnchor.constraint(equalTo: chartParentsView.trailingAnchor),
      
      bookImageView.widthAnchor.constraint(equalToConstant: 40),
      bookImageView.heightAnchor.constraint(equalToConstant: 40),
      bookImageView.bottomAnchor.constraint(equalTo: chartParentsView.bottomAnchor),
      bookImageView.centerXAnchor.constraint(equalTo: chartParentsView.centerXAnchor)
      
      
    ])
    
  }
  
  
  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    
    let targetSize = CGSize(width: layoutAttributes.size.width, height: 0.0)
    
    let size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    
    let new = super.preferredLayoutAttributesFitting(layoutAttributes)
    new.size = CGSize(width: layoutAttributes.size.width, height: ceil(size.height))
    return new
  }
  
}
