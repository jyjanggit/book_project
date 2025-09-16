import Foundation


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
  
  enum CodingKeys: String, CodingKey {
    case title, author, description
    case cover
  }
}



final class Networking {
  
  static let shared = Networking()
  private init() {}
  
  // url 받아오기
  func fetchData<T: Codable>(searchText: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
    let URL = "\(BookApi.bookURL)&query=\(searchText)&querytype=keyword&output=js"
    performrequest(url: searchText, type: T.self) { result in
      completion(result)
    }
  }
  
  private func performrequest<T: Codable>(url: String, type: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
    
    guard let url = URL(string: url) else { return }
    
    //url 요청 생성
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    // 작업 세션 (싱글톤패턴)
    let session = URLSession.shared
    
    let task = session.dataTask(with: request) { data, response, error in
      
      if error != nil {
        completion(.failure(.networkingError))
        return
      }
      
      // 데이터 유무 확인
      guard let safeData = data else {
        completion(.failure(.dataError))
        return
      }
      
      var string = String(data: safeData, encoding: .utf8)!
      if url.absoluteString == BookApi.bookURL {
        string.removeLast()
      }
      
      if let bookParsing = self.parseJSON(safeData, type: T.self) {
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



