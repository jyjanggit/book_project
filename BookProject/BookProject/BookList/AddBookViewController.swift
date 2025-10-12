import UIKit
import SnapKit

final class AddBookViewController: UIViewController {
  
  weak var delegate: AddBookViewControllerDelegate?
  
  var bookEdit: Book?
  var bookID: String?
  
  // MARK: - ui
  private let titleTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책 제목을 입력하세요"
    text.applyUITextField()
    text.accessibilityLabel = "책 제목 입력 필드"
    return text
  }()
  
  private let totalTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책의 총 페이지수"
    text.keyboardType = .numberPad
    text.applyUITextField()
    text.accessibilityLabel = "책의 총 페이지수 입력 필드"
    text.accessibilityHint = "책의 총 페이지 숫자를 입력하세요."
    return text
  }()
  
  private let currentTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책의 현재 페이지수"
    text.keyboardType = .numberPad
    text.applyUITextField()
    text.accessibilityLabel = "책의 현재 페이지수 입력 필드"
    text.accessibilityHint = "현재 읽은 페이지 숫자를 입력하세요. 총 페이지 수를 초과할 수 없습니다."
    return text
  }()
  
  private lazy var textFieldStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [titleTextField, totalTextField, currentTextField])
    stack.axis = .vertical
    stack.spacing = 20
    stack.alignment = .fill
    return stack
  }()
  
  private func setupLayout() {
    view.addSubview(textFieldStackView)
    
    textFieldStackView.snp.makeConstraints { make in
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
    navigationItem.leftBarButtonItem?.accessibilityHint = "입력을 취소하고 창을 닫습니다."
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "저장",
      style: .done,
      target: self,
      action: #selector(saveTapped)
    )
    navigationItem.rightBarButtonItem?.accessibilityHint = "입력한 책 정보를 저장합니다."
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    self.title = bookEdit == nil ? "책 추가" : "책 수정"
    
    if let editBook = bookEdit {
      titleTextField.text = editBook.bookTitle
      totalTextField.text = "\(editBook.totalPage)"
      currentTextField.text = "\(editBook.currentPage)"
    }
    
    naviButton()
    setupLayout()
  }
  
  
  
  // MARK: - 버튼동작
  @objc private func cancelTapped() {
    dismiss(animated: true)
  }
  
  @objc private func saveTapped() {
    
    
    guard let title = titleTextField.text, !title.isEmpty,
          let totalText = totalTextField.text, let total = Int(totalText),
          let currentText = currentTextField.text, let current = Int(currentText) else {
      return
    }
    
    if (total < current) || (total <= 0) {
      let alert = UIAlertController(title: "알림", message: "제대로 된 값을 입력해 주세요.", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
      alert.addAction(okAction)
      self.present(alert, animated: true, completion: nil)
      return
    }
    
    let book = Book(id: bookID ?? UUID().uuidString, bookTitle: title, totalPage: total, currentPage: current)
    
    // 만약 책 있으면(기존 책이면) 수정, 없으면 추가.
    if let bookID = bookID {
      delegate?.updateBookTappedButton(self, didUpdate: book, bookID: bookID)
    } else {
      delegate?.addBookTappedButton(self, didAdd: book)
    }
    dismiss(animated: true)
  }
  
  
}

