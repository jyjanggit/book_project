//
//  PictureViewController.swift
//  BookProject
//
//  Created by JY Jang on 10/3/25.
//


import UIKit
import SnapKit

final class BookPictureViewController: UIViewController  {
  
  private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  private enum Section { case main }
  
  
  
  private struct Item: Hashable {
    let id: String
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
  }
  
  
  private var dataSource: DataSource!
  
  
  private var collectionView: UICollectionView!
  //private var viewModel = BookListViewModel(bookListRepository: BookListRepositoryImpl() )
  
  // MARK: - ui
  private func setupCollectionView() {
    let layout = UICollectionViewCompositionalLayout {_,_ in
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
    
    view.addSubview(collectionView)
    
    collectionView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }

    
    collectionView.register(BookPictureCell.self, forCellWithReuseIdentifier: BookPictureCellConstants.bookPictureIdentifier)
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
    self.title = "책 구절"
    naviButton()
    setupCollectionView()
    setupDataSource()
    
    let testItems = (0..<20).map { index in
      Item(id: UUID().uuidString)  // 고유한 ID 생성
    }
    
    // 스냅샷에 데이터 적용 (화면에 보이게)
    applySnapshot(items: testItems)
    
    
    collectionView.delegate = self
    //viewModel.delegate = self
    
    //viewModel.loadBooks()
    
  }
  
  
  
  private func setupDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Item>( collectionView: collectionView ) { [weak self] collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell( withReuseIdentifier: BookPictureCellConstants.bookPictureIdentifier, for: indexPath) as? BookPictureCell,
            let self = self
      else {
        return UICollectionViewCell()
      }
      
      //cell.updateDelegate = self
      //cell.deleteDelegate = self
    
      
      //cell.configure(viewModel: item.viewModel) // 셀에 있던 구조체에 들어간 거 받아넣음..하나씩
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
    let addBookPictureViewController = AddBookPictureViewController()
    //addBookViewController.delegate = self
    
    let navViewController = UINavigationController(rootViewController: addBookPictureViewController)
    if let sheet = navViewController.sheetPresentationController {
      //sheet.detents = [.medium()]
      sheet.prefersGrabberVisible = true
      sheet.preferredCornerRadius = 16
    }
    present(navViewController, animated: true)
  }
  
  
}

// MARK: - 델리게이트



extension BookPictureViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let detailVC = BookPictureDetailViewController()
    navigationController?.pushViewController(detailVC, animated: true)
  }
}
