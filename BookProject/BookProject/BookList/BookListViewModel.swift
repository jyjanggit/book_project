//
//  BookListViewModel.swift
//  BookProject
//
//  Created by JY Jang on 8/5/25.
//

import UIKit
import Combine

// MARK: - Delegate

protocol AddBookViewControllerDelegate: AnyObject {
  func didTapAddButton(_ vc: AddBookViewController, didAdd book: Book)
  func didUpdateExistingBook(_ vc: AddBookViewController, didUpdate book: Book, bookID: String)
}

protocol BookListCellUpdateDelegate: AnyObject {
  func didTapUpdateButton(bookID: String)
}

protocol BookListCellDeleteDelegate: AnyObject {
  func didTapDeleteButton(bookID: String)
}

protocol BookListRepository: AnyObject {
  func fetchBooks() -> AnyPublisher<[Book], Never>
  func saveBookData(book: Book) -> AnyPublisher<Void, Never>
  func updateBookData(book: Book) -> AnyPublisher<Void, Never>
  func deleteBookData(book: Book) -> AnyPublisher<Void, Never>
}

// MARK: - Repository

final class BookListRepositoryImpl: BookListRepository {
  
  private let coreDataManager = CoredataManager.shared
  
  func fetchBooks() -> AnyPublisher<[Book], Never> {
    
    return Future<[Book], Never> { [weak self] promise in
      guard let self else {
        promise(.success([]))
        return
      }
      
      let books = coreDataManager.getBookListFromCoreData().map { bookData in
        Book(
          id: bookData.id,
          bookTitle: bookData.bookTitle,
          totalPage: Int(bookData.totalPage),
          currentPage: Int(bookData.currentPage)
        )
      }
      promise(.success(books))
    }.eraseToAnyPublisher()
  }
  
  func saveBookData(book: Book) -> AnyPublisher<Void, Never> {
    return Future<Void, Never> { [weak self] promise in
      self?.coreDataManager.saveBookData(book: book) {
        promise(.success(()))
      }
    }.eraseToAnyPublisher()
  }
  
  func updateBookData(book: Book) -> AnyPublisher<Void, Never> {
    return Future<Void, Never> { [weak self] promise in
      self?.coreDataManager.updateBookData(updateData: book) {
        promise(.success(()))
      }
    }.eraseToAnyPublisher()
  }
  
  func deleteBookData(book: Book) -> AnyPublisher<Void, Never> {
    
    return Future<Void, Never> { [weak self] promise in
      self?.coreDataManager.deleteBookData(data: book) {
        promise(.success(()))
      }
    }.eraseToAnyPublisher()
  }
  
}


// MARK: - View Model

final class BookListViewModel {
  
  @Published var bookViewModels: [BookListCell.ViewModel] = []
  private let bookListRepository: BookListRepository
  private var books: [Book] = []
  var cancellables = Set<AnyCancellable>()
  
  init(bookListRepository: BookListRepository) {
    self.bookListRepository = bookListRepository
  }
  
  // 데이터 호출(코어데이터에서)
  func loadBooks() {
    bookListRepository.fetchBooks()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] fetchBooks in
        guard let self else { return }
        self.books = fetchBooks
        self.bookViewModels = convertToViewModels(self.books)
      }.store(in: &cancellables)
  }
  
  // ui가 사용할 수 있도록 변환해줌
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
  
  // 아이디로 책 찾기
  func findBook(by id: String) -> Book? {
    
    books.first(where: { book in
      return book.id == id
    })
    
  }
  
  // 책 추가
  func TappedAddButton(book: Book) {
    
    bookListRepository.saveBookData(book: book)
      .sink { [weak self] in
        guard let self else { return }
        
        books.append(book)
        self.bookViewModels = convertToViewModels(self.books)
      }.store(in: &cancellables)
  }

  // 책 수정
  func TappedUpdateButton(book: Book, bookID: String) {
    
    guard let targetIndex = books.firstIndex(where: { book in book.id == bookID }) else {
      return
    }
    
    bookListRepository.updateBookData(book: book)
      .sink { [weak self] in
        guard let self else { return }
      
        self.books[targetIndex] = book
        self.bookViewModels = convertToViewModels(books)
      }.store(in: &cancellables)
  }
  
  // 책 삭제
  func TappedDeleteButton(bookID: String) {
    
    guard let targetBookData = books.first(where: { book in book.id == bookID }) else {
      return
    }
    
    bookListRepository.deleteBookData(book: targetBookData)
      .sink { [weak self] in
        guard let self else { return }
        
        self.books.removeAll(where: { book in book.id == bookID })
        self.bookViewModels = convertToViewModels(books)
      }.store(in: &cancellables)
  }
}
