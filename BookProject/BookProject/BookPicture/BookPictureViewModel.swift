import UIKit
import Combine

protocol AddBookPictureViewControllerDelegate: AnyObject {
  func addBookPictureTappedButton(_ vc: AddBookPictureViewController, didAdd picture: BookPictureModel)
}

protocol UpdateBookPictureDelegate: AnyObject {
  func updateBookPictureTappedButton(_ vc: AddBookPictureViewController, didUpdate picture: BookPictureModel, pictureID: String)
}


protocol BookPictureRepository: AnyObject {
  func fetchPictures() -> [BookPictureModel]
  func saveBookPictureData(picture: BookPictureModel, completion: @escaping () -> Void)
  func deleteBookPictureData(data: BookPictureModel, completion: @escaping () -> Void)
  func updateBookPictureData(updateData: BookPictureModel, completion: @escaping () -> Void)
}

final class BookPictureRepositoryImpl: BookPictureRepository {
  
  private let coreDataManager = CoredataPictureManager.shared
  
  func fetchPictures() -> [BookPictureModel] {
    coreDataManager.getBookPictureListFromCoreData()
  }
  
  func saveBookPictureData(picture: BookPictureModel, completion: @escaping () -> Void) {
    coreDataManager.saveBookPictureData(picture: picture, completion: completion)
  }
  
  func updateBookPictureData(updateData: BookPictureModel, completion: @escaping () -> Void) {
    coreDataManager.updateBookPictureData(updateData: updateData, completion: completion)
  }
  
  func deleteBookPictureData(data: BookPictureModel, completion: @escaping () -> Void) {
    coreDataManager.deleteBookPictureData(data: data, completion: completion)
  }
}

final class BookPictureViewModel {
  
  @Published var pictureViewModels: [BookPictureCell.ViewModel] = []
  private let bookPictureRepository: BookPictureRepository
  private var pictures: [BookPictureModel] = []
  
  init(bookPictureRepository: BookPictureRepository) {
    self.bookPictureRepository = bookPictureRepository
  }
  
  func loadPictures() {
    self.pictures = bookPictureRepository.fetchPictures()
    let viewModels = convertToViewModels(pictures)
    self.pictureViewModels = viewModels
  }
  
  private func convertToViewModels(_ pictures: [BookPictureModel]) -> [BookPictureCell.ViewModel] {
    return pictures.map { picture in
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      
      return BookPictureCell.ViewModel(
        id: picture.id,
        image: picture.booktTextpicture,
        memo: picture.memo,
        date: formatter.string(from: picture.date)
      )
    }
  }
  
  func addBookPictureTappedButton(addPicture: BookPictureModel) {
    bookPictureRepository.saveBookPictureData(picture: addPicture) { [weak self] in
      guard let self else { return }
      
      pictures.append(addPicture)
      self.pictureViewModels = convertToViewModels(pictures)
    }
  }
  
  func findPicture(by id: String) -> BookPictureModel? {
    pictures.first(where: { book in
      return book.id ==  id
    })
  }
  
  func handleTapUpdateButton(updatedPicture: BookPictureModel, pictureID: String) {
    guard let targetIndex = pictures.firstIndex(where: { book in book.id == pictureID }) else {
      return
    }
    
    bookPictureRepository.updateBookPictureData(updateData: updatedPicture) { [weak self] in
      guard let self else { return }
      
      self.pictures[targetIndex] = updatedPicture
      self.pictureViewModels = self.convertToViewModels(self.pictures)
    }
  }
  
  func handleTapDeleteButton(pictureID: String) {
    guard let targetPictureData = pictures.first(where: { book in book.id == pictureID }) else {
      return
    }
    
    bookPictureRepository.deleteBookPictureData(data: targetPictureData) { [weak self] in
      guard let self else { return }
      
      pictures.removeAll(where: { book in book.id == pictureID })
      self.pictureViewModels = convertToViewModels(pictures)
    }
  }
}
