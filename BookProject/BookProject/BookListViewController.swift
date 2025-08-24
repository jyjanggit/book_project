import UIKit

final class BookListViewController: UIViewController {
  
  private var collectionView: UICollectionView!
  private var viewModel = BookListViewModel()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    self.title = "책 목록"
    
    let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                    target: self,
                                    action: #selector(didTapAdd))
    navigationItem.rightBarButtonItem = addButton
    
    setupCollectionView()
  }
  
  @objc private func didTapAdd() {
    let addBookViewController = AddBookViewController()
    addBookViewController.delegate = self
    
    let navViewController = UINavigationController(rootViewController: addBookViewController)
    if let sheet = navViewController.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.prefersGrabberVisible = true
      sheet.preferredCornerRadius = 16
    }
    present(navViewController, animated: true)
  }
  
  private func setupCollectionView() {
    let layout = UICollectionViewCompositionalLayout {_,_ in
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: .init(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(0.0)
        ),
        subitems: [
          .init(layoutSize: .init(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(0.0)
          ))
        ]
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
      section.interGroupSpacing = 20
      return section
    }
    
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = UIColor(hex: "#FFFFFF")
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    collectionView.delegate = self
    collectionView.dataSource = self
    
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
    ])
    
    collectionView.register(BookListCell.self, forCellWithReuseIdentifier: "BookListCell")
  }
}

extension BookListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfBooks
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookListCell", for: indexPath) as? BookListCell else {
      return UICollectionViewCell()
    }
    let book = viewModel.book(index: indexPath.item)
    cell.titleLabel.text = book.bookTitle
    cell.currentPageLabel.text = "\(book.currentPage)쪽"
    cell.totalPageLabel.text = "\(book.totalPage)쪽"
    let percentage = book.totalPage > 0 ? (CGFloat(book.currentPage) / CGFloat(book.totalPage) * 100) : 0
    cell.chartView.readValue = [(UIColor(hex: "#a2bafb"), percentage)]
    
    cell.updateDelegate = self
    cell.deleteDelegate = self
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    .init(width: collectionView.bounds.width - 32, height: 0)
  }
}


extension BookListViewController: AddBookViewControllerDelegate {
  
  
  func addBookViewController(_ vc: AddBookViewController, didAdd book: Book) {
    viewModel.addBook(book)
    collectionView.reloadData()
  }
  
  
  func updateBookViewController(_ vc: AddBookViewController, didUpdate book: Book, index: Int) {
    viewModel.updateBook(book, index: index)
    collectionView.reloadData()
    
  }
}

extension BookListViewController: BookListCellUpdateDelegate {
  
  func didTapUpdateButton(cell: BookListCell) {
    guard let indexPath = collectionView.indexPath(for: cell) else { return }
    let book = viewModel.book(index: indexPath.item)
    
    let addBookVC = AddBookViewController()
    addBookVC.delegate = self
    addBookVC.bookEdit = book
    addBookVC.bookIndex = indexPath.item
    
    let navVC = UINavigationController(rootViewController: addBookVC)
    present(navVC, animated: true)
  }
}


extension BookListViewController: BookListCellDeleteDelegate {
  func didTapDeleteButton(cell: BookListCell) {
    guard let indexPath = collectionView.indexPath(for: cell) else { return }
    
    self.viewModel.deleteBook(index: indexPath.item)
    
    self.collectionView.deleteItems(at: [indexPath])
    
  }
}
