//
//  BookListViewModel.swift
//  BookProject
//
//  Created by JY Jang on 8/5/25.
//

import UIKit

protocol AddBookViewControllerDelegate: AnyObject {
  func addBookTappedButton(_ vc: AddBookViewController, didAdd book: Book)
  func updateBookTappedButton(_ vc: AddBookViewController, didUpdate book: Book, index: Int)
}

protocol viewModelDelegate: AnyObject {
  func reloadDataAdd()
  func reloadDataUpdate()
  func reloadDataDelete(index: Int)
}


final class BookListViewModel {
  
  weak var delegate: viewModelDelegate?
  
  // 책 목록 배열
  private var books: [Book] = []
  
  // 책 추가
  func addBook(_ book: Book) {
    books.append(book)
    delegate?.reloadDataAdd()
  }
  
  // 책 개수
  var numberOfBooks: Int {
    return books.count
  }
  
  
  // 해당 셀이 어떤 책인지 위치 확인
  func book(index: Int) -> Book {
    return books[index]
  }
  
  // 책 수정
  func updateBook(_ updatedBook: Book, index: Int) {
    books[index] = updatedBook
    delegate?.reloadDataUpdate()
  }
  
  // 책 삭제
  func deleteBook(index: Int) {
    books.remove(at: index)
    delegate?.reloadDataDelete(index: index)
  }
  
}
