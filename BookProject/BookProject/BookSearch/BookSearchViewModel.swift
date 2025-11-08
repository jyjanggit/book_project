import UIKit
import Alamofire

// 네트워크, 에러 담당
enum NetworkError: Error {
  case networkingError
  case dataError
  case parseError
}

struct BookResponse: Codable {
  let version: String?
  let logo: String?
  let title: String?
  let link: String?
  let pubDate: String?
  let totalResults, startIndex, itemsPerPage: Int?
  let query: String?
  let searchCategoryID: Int?
  let searchCategoryName: String?
  let item: [BookSearchResult]
  
  enum CodingKeys: String, CodingKey {
    case version, logo, title, link, pubDate, totalResults, startIndex, itemsPerPage, query
    case searchCategoryID = "searchCategoryId"
    case searchCategoryName, item
  }
}

struct BookSearchResult: Codable {
  let title: String?
  let author, description: String?
  let cover: String?
  let isbn13: String?
  
  enum CodingKeys: String, CodingKey {
    case title, author, description, isbn13
    case cover
  }
}

protocol BookSearchRepository: AnyObject {
  func fetchData<T: Codable>(searchText: String, completion: @escaping (Result<T, NetworkError>) -> Void)
}



final class Networking: BookSearchRepository {
  
  static let shared = Networking()
  private init() {}
  
  func fetchData<T: Codable>(searchText: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
    guard let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      completion(.failure(.networkingError))
      return
    }
    
    let url = "\(BookApi.bookURL)&query=\(encodedSearchText)&QueryType=Keyword&MaxResults=20&start=1&SearchTarget=Book&output=js&Version=20131101&Cover=md"
    
    performRequest(url: url, completion: completion)
  }
  
  
  private func performRequest<T: Codable>(url: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
    
    AF.request(url, method: .get)
      .responseData { response in
        
        if let error = response.error {
          print("Alamofire 요청 에러 \(error.localizedDescription)")
          return completion(.failure(.networkingError))
        }
        
        self.handleJSONPDecoding(response: response, completion: completion)
      }
  }
  
  private func handleJSONPDecoding<T: Codable>(response: AFDataResponse<Data>, completion: @escaping (Result<T, NetworkError>) -> Void) {
    
    guard let data = response.data else {
      return completion(.failure(.dataError))
    }
    
    guard var string = String(data: data, encoding: .utf8) else {
      return completion(.failure(.dataError))
    }
    
    let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmedString.hasPrefix("{") {
      if string.hasSuffix(");") {
        string = String(string.dropLast(2))
      }
      
      if let firstParenIndex = string.firstIndex(of: "(") {
        string = String(string[string.index(after: firstParenIndex)...])
      }
      
      if string.hasSuffix(")") {
        string = String(string.dropLast(1))
      }
    }
    
    guard let cleanData = string.data(using: .utf8) else {
      return completion(.failure(.parseError))
    }
    
    do {
      let decoded = try JSONDecoder().decode(T.self, from: cleanData)
      completion(.success(decoded))
    } catch {
      print("디코딩 에러: \(error.localizedDescription)")
      completion(.failure(.parseError))
    }
  }
}

protocol BookSearchViewModelDelegate: AnyObject {
  func reloadData(items:[BookSearchViewController.Item])
}

final class BookSearchViewModel {
  
  weak var delegate: BookSearchViewModelDelegate?
  
  var bookSearchList: [BookSearchModel] = []
  
  private let bookSearchRepository: BookSearchRepository
  
  init(bookSearchRepository: BookSearchRepository = Networking.shared) {
    self.bookSearchRepository = bookSearchRepository
  }
  
  
  func searchBarSearchButtonTapped(query: String) {
    bookSearchRepository.fetchData(searchText: query) { [weak self] (result: Result<BookResponse, NetworkError>) in
      guard let self else { return }
      
      switch result {
      case .success(let bookResponse):
        self.bookSearchList = bookResponse.item.map{ book in
            .init(itemId: book.isbn13 ?? "",
                  cover: book.cover ?? "",
                  title: book.title ?? "",
                  //description: book.description ?? "",
                  author: book.author ?? "")
        }
        
        self.delegate?.reloadData(items: self.bookSearchResultToSearchModel(bookResponse.item))
        
      case .failure(let error):
        print("검색 실패: \(error.localizedDescription)")
      }
    }
  }
  
  private func bookSearchResultToSearchModel(_ bookResults: [BookSearchResult]) -> [BookSearchViewController.Item] {
    return bookResults.map { book in
      BookSearchViewController.Item(
        viewModel: BookSearchCell.ViewModel(
          itemId: book.isbn13 ?? "",
          cover: book.cover ?? "",
          title: book.title ?? "제목 없음",
          //description: book.description ?? "설명 없음",
          author: book.author ?? "저자 없음"
        )
      )
    }
  }
}
