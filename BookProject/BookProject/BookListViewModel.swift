//
//  BookListViewModel.swift
//  BookProject
//
//  Created by JY Jang on 8/5/25.
//
protocol AddBookViewControllerDelegate: AnyObject {
  func addBookViewController(_ vc: AddBookViewController, didAdd book: Book)
}

final class BookListViewModel {
  
  // 책 목록 배열
  private var books: [Book] = []
  
  // 책 추가
  func addBook(_ book: Book) {
    books.append(book)
    
  }
  
  // 책 개수
  var numberOfBooks: Int {
    return books.count
  }
  
  
  // 해당 셀이 어떤 책인지 위치 확인
  func book(index: Int) -> Book {
    return books[index]
  }
}
