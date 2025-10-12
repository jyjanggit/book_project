import Testing
@testable import BookProject


final class 가짜_BookSearchRepository: BookSearchRepository {
  
  var fetchDataCallCount = 0
  var resultToReturn: Result<BookResponse, NetworkError>?
  
  func fetchData<T: Codable>(searchText: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
    fetchDataCallCount += 1
    
    if let result = self.resultToReturn {
      completion(result as! Result<T, NetworkError>)
    } else {
      let failureResult: Result<T, NetworkError> = .failure(NetworkError.networkingError)
      completion(failureResult)
    }
  }
}


final class 가짜_BookSearchViewModelDelegate: BookSearchViewModelDelegate {
  
  var reloadDataCallCount = 0
  var receivedItems: [BookSearchViewController.Item] = []
  
  func reloadData(items: [BookSearchViewController.Item]) {
    reloadDataCallCount += 1
    receivedItems = items
  }
}



struct BookSearchViewModelTests {
  
  @Test("검색 성공 시, Repository 호출, 데이터 변환, 화면 노출 성공")
  func when_searchButton_tapped_then_fetchData_and_display() {
    let delegate = 가짜_BookSearchViewModelDelegate()
    let bookSearchRepository = 가짜_BookSearchRepository()
    let viewModel = BookSearchViewModel(
      bookSearchRepository: bookSearchRepository
    )
    
    let dummyItem = BookSearchResult(title: "title", author: "author", description: "description", cover: "cover.jpg", isbn13: "isbn13")
    let mockResponse = BookResponse(version: nil, logo: nil, title: nil, link: nil, pubDate: nil, totalResults: 1, startIndex: 1, itemsPerPage: 1, query: nil, searchCategoryID: nil, searchCategoryName: nil, item: [dummyItem])
    
    
    viewModel.delegate = delegate
    
    // when
    viewModel.searchBarSearchButtonTapped(query: "TestQuery")
    
    // then
    #expect(bookSearchRepository.fetchDataCallCount == 1)
    #expect(delegate.reloadDataCallCount == 1)
    #expect(viewModel.bookSearchList.first?.title == "title")
  }
  
  @Test("검색 실패 시, Repository 호출만.")
  func when_searchFails_then_noDelegateCall() {
    let delegate = 가짜_BookSearchViewModelDelegate()
    let bookSearchRepository = 가짜_BookSearchRepository()
    let viewModel = BookSearchViewModel(
      bookSearchRepository: bookSearchRepository
    )
    
    bookSearchRepository.resultToReturn = .failure(.networkingError)
    
    viewModel.delegate = delegate
    
    // when
    viewModel.searchBarSearchButtonTapped(query: "FailQuery")
    
    // then
    #expect(bookSearchRepository.fetchDataCallCount == 1)
    #expect(delegate.reloadDataCallCount == 0)
    #expect(viewModel.bookSearchList.isEmpty)
  }
}
