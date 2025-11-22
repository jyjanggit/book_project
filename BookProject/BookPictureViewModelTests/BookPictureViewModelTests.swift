import Testing
import UIKit
import Foundation
@testable import BookProject

final class 가짜_BookPictureRepository: BookPictureRepository {
  var fakePictures: [BookProject.BookPictureModel] = []

  var fetchPicturesCallCount = 0
  func fetchPictures() -> [BookProject.BookPictureModel] {
    fetchPicturesCallCount += 1
    return fakePictures
  }
  
  var savePictureDataCallCount = 0
  func saveBookPictureData(picture: BookProject.BookPictureModel, completion: @escaping () -> Void) {
    savePictureDataCallCount += 1
    completion()
  }
  
  var deletePictureDataCallCount = 0
  func deleteBookPictureData(data: BookProject.BookPictureModel, completion: @escaping () -> Void) {
    deletePictureDataCallCount += 1
    completion()
  }
  
  var updatePictureDataCallCount = 0
  func updateBookPictureData(updateData: BookProject.BookPictureModel, completion: @escaping () -> Void) {
    updatePictureDataCallCount += 1
    completion()
  }
}

final class 가짜_BookPictureViewModelDelegate: BookPictureViewModelDelegate {
  var reloadDataCallCount = 0
  func reloadData(pictures books: [BookPictureCell.ViewModel]) {
    reloadDataCallCount += 1
  }
}



struct BookPictureViewModelTests {
  
  @Test("뷰가 로드되면 데이터 불러오고 화면에 노출")
  func when_viewDidLoad_then_loadData_and_displayData() {
    //given
    let delegate = 가짜_BookPictureViewModelDelegate()
    let bookPictureRepository = 가짜_BookPictureRepository()
    let viewModel = BookPictureViewModel(
      bookPictureRepository: bookPictureRepository
    )
    
    viewModel.delegate = delegate
    
    // when
    viewModel.loadPictures()
    // then
    #expect(bookPictureRepository.fetchPicturesCallCount == 1)
    #expect(delegate.reloadDataCallCount == 1)
    
  }
  
  @Test("추가 버튼이 클릭되면 책을 저장하고 화면에 노출")
  func when_addButton_append_then_saveBook_and_displayData() {
    let delegate = 가짜_BookPictureViewModelDelegate()
    let bookPictureRepository = 가짜_BookPictureRepository()
    let viewModel = BookPictureViewModel(
      bookPictureRepository: bookPictureRepository
    )
    
    viewModel.delegate = delegate
    
    // when
    viewModel.TappedAddButton(addPicture: BookPictureModel(id: "id", booktTextpicture: UIImage(), memo: "memo", date: Date()))
    
    // then
    #expect(bookPictureRepository.savePictureDataCallCount == 1)
    #expect(delegate.reloadDataCallCount == 1)

  }
  
  @Test("수정 버튼이 클릭되면 책을 저장하고 화면에 노출")
  func when_updateButton_append_then_updateBook_and_displayData() {
    let delegate = 가짜_BookPictureViewModelDelegate()
    let bookPictureRepository = 가짜_BookPictureRepository()
    let viewModel = BookPictureViewModel(
      bookPictureRepository: bookPictureRepository
    )
    
    let id = "testupdateId"
    let firstBook = BookPictureModel(id: id, booktTextpicture: UIImage(), memo: "수정전", date: Date())
    let secondBook = BookPictureModel(id: id, booktTextpicture: UIImage(), memo: "수정후", date: Date())
    
    viewModel.delegate = delegate
    
    bookPictureRepository.fakePictures = [firstBook]
    viewModel.loadPictures()
    
    // when
    viewModel.TappedUpdateButton(updatedPicture: secondBook, pictureID: id)
    
    // then
    #expect(bookPictureRepository.updatePictureDataCallCount == 1)
    #expect(delegate.reloadDataCallCount == 2)

  }
  
  @Test("삭제 버튼이 클릭되면 책을 저장하고 화면에 노출")
  func when_deleteButton_append_then_deleteBook_and_displayData() {
    let delegate = 가짜_BookPictureViewModelDelegate()
    let bookPictureRepository = 가짜_BookPictureRepository()
    let viewModel = BookPictureViewModel(
      bookPictureRepository: bookPictureRepository
    )
    
    let id = "testdeleteId"
    let deleteBook = BookPictureModel(id: id, booktTextpicture: UIImage(), memo: "삭제", date: Date())
    
    viewModel.delegate = delegate
    bookPictureRepository.fakePictures = [deleteBook]
    viewModel.loadPictures()
    
    // when
    viewModel.TappedDeleteButton(pictureID: id)
    
    // then
    #expect(bookPictureRepository.deletePictureDataCallCount == 1)
    #expect(delegate.reloadDataCallCount == 2)

  }
  
  
}


