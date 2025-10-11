//
//  CoredataManager.swift
//  BookProject
//
//  Created by JY Jang on 9/20/25.
//

import UIKit
import CoreData

final class CoredataPictureManager {
  
  static let shared = CoredataPictureManager()
  private init() {}
  // 싱글톤 객체
  
  // 앱델리게이트
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  
  // 임시 저장
  lazy var context = appDelegate?.persistentContainer.viewContext
  
  // 엔티티 이름
  let modelName: String = "BookPictureDataModel"
  
  // 코어데이터 저장 데이터 읽어오기
  func getBookPictureListFromCoreData() -> [BookPictureModel] {
    var bookPictureList: [BookPictureModel] = []
    
    // 임시저장된 공간에 있는지 확인
    if let context = context {
      // 있다면 요청
      let request = NSFetchRequest<NSManagedObject>(entityName: self.modelName)
      // 정렬순서를 정해서 요청하기 (날짜순)
      let dataOrder = NSSortDescriptor(key: "date", ascending: false)
      request.sortDescriptors = [dataOrder]
      
      do {
        // 임시 저장에서 요청을 통해 데이터 가져오기(fetch메서드)
        if let fetchedBookPictureList = try context.fetch(request) as? [BookPictureDataModel] {
          bookPictureList = fetchedBookPictureList.compactMap { entity in
            let image = UIImage(data: entity.booktTextpicture) ?? UIImage()
            
            return BookPictureModel(
              id: entity.id,
              memo: entity.memo,
              booktTextpicture: image,
              date: entity.date
            )
          }
        }
      } catch {
        print("실패")
      }
    }
    
    return bookPictureList
  }
  
  // 코어데이터에 생성하기
  func saveBookPictureData(picture: BookPictureModel, completion: @escaping () -> Void ) {
    
    if let context = context {
      // 임시로 저장된 데이터 형태를 파악?
      if let entity = NSEntityDescription.entity(forEntityName: self.modelName, in: context) {
        
        // 임시저장할 객체 만들기(NSManagedObject -> BookPictureDataModel)
        if let bookPictureData = NSManagedObject(entity: entity, insertInto: context) as? BookPictureDataModel {
          
          // 실제 데이터 할당
          bookPictureData.id = picture.id
          bookPictureData.memo = picture.memo
          bookPictureData.booktTextpicture = picture.booktTextpicture.jpegData(compressionQuality: 0.8) ?? Data()
          bookPictureData.date = picture.date
          
          appDelegate?.saveContext()
        }
      }
    }
    completion()
  }
  
  // 데이터 삭제하기
  func deleteBookPictureData(data: BookPictureModel, completion: @escaping () -> Void) {
    if let context = context {
      let request = NSFetchRequest<NSManagedObject>(entityName: self.modelName)
      request.predicate = NSPredicate(format: "id == %@", data.id)
      
      do {
        if let fetchedBookPictureList = try context.fetch(request) as? [BookPictureDataModel] {
          if let targetBookPicture = fetchedBookPictureList.first {
            context.delete(targetBookPicture)
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
  func updateBookPictureData(updateData: BookPictureModel, completion: @escaping () -> Void) {
    if let context = context {
      let request = NSFetchRequest<NSManagedObject>(entityName: self.modelName)
      request.predicate = NSPredicate(format: "id == %@", updateData.id)
      
      do {
        if let fetchedBookPictureList = try context.fetch(request) as? [BookPictureDataModel] {
          if let targetBookPicture = fetchedBookPictureList.first {
            targetBookPicture.memo = updateData.memo
            targetBookPicture.booktTextpicture = updateData.booktTextpicture.jpegData(compressionQuality: 0.8) ?? Data()
            targetBookPicture.date = updateData.date
            
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
