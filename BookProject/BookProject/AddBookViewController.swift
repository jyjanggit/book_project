import UIKit

class AddBookViewController: UIViewController {
  
  weak var delegate: AddBookViewControllerDelegate?
  
  var bookEdit: Book?
  var bookIndex: Int?
  
  let titleTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책 제목을 입력하세요"
    text.applyUITextField()
    return text
  }()
  
  let totalTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책의 총 페이지수"
    text.keyboardType = .numberPad
    text.applyUITextField()
    return text
  }()
  
  let currentTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "책의 현재 페이지수"
    text.keyboardType = .numberPad
    text.applyUITextField()
    return text
  }()
  
  lazy var textFieldStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [titleTextField, totalTextField, currentTextField])
    stack.axis = .vertical
    stack.spacing = 20
    stack.alignment = .fill
    return stack
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    self.title = bookEdit == nil ? "책 추가" : "책 수정"
    
    if let editBook = bookEdit {
      titleTextField.text = editBook.bookTitle
      totalTextField.text = "\(editBook.totalPage)"
      currentTextField.text = "\(editBook.currentPage)"
    }
    
    
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
    
    setupLayout()
  }
  
  private func setupLayout() {
    view.addSubview(textFieldStackView)
    
    textFieldStackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      textFieldStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      textFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])
  }
  
  
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
    
    let book = Book(bookTitle: title, totalPage: total, currentPage: current)
    
    // 만약 책 인덱스가 있으면(기존 책이면) 수정, 없으면 추가.
    if let index = bookIndex {
      delegate?.updateBookViewController(self, didUpdate: book, index: index)
    } else {
      delegate?.addBookViewController(self, didAdd: book)
    }
    dismiss(animated: true)
  }
  
  
}

