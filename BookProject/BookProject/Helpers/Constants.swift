//
//  Constants.swift
//  BookProject
//
//  Created by JY Jang on 9/6/25.
//

import UIKit



public struct bookListCell {
  static let bookListIdentifier = "BookListCell"
  private init() {}
}

public enum BookApi {
  static let requestUrl = "http://www.aladin.co.kr/ttb/api/ItemSearch.aspx?ttbkey=ttbjjy9102241351001&query=해리포터&querytype=keyword&output=js"
}

public struct bookSearchCell {
  static let bookSearchIdentifier = "SearchListCell"
  private init() {}
}

