//
//  BookListViewController.swift
//  BookProject
//
//  Created by JY Jang on 8/7/25.
//
import UIKit


final class BookListViewController: UIViewController, UIViewControllerTransitioningDelegate{
  
  private var collectionView: UICollectionView!
  
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
    let navViewController = UINavigationController(rootViewController: addBookViewController)
    if #available(iOS 15.0, *) {
      if let sheet = navViewController.sheetPresentationController {
        sheet.detents = [.medium()]
        sheet.prefersGrabberVisible = true
        sheet.preferredCornerRadius = 16
      }
    } else {
      navViewController.modalPresentationStyle = .custom
      navViewController.transitioningDelegate = self
    }
    present(navViewController, animated: true)
  }
  
  
  private func setupCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    layout.minimumLineSpacing = 20
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = UIColor(hex: "#FFFFFF")
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    
    // 16이상이면 활성화
    if #available(iOS 16.0, *) {
      collectionView.selfSizingInvalidation = .enabledIncludingConstraints
    }
    
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
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookListCell", for: indexPath) as? BookListCell else {
      return UICollectionViewCell()
    }
    cell.backgroundColor = UIColor(hex: "#FFFFFF")
    
    return cell
  }
}



