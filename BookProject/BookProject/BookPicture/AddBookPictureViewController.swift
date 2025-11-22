import UIKit
import SnapKit

final class AddBookPictureViewController: UIViewController {
  
  weak var delegate: AddBookPictureViewControllerDelegate?
  weak var updatedelegate: UpdateBookPictureDelegate?
  
  var pictureEdit: BookPictureModel?
  var pictureID: String?
  var selectedImage: UIImage?
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let editPicture = pictureEdit {
      imageView.image = editPicture.booktTextpicture
      selectedImage = editPicture.booktTextpicture
      memoTextField.text = editPicture.memo
    }
    
    setupNavigationItem()
    setupLayout()
    setupAction()
  }
  
  // MARK: - ui
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.backgroundColor = .systemGray5
    imageView.isUserInteractionEnabled = true
    imageView.accessibilityLabel = "추가한 책 구절의 사진입니다."
    return imageView
  }()
  
  private let photoButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
    let icon = UIImage(systemName: "photo", withConfiguration: config)
    button.setImage(icon, for: .normal)
    button.tintColor = .systemBlue
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.accessibilityLabel = "사진 추가"
    button.accessibilityHint = "클릭하면 사진첩을 열어 사진을 선택할 수 있습니다."
    return button
  }()
  
  private let memoTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책 메모를 입력하세요"
    text.applyUITextField()
    text.accessibilityLabel = "책 메모 텍스트필드입니다."
    text.accessibilityHint = "책 관련 메모를 할 수 있는 영역입니다."
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
  
  // MARK: - setupNavigationItem
  
  private func setupNavigationItem() {
    
    navigationItem.title = pictureEdit == nil ? "책 구절 추가" : "책 구절 수정"
    
    let cancelButton = UIBarButtonItem(
        title: "취소",
        style: .plain,
        target: self,
        action: #selector(cancelTapped)
    )
    cancelButton.accessibilityLabel = "취소"
    cancelButton.accessibilityHint = "입력을 취소하고 창을 닫습니다."
    navigationItem.leftBarButtonItem = cancelButton


    let saveButton = UIBarButtonItem(
        title: "저장",
        style: .done,
        target: self,
        action: #selector(saveTapped)
    )
    saveButton.accessibilityLabel = "저장"
    saveButton.accessibilityHint = "현재 내용을 저장합니다."
    navigationItem.rightBarButtonItem = saveButton

  }
  
  // MARK: - setupLayout
  
  private func setupLayout() {
    
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    
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
  
  // MARK: - 버튼동작
  
  private func setupAction() {
    photoButton.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
    imageView.addGestureRecognizer(tapGesture)
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
      booktTextpicture: image,
      memo: memo,
      date: Date()
    )
    
    if let pictureID = pictureID {
      updatedelegate?.didTapUpdateButton(self, didUpdate: picture, pictureID: pictureID)
    } else {
      delegate?.didTapAddButton(self, didAdd: picture)
    }
    
    dismiss(animated: true)
  }
  
  private func showAlert(message: String) {
    let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true)
  }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension AddBookPictureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[.originalImage] as? UIImage {
      imageView.image = image
      selectedImage = image
    }
    picker.dismiss(animated: true)
  }
  
}
