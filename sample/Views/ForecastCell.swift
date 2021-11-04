import Foundation
import UIKit

class ForecastCell: UICollectionViewCell {
    
    static let xib = "ForecastCell"
    static let identifier = "ForecastCellIdentifier"
    
    @IBOutlet weak var labelTemperature: UILabel?
    @IBOutlet weak var imageIcon: UIImageView?
    @IBOutlet weak var labelTime: UILabel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        accessibilityIdentifier = nil
        labelTemperature?.text = nil
        imageIcon?.image = nil
        labelTime?.text = nil
    }
}
