//
//  Model.swift
//  BookProject
//
//  Created by JY Jang on 8/5/25.
//

import Foundation

struct Book {
  var id: String
  var bookTitle: String
  var totalPage: Int
  var currentPage: Int
  
  var percentage: CGFloat {
    totalPage > 0 ? (CGFloat(currentPage) / CGFloat(totalPage) * 100) : 0
  }
}
