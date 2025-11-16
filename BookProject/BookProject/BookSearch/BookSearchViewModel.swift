import UIKit
import Alamofire
import Combine

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

//protocol Cancellation {
//  func cancelTask()
//}
//
//extension DataRequest: Cancellation {
//  func cancelTask() {
//    if isFinished == false {
//      cancel()
//    }
//  }
//}

protocol BookSearchRepository: AnyObject {
  func fetchData(searchText: String) -> AnyPublisher<BookResponse, NetworkError>
}

final class BookSearchRepositoryImpl: BookSearchRepository {
  
  private let networking = Networking.shared
  
  func fetchData(searchText: String) -> AnyPublisher<BookResponse, NetworkError> {
    guard let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      return Fail(error: NetworkError.networkingError).eraseToAnyPublisher()
    }
    
    let urlString = "\(BookApi.bookURL)&query=\(encodedSearchText)&QueryType=Keyword&MaxResults=20&start=1&SearchTarget=Book&output=js&Version=20131101&Cover=md"
    
    return networking.fetchData(
      url: URL(string: urlString)!
    )
  }
}


final class Networking {
  
  static let shared = Networking()
  private init() {}
  
  func fetchData<T: Codable>(url: URL) -> AnyPublisher<T, NetworkError> {
    
    return Future<T, NetworkError> { promise in
      
      AF.request(url, method: .get)
        .responseData { response in
          
          if let error = response.error {
            print("Alamofire 요청 에러 \(error.localizedDescription)")
            return promise(.failure(.networkingError))
          }
          
          self.handleJSONPDecoding(response: response, promise: promise)
        }
    }.eraseToAnyPublisher()
  }
  
  private func handleJSONPDecoding<T: Codable>(response: AFDataResponse<Data>, promise: @escaping (Result<T, NetworkError>) -> Void) {
    
    guard let data = response.data else {
      return promise(.failure(.dataError))
    }
    
    guard var string = String(data: data, encoding: .utf8) else {
      return promise(.failure(.dataError))
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
      return promise(.failure(.parseError))
    }
    
    do {
      let decoded = try JSONDecoder().decode(T.self, from: cleanData)
      promise(.success(decoded))
    } catch {
      print("디코딩 에러: \(error.localizedDescription)")
      promise(.failure(.parseError))
    }
  }
}

protocol BookSearchViewModelDelegate: AnyObject {
  func reloadData(items:[BookSearchViewController.Item])
}

final class BookSearchViewModel {
  
  @Published var searchResults: [BookSearchViewController.Item] = []
  
  private var searchCancellable: AnyCancellable?
  
  private let bookSearchRepository: BookSearchRepository
  
  init(bookSearchRepository: BookSearchRepository = BookSearchRepositoryImpl()) {
    self.bookSearchRepository = bookSearchRepository
  }
  
  
  func searchBarSearchButtonTapped(query: String) {
    searchCancellable?.cancel()
    
    searchCancellable = bookSearchRepository.fetchData(searchText: query)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          print("검색 완료")
        case .failure(let error):
          print("검색 실패: \(error.localizedDescription)")
        }
      }, receiveValue: { [weak self] bookResponse in
        self?.searchResults = self?.convertToViewModels(bookResponse.item) ?? []
      })
  }
  
  
  private func convertToViewModels(_ bookResults: [BookSearchResult]) -> [BookSearchViewController.Item] {
    return bookResults.map { book in
      BookSearchViewController.Item(
        viewModel: BookSearchCell.ViewModel(
          itemId: book.isbn13 ?? "",
          cover: book.cover ?? "",
          title: book.title ?? "제목 없음",
          author: book.author ?? "저자 없음"
        )
      )
    }
  }
}
