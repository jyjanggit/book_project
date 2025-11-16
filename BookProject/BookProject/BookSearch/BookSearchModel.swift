import Foundation

struct BookSearchModel {
  var itemId: String
  var cover: String
  var title: String
  //var description: String
  var author: String
  
}

extension BookSearchModel {
  init(from result: BookSearchResult) {
    self.itemId = result.isbn13 ?? ""
    self.cover = result.cover ?? ""
    self.title = result.title ?? "제목 없음"
    self.author = result.author ?? "저자 없음"
  }
}
