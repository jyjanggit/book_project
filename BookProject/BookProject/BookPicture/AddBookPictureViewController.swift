import UIKit
import SnapKit

final class AddBookPictureViewController: UIViewController {
  
  weak var delegate: AddBookPictureViewControllerDelegate?
  
  var pictureEdit: BookPictureModel?
  var pictureID: String?
  var selectedImage: UIImage?
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.backgroundColor = .systemGray5
    imageView.isUserInteractionEnabled = true
    return imageView
  }()
  
  private let photoButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
    let icon = UIImage(systemName: "photo", withConfiguration: config)
    button.setImage(icon, for: .normal)
    button.tintColor = .systemBlue
    button.setContentHuggingPriority(.required, for: .horizontal)
    return button
  }()
  
  private let memoTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책 메모를 입력하세요"
    text.applyUITextField()
    return text
  }()
  
  private lazy var mainStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [imageView, subStackView])
    stack.axis = .vertical
    stack.spacing = 20
    stack.alignment = .fill
    return stack
  }()
  
  private lazy var subStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [photoButton, memoTextField])
    stack.axis = .horizontal
    stack.spacing = 12
    stack.alignment = .fill
    return stack
  }()
  
  private func setupLayout() {
    view.addSubview(mainStackView)
    
    imageView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(imageView.snp.width)
    }
    
    mainStackView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
      make.leading.equalTo(view).offset(16)
      make.trailing.equalTo(view).inset(16)
    }
  }
  
  private func naviButton() {
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
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    self.title = pictureEdit == nil ? "책 구절 추가" : "책 구절 수정"
    
    if let editPicture = pictureEdit {
      imageView.image = editPicture.booktTextpicture
      selectedImage = editPicture.booktTextpicture
      memoTextField.text = editPicture.memo
    }
    
    photoButton.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
    imageView.addGestureRecognizer(tapGesture)
    
    naviButton()
    setupLayout()
  }
  
  @objc private func imageViewTapped() {
    photoButtonTapped()
  }
  
  @objc private func photoButtonTapped() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = .photoLibrary
    present(picker, animated: true)
  }
  
  @objc private func cancelTapped() {
    dismiss(animated: true)
  }
  
  @objc private func saveTapped() {
    guard let image = selectedImage else {
      showAlert(message: "이미지를 선택해주세요")
      return
    }
    
    let memo = memoTextField.text ?? ""
    
    let picture = BookPictureModel(
      id: pictureID ?? UUID().uuidString,
      memo: memo,
      booktTextpicture: image,
      date: Date()
    )
    
    if let pictureID = pictureID {
      delegate?.updateBookPictureTappedButton(self, didUpdate: picture, pictureID: pictureID)
    } else {
      delegate?.addBookPictureTappedButton(self, didAdd: picture)
    }
    
    dismiss(animated: true)
  }
  
  private func showAlert(message: String) {
    let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true)
  }
}

extension AddBookPictureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[.originalImage] as? UIImage {
      imageView.image = image
      selectedImage = image
    }
    picker.dismiss(animated: true)
  }
}
