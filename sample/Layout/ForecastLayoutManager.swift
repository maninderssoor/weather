import Foundation
import UIKit

struct ForecastLayoutManager {
    
    static var item: NSCollectionLayoutSection {
        let largeItemSize = NSCollectionLayoutSize(widthDimension: .absolute(.largeWidth),
                                                   heightDimension: .fractionalHeight(1))
        let largeItem = NSCollectionLayoutItem(layoutSize: largeItemSize)

        let smallItemSize = NSCollectionLayoutSize(widthDimension: .absolute(.smallWidth),
                                                   heightDimension: .fractionalHeight(1.0))
        let smallItem = NSCollectionLayoutItem(layoutSize: smallItemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(.largeWidth + (.smallWidth * 8.0)),
                                                       heightDimension: .absolute(100.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                     subitems: [largeItem, smallItem, smallItem, smallItem, smallItem, smallItem, smallItem, smallItem, smallItem])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
        section.orthogonalScrollingBehavior = .continuous

        return section
    }
}

private extension CGFloat {
    static let largeWidth: CGFloat = 150.0
    static let smallWidth: CGFloat = 100.0
}

