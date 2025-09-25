//
//  BookSearchViewController.swift
//  BookProject
//
//  Created by JY Jang on 8/31/25.
//

import UIKit


final class BookSearchViewController: UIViewController {
  
  private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  private enum Section { case main }
  
  struct Item: Hashable {
    let viewModel: SearchListCell.ViewModel
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(viewModel.itemId)
    }
    
  }
  private var dataSource: DataSource!
  
  
  private var collectionView: UICollectionView!
  private var viewModel = BookSearchViewModel()
  
  
  
  
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
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
    ])
    
    collectionView.register(SearchListCell.self, forCellWithReuseIdentifier: "SearchListCell")
  }
  
  private func setupLayout() {
    //uISearchController.searchResultsUpdater = self
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
        withReuseIdentifier: bookSearchCell.bookSearchIdentifier,
        for: indexPath
      ) as? SearchListCell else {
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
    viewModel.delegate = self
    setupCollectionView()
    setupLayout()
    setupDataSource()
  }
  
  
}

extension BookSearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text, !query.isEmpty else { return }
    viewModel.searchBarSearchButtonTapped(query: query)
  }
}


extension BookSearchViewController: BookSearchViewModelDelegate {
  func reloadData(items: [Item]) {
    DispatchQueue.main.async {
      self.applySnapshot(items: items)
    }
  }
}
