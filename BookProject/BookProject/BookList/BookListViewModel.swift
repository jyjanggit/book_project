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

protocol BookListRepository: AnyObject {
  func fetchBooks() -> [Book]
  func saveBookData(book: Book, completion: @escaping () -> Void)
  func deleteBookData(data: Book, completion: @escaping () -> Void)
  func updateBookData(updateData: Book, completion: @escaping () -> Void)
}


final class BookListRepositoryImpl: BookListRepository {
  
  private let coreDataManager = CoredataManager.shared
  
  func fetchBooks() -> [Book] {
    coreDataManager.getBookListFromCoreData().map { bookData in
      Book(
        id: bookData.id,
        bookTitle: bookData.bookTitle,
        totalPage: Int(bookData.totalPage),
        currentPage: Int(bookData.currentPage)
      )
    }
  }
  
  
  func saveBookData(book: Book, completion: @escaping () -> Void) {
    coreDataManager.saveBookData(book: book, completion: completion)
  }
  
  func updateBookData(updateData: Book, completion: @escaping () -> Void) {
    coreDataManager.updateBookData(updateData: updateData, completion: completion)
  }
  
  func deleteBookData(data: Book, completion: @escaping () -> Void) {
    coreDataManager.deleteBookData(data: data, completion: completion)
  }
}



final class BookListViewModel {
  
  weak var delegate: viewModelDelegate?
  private let bookListRepository: BookListRepository
  private var books: [Book] = []
  
  init(bookListRepository: BookListRepository) {
    self.bookListRepository = bookListRepository
  }
  
  // 데이터 호출(코어데이터에서)
  func loadBooks() {
    self.books = bookListRepository.fetchBooks()
    let viewModels = convertToViewModels(books)
    notifyDelegate(with: viewModels)
  }
  
  private func convertToViewModels(_ books: [Book]) -> [BookListCell.ViewModel] {
    return books.map { book in
      BookListCell.ViewModel(
        id: book.id,
        title: book.bookTitle,
        currentPage: "\(book.currentPage)쪽",
        totalPage: "\(book.totalPage)쪽",
        chartReadValue: book.percentage
      )
    }
  }
  
  private func notifyDelegate(with viewModels: [BookListCell.ViewModel]) {
    delegate?.reloadData(books: viewModels)
  }
  
  // 책 추가
  func addBookTappedButton(addBook: Book) {
    bookListRepository.saveBookData(book: addBook) { [weak self] in
      guard let self else {
        return
      }
      
      books.append(addBook)
      notifyDelegate(with: convertToViewModels(books))
    }
  }
  
  func findBook(by id: String) -> Book? {
    books.first(where: { $0.id == id })
  }
  
  // 책 수정
  func handleTapUpdateButton(updatedBook: Book, bookID: String) {
    guard let targetIndex = books.firstIndex(where: { $0.id == bookID }) else {
      return
    }
    
    bookListRepository.updateBookData(updateData: updatedBook) { [weak self] in
      guard let self else {
        return
      }
      
      self.books[targetIndex] = updatedBook
      self.notifyDelegate(with: self.convertToViewModels(self.books))
    }
  }
  
  // 책 삭제
  func handleTapDeleteButton(bookID: String) {
    guard let targetBookData = books.first(where: { $0.id == bookID }) else {
      return
    }
    
    bookListRepository.deleteBookData(data: targetBookData) { [weak self] in
      guard let self else {
        return
      }
      
      books.removeAll(where: { $0.id == bookID })
      notifyDelegate(with: convertToViewModels(books))
    }
  }
}
