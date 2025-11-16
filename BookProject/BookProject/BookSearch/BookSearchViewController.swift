//
//  BookSearchViewController.swift
//  BookProject
//
//  Created by JY Jang on 8/31/25.
//

import UIKit
import SnapKit
import Combine


final class BookSearchViewController: UIViewController {
  
  private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  private enum Section { case main }
  
  struct Item: Hashable {
    let viewModel: BookSearchCell.ViewModel
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(viewModel.itemId)
    }
    
  }
  private var dataSource: DataSource!
  
  
  private var collectionView: UICollectionView!
  private var viewModel = BookSearchViewModel(bookSearchRepository: BookSearchRepositoryImpl())
  private var cancellables = Set<AnyCancellable>()

  
  
  
  private let uISearchController: UISearchController = {
    let uISearchController = UISearchController(searchResultsController: nil)
    uISearchController.obscuresBackgroundDuringPresentation = false
    uISearchController.hidesNavigationBarDuringPresentation = false
    uISearchController.searchBar.placeholder = "책 제목, 저자를 검색하세요"
    uISearchController.searchBar.returnKeyType = .search
    return uISearchController
  }()
  
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
    
    collectionView.register(BookSearchCell.self, forCellWithReuseIdentifier: "SearchListCell")
  }
  
  private func setupLayout() {
    uISearchController.searchBar.delegate = self
    
    navigationItem.searchController = uISearchController
    navigationItem.hidesSearchBarWhenScrolling = false
    
    definesPresentationContext = true
  }
  
  
  
  
  
  private func setupDataSource() {
    dataSource = UICollectionViewDiffableDataSource<
      Section,
      Item
    >(collectionView: collectionView) { collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: BookSearchCellConstants.bookSearchIdentifier,
        for: indexPath
      ) as? BookSearchCell else {
        return UICollectionViewCell()
      }
      
      cell.configure(viewModel: item.viewModel)
      return cell
    }
  }
  
  
  private func applySnapshot(items: [Item], animated: Bool = true) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.main])
    snapshot.appendItems(items, toSection: .main)
    dataSource.apply(snapshot, animatingDifferences: animated)
  }
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    self.title = "책 검색"
    bindViewModel()
    setupCollectionView()
    setupLayout()
    setupDataSource()
  }
  
  
  private func bindViewModel() {
    viewModel.$searchResults
      .receive(on: DispatchQueue.main)
      .sink { [weak self] search in
        self?.applySnapshot(items: search, animated: true)
      }.store(in: &cancellables)

  }
  
}




extension BookSearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text, !query.isEmpty else { return }
    viewModel.searchBarSearchButtonTapped(query: query)
  }
}

