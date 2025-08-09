import UIKit

extension UILabel {
  
//  struct TextStyle {
//    let commonFont = UIFont.systemFont(ofSize: 24)
//    let boldFont = UIFont.boldSystemFont(ofSize: 24)
//  }
  
  func applyCommonStyle() {
    self.font = UIFont.systemFont(ofSize: 24)
    self.textColor = UIColor(hex: "#333333")
    self.textAlignment = .center
    self.numberOfLines = 0
  }
  
  func applyBoldCommonStyle() {
    self.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    self.textColor = UIColor(hex: "#333333")
    self.textAlignment = .center
    self.numberOfLines = 0
  }
  
}

extension UIButton {
  func applyButton() {
    self.setTitleColor(UIColor(hex: "#ffffff"), for: .normal)
    self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
    self.layer.cornerRadius = 8
    self.clipsToBounds = true
  }
}


extension UITextField {
  func applyUITextField() {
    self.borderStyle = .roundedRect
    self.font = UIFont.systemFont(ofSize: 20)
    self.textColor = UIColor(hex: "#181818")
  }
}
