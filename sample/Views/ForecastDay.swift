import Foundation
import UIKit

class ForecastDayCell: UICollectionViewCell {
    
    static let xib = "ForecastDay"
    static let identifier = "ForecastDayIdentifier"
    
    @IBOutlet weak var labelTitle: UILabel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        accessibilityIdentifier = nil
        labelTitle?.text = nil
    }
}
