import UIKit
import Combine

// MARK: - Delegate

protocol AddBookPictureViewControllerDelegate: AnyObject {
  func didTapAddButton(_ vc: AddBookPictureViewController, didAdd picture: BookPictureModel)
}

protocol UpdateBookPictureDelegate: AnyObject {
  func didTapUpdateButton(_ vc: AddBookPictureViewController, didUpdate picture: BookPictureModel, pictureID: String)
}

// MARK: - Repository

protocol BookPictureRepository: AnyObject {
  func fetchPictures() -> AnyPublisher<[BookPictureModel], Never>
  func saveBookPictureData(picture: BookPictureModel) -> AnyPublisher<Void, Never>
  func updateBookPictureData(picture: BookPictureModel) -> AnyPublisher<Void, Never>
  func deleteBookPictureData(picture: BookPictureModel) -> AnyPublisher<Void, Never>
}

final class BookPictureRepositoryImpl: BookPictureRepository {
  
  private let coreDataManager = CoredataPictureManager.shared
  
  func fetchPictures() -> AnyPublisher<[BookPictureModel], Never> {
    
    return Future<[BookPictureModel], Never> { [weak self] promise in
      guard let self else {
        promise(.success([]))
        return
      }
      let pictures = self.coreDataManager.getBookPictureListFromCoreData()
      promise(.success(pictures))
    }.eraseToAnyPublisher()
  }
  
  func saveBookPictureData(picture: BookPictureModel) -> AnyPublisher<Void, Never> {
    return Future<Void, Never> { [weak self] promise in
      self?.coreDataManager.saveBookPictureData(picture: picture) {
        promise(.success(()))
      }
    }.eraseToAnyPublisher()
  }
  
  func updateBookPictureData(picture: BookPictureModel) -> AnyPublisher<Void, Never> {
    return Future<Void, Never> { [weak self] promise in
      self?.coreDataManager.updateBookPictureData(updateData: picture) {
        promise(.success(()))
      }
    }.eraseToAnyPublisher()
  }
  
  func deleteBookPictureData(picture: BookPictureModel) -> AnyPublisher<Void, Never> {
    return Future<Void, Never> { [weak self] promise in
      self?.coreDataManager.deleteBookPictureData(data: picture) {
        promise(.success(()))
      }
    }.eraseToAnyPublisher()
  }
}

// MARK: - View Model

final class BookPictureViewModel {
  
  @Published var pictureViewModels: [BookPictureCell.ViewModel] = []
  private let bookPictureRepository: BookPictureRepository
  private var pictures: [BookPictureModel] = []
  var cancellables = Set<AnyCancellable>()
  
  init(bookPictureRepository: BookPictureRepository) {
    self.bookPictureRepository = bookPictureRepository
  }
  
  func loadPictures() {
    bookPictureRepository.fetchPictures()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] fetchPictures in
        guard let self else { return }
        self.pictures = fetchPictures
        self.pictureViewModels = self.convertToViewModels(self.pictures)
      }.store(in: &cancellables)
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
  
  func findPicture(by id: String) -> BookPictureModel? {
    
    pictures.first(where: { book in
      return book.id ==  id
    })
    
  }
  
  func TappedAddButton(addPicture: BookPictureModel) {
    
    bookPictureRepository.saveBookPictureData(picture: addPicture)
      .sink{ [weak self] in
        guard let self else { return }
        
        self.pictures.append(addPicture)
        self.pictureViewModels = convertToViewModels(self.pictures)
      }.store(in: &cancellables)
  }
  
  func TappedUpdateButton(updatedPicture: BookPictureModel, pictureID: String) {
    
    guard let targetIndex = pictures.firstIndex(where: { book in book.id == pictureID }) else {
      return
    }
    
    bookPictureRepository.updateBookPictureData(picture: updatedPicture)
      .sink{ [weak self] in
        guard let self else { return }
        
        self.pictures[targetIndex] = updatedPicture
        self.pictureViewModels = convertToViewModels(self.pictures)
    }
    
  }
  
  func TappedDeleteButton(pictureID: String) {
    
    guard let targetPictureData = pictures.first(where: { book in book.id == pictureID }) else {
      return
    }
    
    bookPictureRepository.deleteBookPictureData(picture: targetPictureData)
      .sink { [weak self] in
        guard let self else { return }
      
        self.pictures.removeAll(where: { book in book.id == pictureID })
        self.pictureViewModels = convertToViewModels(self.pictures)
      }.store(in: &cancellables)
    
  }
  
}
