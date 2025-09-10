//
//  BookListViewModel.swift
//  BookProject
//
//  Created by JY Jang on 8/5/25.
//

import UIKit

protocol AddBookViewControllerDelegate: AnyObject {
  func addBookTappedButton(_ vc: AddBookViewController, didAdd book: Book)
  func updateBookTappedButton(_ vc: AddBookViewController, didUpdate book: Book, bookID: String)
}

protocol viewModelDelegate: AnyObject {
  func reloadData(books: [Book])
}

protocol BookListCellUpdateDelegate: AnyObject {
  func didTapUpdateButton(bookID: String)
}

protocol BookListCellDeleteDelegate: AnyObject {
  func didTapDeleteButton(bookID: String)
}


final class BookListViewModel {
  
  weak var delegate: viewModelDelegate?
  
  // 책 목록 배열
  private var books: [Book] = []
  
  // 책 추가
  func addBook(_ book: Book) {
    books.append(book)
    delegate?.reloadData(books: books)
  }
  
  // 책 개수
  var numberOfBooks: Int {
    return books.count
  }
  
  
  // 해당 셀이 어떤 책인지 위치 확인
  func book(index: Int) -> Book {
    return books[index]
  }
  
  func bookViewModel(index: Int) -> BookListCell.ViewModel? {
    let percentage = books[index].totalPage > 0 ? (CGFloat(books[index].currentPage) / CGFloat(books[index].totalPage) * 100) : 0

    return BookListCell.ViewModel (
      id: books[index].id,
      title: books[index].bookTitle,
      currentPage: "\(books[index].currentPage)쪽",
      totalPage: "\(books[index].totalPage)쪽",
      chartReadValue: [(UIColor(hex: "#a2bafb"), percentage)]
    )

  }
  
  func findBook(by id: String) -> Book? {
    // 아이디로 책 찾는 기능
    if let index = books.firstIndex(where: { $0.id == id }) { return books[index] }
    return nil
  }
  
  // 책 수정
  func updateBook(_ updatedBook: Book, bookID: String) {
    guard let index = books.firstIndex(where: { $0.id == bookID }) else { return }
    books[index] = updatedBook
    delegate?.reloadData(books: books)
  }
  
  // 책 삭제
  func deleteBook(bookID: String) {
    
    guard let index = books.firstIndex(where: { $0.id == bookID }) else { return }
    
    books.remove(at: index)
    delegate?.reloadData(books: books)
  }
  
}
