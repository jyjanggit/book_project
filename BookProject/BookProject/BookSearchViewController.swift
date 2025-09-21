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
  
  private struct Item: Hashable {
    let viewModel: SearchModel
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(viewModel.itemId)
    }
    
  }
  private var dataSource: DataSource!
  
  
  private var collectionView: UICollectionView!
  private var viewModel = BookSearchViewModel()
  
  
  
  
  let uISearchController: UISearchController = {
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
  
  
  // api
  var networkManager = Networking.shared
  // 이거 뷰모델로 안보내도되나? 근데 보내면Item이없는데..
  func fetchBooks(query: String) {
    networkManager.fetchData(searchText: query) { (result: Result<BookResponse, NetworkError>) in
      switch result {
      case .success(let bookResponse):
        print("검색 성공: \(query)")
        
        DispatchQueue.main.async {
          self.viewModel.bookSearchList = bookResponse.item
          let searchModels = self.viewModel.bookSearchResultToSearchModel(bookResponse.item)
          self.applySnapshot(items: searchModels.map { Item(viewModel: $0) }, animated: true)
        }
        
      case .failure(let error):
        print("검색 실패: \(error.localizedDescription)")
      }
    }
  }
  
  private func setupDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Item>( collectionView: collectionView ) { [weak self] collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell( withReuseIdentifier: bookSearchCell.bookSearchIdentifier, for: indexPath) as? SearchListCell,
            let self = self
      else {
        return UICollectionViewCell()
      }
      
      let bookData = item.viewModel
      cell.configure(viewModel: bookData)
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
    setupCollectionView()
    setupLayout()
    setupDataSource()
  }
  
  
}

extension BookSearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text, !query.isEmpty else { return }
    fetchBooks(query: query)
  }
}


