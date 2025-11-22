import UIKit
import SnapKit
import Combine

final class BookListViewController: UIViewController {
  
  private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  private enum Section { case main }
  
  private struct Item: Hashable {
    
    let viewModel: BookListCell.ViewModel
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(viewModel.id)
    }
    
  }
  
  private var dataSource: DataSource!
  private var collectionView: UICollectionView!
  private var viewModel = BookListViewModel(bookListRepository: BookListRepositoryImpl() )
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    setupNavigationItem()
    setupCollectionView()
    setupLayout()
    setupDataSource()
    bindViewModel()
    viewModel.loadBooks()
    
  }
  
  // MARK: - setupNavigationItem
  
  private func setupNavigationItem() {
    
    let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                    target: self,
                                    action: #selector(didTapAdd))
    addButton.accessibilityLabel = "책 추가"
    addButton.accessibilityHint = "읽은 책을 추가 할 수 있습니다."
    
    navigationItem.rightBarButtonItem = addButton
    navigationItem.title = "책 목록"
    
  }
  
  // MARK: - setupCollectionView
  
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
    
    view.addSubview(collectionView)
    
    collectionView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    collectionView.register(BookListCell.self, forCellWithReuseIdentifier: BookListCellConstants.bookListIdentifier)
    
  }
  
  // MARK: - setupLayout
  
  private func setupLayout() {
    
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    
  }
  
  // MARK: - setupDataSource
  
  private func setupDataSource() {
    
    dataSource = UICollectionViewDiffableDataSource<Section, Item>( collectionView: collectionView ) { [weak self] collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell( withReuseIdentifier: BookListCellConstants.bookListIdentifier, for: indexPath) as? BookListCell,
            let self = self
      else {
        return UICollectionViewCell()
      }
      
      cell.updateDelegate = self
      cell.deleteDelegate = self
      cell.configure(viewModel: item.viewModel)
      return cell
    }
    
  }
  
  // MARK: - bindViewModel
  
  private func bindViewModel() {
    
      viewModel.$bookViewModels
      .receive(on: DispatchQueue.main)
      .sink { [weak self] viewModels in
        self?.applySnapshot(items: viewModels.map { bookViewModel in
          Item(viewModel: bookViewModel)
        })
      }
      .store(in: &cancellables)
    
  }

  // MARK: - 버튼동작
  
  @objc private func didTapAdd() {
    
    presentAddBookScreen(bookToEdit: nil, bookID: nil)
    
  }
  
  // MARK: - Private Mathods
  
  private func applySnapshot(items: [Item], animated: Bool = true) {
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.main])
    snapshot.appendItems(items, toSection: .main)
    dataSource.apply(snapshot, animatingDifferences: animated)
    
  }
  
  // 추가, 수정 모달창 공통
  private func presentAddBookScreen(bookToEdit: Book?, bookID: String?) {
    
    let addBookViewController = AddBookViewController()
    addBookViewController.delegate = self
    addBookViewController.bookEdit = bookToEdit
    addBookViewController.bookID = bookID
    
    let navViewController = UINavigationController(rootViewController: addBookViewController)
    if let sheet = navViewController.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.prefersGrabberVisible = true
      sheet.preferredCornerRadius = 16
    }
    present(navViewController, animated: true)
    
  }
  
}

// MARK: - AddBookViewControllerDelegate

extension BookListViewController: AddBookViewControllerDelegate {
  
  func didTapAddButton(_ vc: AddBookViewController, didAdd book: Book) {
    viewModel.TappedAddButton(book: book)
  }

  func didUpdateExistingBook(_ vc: AddBookViewController, didUpdate book: Book, bookID: String) {
    viewModel.TappedUpdateButton(book: book, bookID: bookID)
  }
  
}

// MARK: - BookListCellUpdateDelegate

extension BookListViewController: BookListCellUpdateDelegate {
  
  func didTapUpdateButton(bookID: String) {
    guard let book = viewModel.findBook(by: bookID) else { return }
    presentAddBookScreen(bookToEdit: book, bookID: bookID)
  }
  
}

// MARK: - BookListCellDeleteDelegate

extension BookListViewController: BookListCellDeleteDelegate {
  
  func didTapDeleteButton(bookID: String) {
    self.viewModel.TappedDeleteButton(bookID: bookID)
  }
  
}



