import UIKit

final class BookListViewController: UIViewController  {
  
  
  
  
  private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  private enum Section { case main }
  
  
  
  private struct Item: Hashable {
    let viewModel: BookListCell.ViewModel
    
//    static func == (lhs: BookListViewController.Item, rhs: BookListViewController.Item) -> Bool {
//      return lhs.viewModel == rhs.viewModel
//    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(viewModel.id)
    }
    
  }
  
  
  private var dataSource: DataSource!
  
  
  private var collectionView: UICollectionView!
  private var viewModel = BookListViewModel()
  
  // MARK: - ui
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
    
    //collectionView.delegate = self
    //collectionView.dataSource = self
    
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
    ])
    
    collectionView.register(BookListCell.self, forCellWithReuseIdentifier: bookListCell.bookListIdentifier)
  }
  
  private func naviButton() {
    let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                    target: self,
                                    action: #selector(didTapAdd))
    navigationItem.rightBarButtonItem = addButton
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    self.title = "책 목록"
    
    naviButton()
    setupCollectionView()
    setupDataSource()
    viewModel.delegate = self
    
  }
  
  
  
  private func setupDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Item>( collectionView: collectionView ) { [weak self] collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell( withReuseIdentifier: bookListCell.bookListIdentifier, for: indexPath) as? BookListCell,
            let self = self
      else {
        return UICollectionViewCell()
      }
      
      cell.updateDelegate = self
      cell.deleteDelegate = self
    
      
      cell.configure(viewModel: item.viewModel) // 셀에 있던 구조체에 들어간 거 받아넣음..하나씩
      return cell
      
      
    }
  }
  
  
  private func applySnapshot(items: [Item], animated: Bool = true) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.main])
    snapshot.appendItems(items, toSection: .main)
    dataSource.apply(snapshot, animatingDifferences: animated)
  }
  
  // MARK: - 버튼동작
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
  
  
}

// MARK: - 델리게이트

extension BookListViewController: AddBookViewControllerDelegate {
  
  
  func addBookTappedButton(_ vc: AddBookViewController, didAdd book: Book) {
    viewModel.addBookTappedButton(addBook: book)
  }
  
  
  func updateBookTappedButton(_ vc: AddBookViewController, didUpdate book: Book, bookID: String) {
    viewModel.handleTapUpdateButton(updatedBook: book, bookID: bookID)
    
  }
}

extension BookListViewController: BookListCellUpdateDelegate {
  
  func didTapUpdateButton(bookID: String) {
    guard let book = viewModel.findBook(by: bookID) else { return }
    
    let addBookVC = AddBookViewController()
    addBookVC.delegate = self
    addBookVC.bookEdit = book
    addBookVC.bookID = bookID
    
    let navVC = UINavigationController(rootViewController: addBookVC)
    present(navVC, animated: true)
  }
}


extension BookListViewController: BookListCellDeleteDelegate {
  func didTapDeleteButton(bookID: String) {
    self.viewModel.handleTapDeleteButton(bookID: bookID)
  }
}


extension BookListViewController: viewModelDelegate {
  func reloadData(books: [BookListCell.ViewModel]) {
    applySnapshot(items: books.map { Item(viewModel: $0) })
  }
}

