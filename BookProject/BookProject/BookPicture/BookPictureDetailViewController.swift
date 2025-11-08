import UIKit
import SnapKit

final class BookPictureDetailViewController: UIViewController {
  
  var pictureID: String?
  var viewModel: BookPictureViewModel?
  
  private let scrollView = UIScrollView()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.backgroundColor = .systemGray5
    imageView.accessibilityLabel = "책 구절의 이미지입니다."
    return imageView
  }()
  
  private let memoLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.applyBoldCommonStyle()
    label.textAlignment = .left
    label.accessibilityLabel = "책 구절의 메모입니다."
    return label
  }()
  
  private let dateLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 1
    label.applyCommonStyle16()
    label.textAlignment = .left
    label.accessibilityLabel = "책 구절을 저장한 날의 날짜입니다."
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
    loadPictureData()
  }
  
  private func loadPictureData() {
    guard let pictureID = pictureID,
          let picture = viewModel?.findPicture(by: pictureID) else {
      return
    }
    
    imageView.image = picture.booktTextpicture
    memoLabel.text = picture.memo
    memoLabel.accessibilityValue = picture.memo
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 MM월 dd일"
    dateLabel.text = formatter.string(from: picture.date)
    dateLabel.accessibilityValue = dateLabel.text
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
    navigationItem.rightBarButtonItem?.accessibilityLabel = "더 보기 메뉴"
    navigationItem.rightBarButtonItem?.accessibilityHint = "책 구절의 수정 또는 삭제 메뉴를 엽니다."
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
    editAction.accessibilityHint = "입력한 사진과 메모를 수정할 수 있습니다."
    
    let deleteAction = UIAlertAction(
      title: "삭제",
      style: .destructive
    ) { _ in
      self.pictureDeleteButtonTapped()
    }
    deleteAction.accessibilityHint = "입력한 사진과 메모를 삭제 할 수 있습니다."
    
    let cancelAction = UIAlertAction(
      title: "취소",
      style: .cancel
    )
    cancelAction.accessibilityHint = "취소하고 선택 창을 닫습니다."
    
    alert.addAction(editAction)
    alert.addAction(deleteAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true)
  }
  
  @objc private func pictureUpdateButtonTapped() {
    guard let pictureID = pictureID,
          let picture = viewModel?.findPicture(by: pictureID) else {
      return
    }
    
    let addBookPictureVC = AddBookPictureViewController()
    addBookPictureVC.updatedelegate = self
    addBookPictureVC.pictureEdit = picture
    addBookPictureVC.pictureID = pictureID
    
    let navVC = UINavigationController(rootViewController: addBookPictureVC)
    present(navVC, animated: true)
    
  }
  
  @objc private func pictureDeleteButtonTapped() {
    guard let pictureID = pictureID else { return }
    
    let alert = UIAlertController(
      title: "삭제",
      message: "정말 삭제하시겠습니까?",
      preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
      self.viewModel?.handleTapDeleteButton(pictureID: pictureID)
      self.navigationController?.popViewController(animated: true)
    })
    
    present(alert, animated: true)
  }
}

extension BookPictureDetailViewController: UpdateBookPictureDelegate {
  
  func updateBookPictureTappedButton(_ vc: AddBookPictureViewController, didUpdate picture: BookPictureModel, pictureID: String) {
    viewModel?.handleTapUpdateButton(updatedPicture: picture, pictureID: pictureID)
    loadPictureData()
  }
}
