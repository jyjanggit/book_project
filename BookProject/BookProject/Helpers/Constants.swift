//
//  Constants.swift
//  BookProject
//
//  Created by JY Jang on 9/6/25.
//

import UIKit



public struct BookListCellConstants {
  static let bookListIdentifier = "BookListCell"
  private init() {}
}

public enum BookApi {
  static let bookURL = "http://www.aladin.co.kr/ttb/api/ItemSearch.aspx?ttbkey=ttbjjy9102241351001"

}

public struct BookSearchCellConstants {
  static let bookSearchIdentifier = "SearchListCell"
  private init() {}
}

public struct BookPictureCellConstants {
  static let bookPictureIdentifier = "PictureListCell"
  private init() {}
}
