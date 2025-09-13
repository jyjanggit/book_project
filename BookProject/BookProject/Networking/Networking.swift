import Foundation


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



class Networking {
  
  static let shared = Networking()
  private init() {}
    
  //func fetchData(url: URL, type: Codable.Type, completion: @escaping ([BookSearchResult]?) -> Void) { 변경전
  func fetchData<T: Codable>(url: URL, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
    
    //url 요청 생성
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    // 작업 세션 (싱글톤패턴)
    let session = URLSession.shared
    
    let task = session.dataTask(with: request) { data, response, error in
      // 에러가 없는지 확인
      guard error == nil else {
        return
      }
      
      // 데이터 유무 확인
      guard let safeData = data else {
        return
      }
      
      var string = String(data: safeData, encoding: .utf8)!
      if url.absoluteString == BookApi.requestUrl {
        string.removeLast()
      }
      
      do{
        let decoder = JSONDecoder()
        let response = try decoder.decode(type.self, from: safeData)
        completion(.success(response))
      } catch {
        completion(.failure(error))
      }
      
    }
    
    task.resume()
    
  }

}



