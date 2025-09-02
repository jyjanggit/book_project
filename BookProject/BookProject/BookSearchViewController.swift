//
//  BookSearchViewController.swift
//  BookProject
//
//  Created by JY Jang on 8/31/25.
//

import UIKit

final class BookSearchViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating {
  
  
  func updateSearchResults(for searchController: UISearchController) {
  }
  
  
  private var collectionView: UICollectionView!
  
  let uISearchController: UISearchController = {
    let uISearchController = UISearchController(searchResultsController: nil)
    uISearchController.obscuresBackgroundDuringPresentation = false
    uISearchController.hidesNavigationBarDuringPresentation = false
    uISearchController.searchBar.placeholder = "책 제목을 검색하세요"
    uISearchController.searchBar.returnKeyType = .search
    return uISearchController
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hex: "#FFFFFF")
    self.title = "책 검색"
    setupLayout()
  }
  
  private func setupLayout() {
    uISearchController.searchResultsUpdater = self
    uISearchController.searchBar.delegate = self
    
    navigationItem.searchController = uISearchController
    navigationItem.hidesSearchBarWhenScrolling = false
    
    definesPresentationContext = true
  }

  
  
}



