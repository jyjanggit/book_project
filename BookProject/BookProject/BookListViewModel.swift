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
  let coreDataManager = CoredataManager.shared
  lazy var bookDataList = coreDataManager.getBookListFromCoreData()
  
  
  //private var books: [Book] = []
  
  // 데이터 호출(코어데이터에서)
  func loadBooks() {
    let coreDataBooks = fetchBooksFromCoreData()
    let domainBooks = convertToDomainModels(coreDataBooks)
    let viewModels = convertToViewModels(domainBooks)
    notifyDelegate(with: viewModels)
  }
  
  private func fetchBooksFromCoreData() -> [BookDataModel] {
    return coreDataManager.getBookListFromCoreData()
  }
  
  private func convertToDomainModels(_ bookDataList: [BookDataModel]) -> [Book] {
    return bookDataList.map { bookData in
      Book(
        id: bookData.id,
        bookTitle: bookData.bookTitle,
        totalPage: Int(bookData.totalPage),
        currentPage: Int(bookData.currentPage)
      )
    }
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
    coreDataManager.saveBookData(
      id: addBook.id,
      bookTitle: addBook.bookTitle,
      totalPage: Int16(addBook.totalPage),
      currentPage: Int16(addBook.currentPage),
      percentage: Double(addBook.percentage)
    ) { [weak self] in
      self?.loadBooks()
    }
  }
  
  
  //  private func bookToViewModelReloadDelegate() {
  //    // 1.Book ->BookListCell.ViewModel로 변환
  //    let viewModels = books.map { book in BookListCell.ViewModel(
  //        id: book.id,
  //        title: book.bookTitle,
  //        currentPage: "\(book.currentPage)쪽",
  //        totalPage: "\(book.totalPage)쪽",
  //        chartReadValue: book.percentage
  //    )}
  //    // 2.변환한 것을 담아서 리로드
  //    delegate?.reloadData(books: viewModels)
  //    
  //    
  //    
  //  }
  
  
  
  func findBook(by id: String) -> Book? {
    // 아이디로 책 찾는 기능
    if let bookData = bookDataList.firstIndex(where: { $0.id == id }) {
      return Book(
        id: bookData.id,
        bookTitle: bookData.bookTitle,
        totalPage: Int(bookData.totalPage),
        currentPage: Int(bookData.currentPage)
      )
    }
    return nil
  }
  
  // 책 수정
  func handleTapUpdateButton(updatedBook: Book, bookID: String) {
    
    if let targetBookData = bookDataList.firstIndex(where: { $0.id == bookID }) {
      targetBookData.bookTitle = updatedBook.bookTitle
      targetBookData.totalPage = Int16(updatedBook.totalPage)
      targetBookData.currentPage = Int16(updatedBook.currentPage)
      targetBookData.percentage = Double(updatedBook.percentage)
      
      coreDataManager.updateBookData(updateData: targetBookData) { [weak self] in
        self?.loadBooks()
      }
    }
    
    // 책 삭제
    func handleTapDeleteButton(bookID: String) {
      if let targetBookData = bookDataList.firstIndex(where: { $0.id == bookID }) {
        coreDataManager.deleteBookData(data: targetBookData) { [weak self] in
          self?.loadBooks()
        }
      }
    }
    
  }
