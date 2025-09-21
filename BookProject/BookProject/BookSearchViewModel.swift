import UIKit


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



final class Networking {
  
  static let shared = Networking()
  private init() {}
  
  // url 받아오기
  func fetchData<T: Codable>(searchText: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
    // 한글검색 변환
    guard let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      completion(.failure(.networkingError))
      return
    }
    let URL = "\(BookApi.bookURL)&query=\(encodedSearchText)&QueryType=Keyword&MaxResults=20&start=1&SearchTarget=Book&output=js&Version=20131101&Cover=md"
    
    performrequest(url: URL, type: T.self) { result in
      completion(result)
    }
  }
  
  
  private func performrequest<T: Codable>(url: String, type: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
    
    guard let url = URL(string: url) else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let session = URLSession.shared
    
    let task = session.dataTask(with: request) { data, response, error in
      
      if error != nil {
        completion(.failure(.networkingError))
        return
      }
      
      guard let safeData = data else {
        completion(.failure(.dataError))
        return
      }
      
      guard var string = String(data: safeData, encoding: .utf8) else {
        completion(.failure(.dataError))
        return
      }
            
      // JSON인지 JSONP인지 확인
      let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
      
      // JSON 형태인 경우 ({}로 시작)
      if !trimmedString.hasPrefix("{") {
        // JSONP 제거
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
        completion(.failure(.parseError))
        return
      }
      
      if let bookParsing = self.parseJSON(cleanData, type: T.self) {
        completion(.success(bookParsing))
      } else {
        completion(.failure(.parseError))
      }
    }
    
    task.resume()
  }
  
  
  // 데이터 제대로 받아지는지 확인
  private func parseJSON<T: Decodable>(_ data: Data, type: T.Type) -> T? {
    do {
      let decoded = try JSONDecoder().decode(type, from: data)
      return decoded
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
  
  
}







final class BookSearchViewModel {
  
  // 책 데이터
  var bookSearchList: [BookSearchResult] = []
  
  // 변환함수 추가
  func bookSearchResultToSearchModel(_ bookResults: [BookSearchResult]) -> [SearchModel] {
    let searchModels = bookResults.map { book in
      SearchModel(
        itemId: book.isbn13 ?? "",
        cover: book.cover ?? "",
        title: book.title ?? "제목 없음",
        description: book.description ?? "설명 없음",
        author: book.author ?? "저자 없음"
      )
    }
    return searchModels
  }
  
  

}

