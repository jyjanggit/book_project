//
//  BookSearchViewController.swift
//  BookProject
//
//  Created by JY Jang on 8/31/25.
//

import UIKit


final class BookSearchViewController: UIViewController {
  


  
  private var collectionView: UICollectionView!
  
  //private var bookList: [Item] = []
  
  let uISearchController: UISearchController = {
    let uISearchController = UISearchController(searchResultsController: nil)
    uISearchController.obscuresBackgroundDuringPresentation = false
    uISearchController.hidesNavigationBarDuringPresentation = false
    uISearchController.searchBar.placeholder = "책 제목을 검색하세요"
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
    
    collectionView.delegate = self
    collectionView.dataSource = self
    
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
    uISearchController.searchResultsUpdater = self
    uISearchController.searchBar.delegate = self
    
    navigationItem.searchController = uISearchController
    navigationItem.hidesSearchBarWhenScrolling = false
    
    definesPresentationContext = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    self.title = "책 검색"
    setupCollectionView()
    setupLayout()
    //Networking.shared.getMethod()
  }
  
  
}


extension BookSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 5 // 테스트용
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bookSearchCell.bookSearchIdentifier, for: indexPath) as? SearchListCell else { return UICollectionViewCell() }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width - 32, height: 0)
  }
}


extension BookSearchViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let keyword = searchController.searchBar.text
  }
}


extension BookSearchViewController: UISearchBarDelegate {
  func searchBarButtonCliked(_ searchBar: UISearchBar) {
  }
}


