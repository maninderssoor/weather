import Foundation
import UIKit

extension UIImageView {
    func download(from urlString: String?, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else { return }
        
        alpha = 0.0
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
                
                UIView.animate(withDuration: 0.3) {[weak self] in
                    self?.alpha = 1.0
                }
            }
        }.resume()
    }
}
