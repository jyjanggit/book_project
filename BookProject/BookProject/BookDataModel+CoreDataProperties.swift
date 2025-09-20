//
//  BookDataModel+CoreDataProperties.swift
//  BookProject
//
//  Created by JY Jang on 9/20/25.
//
//

import Foundation
import CoreData


extension BookDataModel {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<BookDataModel> {
    return NSFetchRequest<BookDataModel>(entityName: "BookDataModel")
  }
  
  @NSManaged public var id: String
  @NSManaged public var bookTitle: String
  @NSManaged public var totalPage: Int16
  @NSManaged public var currentPage: Int16
  @NSManaged public var percentage: Double
  @NSManaged public var createdAt: Date

  
}

extension BookDataModel : Identifiable {
  
}
