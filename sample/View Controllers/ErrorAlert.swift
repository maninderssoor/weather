import Foundation
import UIKit

extension UIAlertController {
    
    static func controller(with title: String, and message: String, on viewController: UIViewController) {
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: NSLocalizedString("O.K.", comment: ""),
                                         style: .cancel,
                                         handler: nil)
        controller.addAction(cancelButton)
        
        viewController.present(controller, animated: true, completion: nil)
    }
}
