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
  func reloadData(books: [BookListCell.ViewModel])
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
    bookToViewModelReloadDelegate()
  }
  
  
  // 해당 셀이 어떤 책인지 위치 확인
  func book(index: Int) -> Book {
    return books[index]
  }
  
  private func bookToViewModelReloadDelegate() {
    // 1.Book ->BookListCell.ViewModel로 변환
    let viewModels = books.map { book in
      BookListCell.ViewModel(
        id: book.id,
        title: book.bookTitle,
        currentPage: "\(book.currentPage)쪽",
        totalPage: "\(book.totalPage)쪽",
        chartReadValue: [(UIColor(hex: "#a2bafb"), book.percentage)]
      )
    }
    // 2.변환한 것을 담아서 리로드
    delegate?.reloadData(books: viewModels)
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
    bookToViewModelReloadDelegate()
  }
  
  // 책 삭제
  func deleteBook(bookID: String) {
    guard let index = books.firstIndex(where: { $0.id == bookID }) else { return }
    books.remove(at: index)
    bookToViewModelReloadDelegate()
  }
  
}
