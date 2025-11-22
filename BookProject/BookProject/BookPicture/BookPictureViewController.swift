import UIKit
import SnapKit
import Combine

final class BookPictureViewController: UIViewController {
  
  private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  private enum Section { case main }
  
  private struct Item: Hashable {
    let viewModel: BookPictureCell.ViewModel
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(viewModel.id)
    }
  }
  
  private var dataSource: DataSource!
  private var collectionView: UICollectionView!
  private var viewModel = BookPictureViewModel(bookPictureRepository: BookPictureRepositoryImpl())
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationItem()
    setupCollectionView()
    setupLayout()
    setupDataSource()
    bindViewModel()
    viewModel.loadPictures()
  }
  
  // MARK: - setupNavigationItem
  
  private func setupNavigationItem() {
    let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                    target: self,
                                    action: #selector(didTapAdd))
    navigationItem.rightBarButtonItem = addButton
    addButton.accessibilityLabel = "책 구절 추가"
    addButton.accessibilityHint = "책의 구절 사진과 메모를 추가 할 수 있습니다."
    
    navigationItem.title = "책 구절"
  }
  
  // MARK: - setupCollectionView
  private func setupCollectionView() {
    let layout = UICollectionViewCompositionalLayout { _, _ in
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0/3.0),
        heightDimension: .fractionalHeight(1.0)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalWidth(1.0/3.0)
      )
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: groupSize,
        subitem: item,
        count: 3
      )
      
      let section = NSCollectionLayoutSection(group: group)
      return section
    }
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = UIColor(hex: "#FFFFFF")
    collectionView.delegate = self
    
    view.addSubview(collectionView)
    
    collectionView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    collectionView.register(BookPictureCell.self, forCellWithReuseIdentifier: BookPictureCellConstants.bookPictureIdentifier)
  }
  
  // MARK: - setupLayout
  
  private func setupLayout() {
    view.backgroundColor = UIColor(hex: "#FFFFFF")
  }
  
  // MARK: - setupDataSource
  
  private func setupDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: BookPictureCellConstants.bookPictureIdentifier,
        for: indexPath
      ) as? BookPictureCell else {
        return UICollectionViewCell()
      }
      
      cell.configure(viewModel: item.viewModel)
      return cell
    }
  }

  // MARK: - bindViewModel
  
  private func bindViewModel() {
    viewModel.$pictureViewModels
      .receive(on: DispatchQueue.main)
      .sink { [weak self] picture in
        self?.applySnapshot(items: picture.map { pictureViewModel in
          Item(viewModel: pictureViewModel)
        })
      }
      .store(in: &cancellables)
  }
  
  // MARK: - 버튼동작
  
  @objc private func didTapAdd() {
    let addBookPictureViewController = AddBookPictureViewController()
    addBookPictureViewController.delegate = self
    
    let navViewController = UINavigationController(rootViewController: addBookPictureViewController)
    if let sheet = navViewController.sheetPresentationController {
      sheet.prefersGrabberVisible = true
      sheet.preferredCornerRadius = 16
    }
    present(navViewController, animated: true)
  }
  
  // MARK: - Private Mathods
  
  private func applySnapshot(items: [Item], animated: Bool = true) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.main])
    snapshot.appendItems(items, toSection: .main)
    dataSource.apply(snapshot, animatingDifferences: animated)
  }
}

// MARK: - AddBookPictureViewControllerDelegate

extension BookPictureViewController: AddBookPictureViewControllerDelegate {
  
  func didTapAddButton(_ vc: AddBookPictureViewController, didAdd picture: BookPictureModel) {
    viewModel.TappedAddButton(addPicture: picture)
  }
}

// MARK: - UICollectionViewDelegate

extension BookPictureViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
    
    let detailVC = BookPictureDetailViewController()
    detailVC.pictureID = item.viewModel.id
    detailVC.viewModel = viewModel
    navigationController?.pushViewController(detailVC, animated: true)
  }
}


