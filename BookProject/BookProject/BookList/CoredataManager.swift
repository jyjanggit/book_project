//
//  CoredataManager.swift
//  BookProject
//
//  Created by JY Jang on 9/20/25.
//

import UIKit
import CoreData

final class CoredataManager {
  
  static let shared = CoredataManager()
  private init() {}
  // 싱글톤 객체
  
  // 앱델리게이트
  private let appDelegate = UIApplication.shared.delegate as? AppDelegate
  
  // 임시 저장
  private lazy var context = appDelegate?.persistentContainer.viewContext
  
  // 엔티티 이름
  private let modelName: String = "BookDataModel"
  
  // 코어데이터 저장 데이터 읽어오기
  func getBookListFromCoreData() -> [BookDataModel] {
    var bookList: [BookDataModel] = []
    
    // 임시저장된 공간에 있는지 확인
    if let context = context {
      // 있다면 요청
      let request = NSFetchRequest<NSManagedObject>(entityName: self.modelName)
      // 정렬순서를 정해서 요청하기 (날짜순)
      let dataOrder = NSSortDescriptor(key: "createdAt", ascending: true)
      request.sortDescriptors = [dataOrder]
      
      do {
        // 임시 저장에서 요청을 통해 데이터 가져오기(fetch메서드)
        if let fetchedBookList = try context.fetch(request) as? [BookDataModel] {
          bookList = fetchedBookList
        }
      } catch {
        print("실패")
      }
    }
    
    return bookList
    
  }
  
  // 코어데이터에 생성하기
  func saveBookData(book: Book, completion: @escaping () -> Void ) {
    
    if let context = context {
      // 임시로 저장된 데이터 형태를 파악?
      if let entity = NSEntityDescription.entity(forEntityName: self.modelName, in: context) {
        
        // 임시저장할 객체 만들기(NSManagedObject -> BookDataModel)
        if let bookData = NSManagedObject(entity: entity, insertInto: context) as? BookDataModel {
          
          // 실제 데이터 할당
          bookData.id = book.id
          bookData.bookTitle = book.bookTitle
          bookData.totalPage = Int16(book.totalPage)
          bookData.currentPage = Int16(book.currentPage)
          bookData.percentage = book.percentage
          bookData.createdAt = Date()
          
          appDelegate?.saveContext()
        }
      }
    }
    completion()
  }
  
  // 데이터 삭제하기
  func deleteBookData(data: Book, completion: @escaping () -> Void) {
    if let context = context {
      let request = NSFetchRequest<NSManagedObject>(entityName: self.modelName)
      request.predicate = NSPredicate(format: "id == %@", data.id)
      
      do {
        if let fetchedBookList = try context.fetch(request) as? [BookDataModel] {
          if let targetBook = fetchedBookList.first {
            context.delete(targetBook)
            appDelegate?.saveContext()
          }
        }
        completion()
      } catch {
        print("삭제실패")
        completion()
      }
    }
  }
  
  // 데이터 수정하기
  func updateBookData(updateData: Book, completion: @escaping () -> Void) {
    if let context = context {
      let request = NSFetchRequest<NSManagedObject>(entityName: self.modelName)
      request.predicate = NSPredicate(format: "id == %@", updateData.id)
      
      do {
        if let fetchedBookList = try context.fetch(request) as? [BookDataModel] {
          if let targetBook = fetchedBookList.first {
            targetBook.bookTitle = updateData.bookTitle
            targetBook.totalPage = Int16(updateData.totalPage)
            targetBook.currentPage = Int16(updateData.currentPage)
            targetBook.percentage = updateData.percentage
            
            appDelegate?.saveContext()
          }
        }
        completion()
      } catch {
        print("수정실패")
        completion()
      }
    }
  }
  
}
