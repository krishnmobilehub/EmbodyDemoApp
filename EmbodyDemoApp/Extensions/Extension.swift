//
//  Extension.swift
//  EmbodyDemoApp
//

import Foundation
import UIKit

enum Storyboard: String {
    case Main
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}

enum ButtonTag: Int {
    case left = 0
    case right = 1
}

typealias AlertBlock = (_ tag: ButtonTag) -> Void


extension UIStoryboard {
    func instantiateViewController<T : UIViewController>(withClass viewController: T.Type,
                                                         storyBoardName: Storyboard? = Storyboard.Main) -> T {
        let storyboardID = viewController.storyboardID
        return storyBoardName?.instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }
}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(withClassName className: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: String(describing: className), for: indexPath) as! T
    }
}

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(withClassName className: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: String(describing: className), for: indexPath) as! T
    }
}

extension UIButton {
    func buttonCornerRadious(radius: CGFloat = 5.0, borderColor: UIColor = .clear, isShadow: Bool = false, shadowColor: UIColor = .black, shadowOpacity: Float = 1.0) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
        if isShadow {
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowOpacity = shadowOpacity
            self.layer.shadowRadius = 2.0
            self.layer.masksToBounds = false
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
        }
    }
}

extension String {
    func getDetailsFromJson<T: Codable>(_ model: T.Type) -> T? {
        let bundle = Bundle.main
        guard let path = bundle.path(forResource: self, ofType: "json") else { return nil }
        do {
            let decoder = JSONDecoder()
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonModel = try decoder.decode(model, from: jsonData)
            return jsonModel
        } catch {
            print("invalid json")
        }
        return nil
    }
}

extension UIViewController {
    class var storyboardID : String {
        return String(describing: self)
    }
    
    func showAlert(withMessage message: String, title: String? = nil, leftButton: String? = nil, rightButton: String, rightButtonColor: UIColor? = .black, completion: @escaping(AlertBlock)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        if let left = leftButton {
            let leftAction = UIAlertAction(title: left, style: .default, handler: { _ in
                completion(.left)
            })
            alert.addAction(leftAction)
        }
        
        let rightAction = UIAlertAction(title: rightButton, style: .default, handler: { _ in
            completion(.right)
        })
        alert.addAction(rightAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
}
