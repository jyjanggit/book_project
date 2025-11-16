import Testing
@testable import BookProject

final class 가짜_BookListRepository: BookListRepository {
  
  var fakeBooks: [BookProject.Book] = []
  
  var fetchBooksCallCount = 0
  func fetchBooks() -> [BookProject.Book] {
    fetchBooksCallCount += 1
    return fakeBooks
  }
  
  var saveBookDataCallCount = 0
  func saveBookData(book: BookProject.Book, completion: @escaping () -> Void) {
    saveBookDataCallCount += 1
    completion()
  }
  
  var deleteBookDataCallCount = 0
  func deleteBookData(data: BookProject.Book, completion: @escaping () -> Void) {
    deleteBookDataCallCount += 1
    completion()
  }
  
  var updateBookDataCallCount = 0
  func updateBookData(updateData: BookProject.Book, completion: @escaping () -> Void) {
    updateBookDataCallCount += 1
    completion()
  }
}

final class 가짜_viewModelDelegate: BookListViewModelDelegate {
  var reloadDataCallCount = 0
  func reloadData(books: [BookListCell.ViewModel]) {
    reloadDataCallCount += 1
  }
}



struct BookListViewModelTests {
  
  @Test("뷰가 로드되면 데이터 불러오고 화면에 노출")
  func when_viewDidLoad_then_loadData_and_displayData() {
    //given
    let delegate = 가짜_viewModelDelegate()
    let bookListRepository = 가짜_BookListRepository()
    let viewModel = BookListViewModel(
      bookListRepository: bookListRepository
    )
    
    viewModel.delegate = delegate
    
    // when
    viewModel.loadBooks()
    // then
    #expect(bookListRepository.fetchBooksCallCount == 1)
    #expect(delegate.reloadDataCallCount == 1)
    
  }
  
  @Test("책 추가 버튼이 클릭되면 책을 저장하고 화면에 노출")
  func when_addButton_append_then_saveBook_and_displayData() {
    let delegate = 가짜_viewModelDelegate()
    let bookListRepository = 가짜_BookListRepository()
    let viewModel = BookListViewModel(
      bookListRepository: bookListRepository
    )
    
    viewModel.delegate = delegate
    
    // when
    viewModel.addBookTappedButton(addBook: Book(id: "id", bookTitle: "bookTitle", totalPage: 10, currentPage: 1))
    
    // then
    #expect(bookListRepository.saveBookDataCallCount == 1)
    #expect(delegate.reloadDataCallCount == 1)

  }
  
  @Test("책 수정 버튼이 클릭되면 책을 저장하고 화면에 노출")
  func when_updateButton_append_then_updateBook_and_displayData() {
    let delegate = 가짜_viewModelDelegate()
    let bookListRepository = 가짜_BookListRepository()
    let viewModel = BookListViewModel(
      bookListRepository: bookListRepository
    )
    
    let id = "testupdateId"
    let firstBook = Book(id: id, bookTitle: "수정전", totalPage: 100, currentPage: 10)
    let secondBook = Book(id: id, bookTitle: "수정후", totalPage: 100, currentPage: 20)
    
    viewModel.delegate = delegate
    
    bookListRepository.fakeBooks = [firstBook]
    viewModel.loadBooks()
    
    // when
    viewModel.handleTapUpdateButton(updatedBook: secondBook, bookID: id)
    
    // then
    #expect(bookListRepository.updateBookDataCallCount == 1)
    #expect(delegate.reloadDataCallCount == 2)

  }
  
  @Test("책 삭제 버튼이 클릭되면 책을 저장하고 화면에 노출")
  func when_deleteButton_append_then_deleteBook_and_displayData() {
    let delegate = 가짜_viewModelDelegate()
    let bookListRepository = 가짜_BookListRepository()
    let viewModel = BookListViewModel(
      bookListRepository: bookListRepository
    )
    
    let id = "testdeleteId"
    let deleteBook = Book(id: id, bookTitle: "삭제될 책", totalPage: 100, currentPage: 10)
    
    viewModel.delegate = delegate
    bookListRepository.fakeBooks = [deleteBook]
    viewModel.loadBooks()
    
    // when
    viewModel.handleTapDeleteButton(bookID: id)
    
    // then
    #expect(bookListRepository.deleteBookDataCallCount == 1)
    #expect(delegate.reloadDataCallCount == 2)

  }
  
  
}
