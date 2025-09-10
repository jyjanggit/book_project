import Foundation


struct Welcome: Codable {
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
  
  //func fetchData()
  
  func getMethod(completion: @escaping ([BookSearchResult]?) -> Void) {
    
    // url 구조체 생성
    guard let url = URL(string: BookApi.requestUrl) else {
      completion(nil)
      return
    }
    
    //url 요청 생성
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    // 작업 세션 (싱글톤패턴)
    let session = URLSession.shared
    
    let task = session.dataTask(with: request) { data, response, error in
      // 에러가 없는지 확인
      guard error == nil else {
        completion(nil)
        return
      }
      
      // 데이터 유무 확인
      guard let safeData = data else {
        completion(nil)
        return
      }
      
      do{
        let decoder = JSONDecoder()
        let bookArray = try decoder.decode(Welcome.self, from: safeData)
        //completion(BookSearchResult)
      } catch {
        print("Decoding error:", error)
      }
      
    }
    
    task.resume()
    
  }

}



