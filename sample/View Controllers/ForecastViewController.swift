import CoreLocation
import MapKit
import Foundation
import UIKit

class ForecastViewController: UIViewController {
    
    private let viewModel: ForecastViewModel
    
    private lazy var datasource: UICollectionViewDiffableDataSource<ForecastSection, AnyHashable>? = {
        guard let collectionView = self.collectionView else { return nil }
        
        return UICollectionViewDiffableDataSource<ForecastSection, AnyHashable>(collectionView: collectionView) { collectionView, indexPath, item in
            
            switch item {
            case let item as ForecastDay:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastDayCell.identifier, for: indexPath) as? ForecastDayCell else { return UICollectionViewCell() }
                
                cell.labelTitle?.text = item.day
                
                return cell
            case let item as ForecastItem:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastCell.identifier, for: indexPath) as? ForecastCell else { return UICollectionViewCell() }
                
                cell.labelTime?.text = item.formattedTime
                cell.labelTemperature?.text = item.formattedTemperature
                cell.imageIcon?.download(from: item.weather.first?.imageUrlString)
                
                return cell
            default:
                return UICollectionViewCell()
            }
        }
    }()
    
    private lazy var flowLayout: UICollectionViewLayout = {
        UICollectionViewCompositionalLayout { sectionIdentifier, _ -> NSCollectionLayoutSection? in
            return ForecastLayoutManager.item
        }
    }()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        
        return manager
    }()
    
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var searchBar: UISearchBar?
    
    init(viewModel: ForecastViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = ForecastViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        viewModel.view = self
    }
}

extension ForecastViewController {
    
    private func setupCollectionView() {
        collectionView?.register(UINib(nibName: ForecastCell.xib, bundle: nil), forCellWithReuseIdentifier: ForecastCell.identifier)
        collectionView?.register(UINib(nibName: ForecastDayCell.xib, bundle: nil), forCellWithReuseIdentifier: ForecastDayCell.identifier)
        collectionView?.collectionViewLayout = flowLayout
        collectionView?.contentInset = UIEdgeInsets(top: searchBar?.frame.size.height ?? 0,
                                                    left: 0,
                                                    bottom: 0,
                                                    right: 0 )
        collectionView?.accessibilityIdentifier = "collectionView"
    }
    
    @IBAction func loadData() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            UIAlertController.controller(with: NSLocalizedString("Error", comment: ""),
                                         and: NSLocalizedString("Please enable location services for Weather in iOS Settings -> Privacy -> Location Preferences", comment: ""),
                                         on: self)
        default:
            locationManager.startUpdatingLocation()
        }
    }
}

extension ForecastViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            if error != nil {
                UIAlertController.controller(with: NSLocalizedString("Error", comment: ""),
                                             and: NSLocalizedString("There was n error fetching results.\n\nPlease change your search criteria and try again.", comment: ""),
                                             on: self)
            } else if let firstItem = response?.mapItems.first {
                searchBar.text = firstItem.name
                let location = CLLocation(latitude: firstItem.placemark.coordinate.latitude,
                                          longitude: firstItem.placemark.coordinate.longitude)
                self.viewModel.fetchData(with: location)
            }
        }
    }
    
}

extension ForecastViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus == .authorizedAlways ||
                manager.authorizationStatus == .authorizedWhenInUse else { return }
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        viewModel.fetchData(with: location)
        searchBar?.text = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get the users location with error \(String(describing: error))")
        UIAlertController.controller(with: NSLocalizedString("Error", comment: ""),
                                     and: NSLocalizedString("Error fetching your location", comment: ""),
                                     on: self)
        locationManager.stopUpdatingLocation()
    }
}

extension ForecastViewController: ForecastView {
    func didFetchData(with snapshot: NSDiffableDataSourceSnapshot<ForecastSection, AnyHashable>) {
        self.datasource?.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func didFailFetch(with error: ForecastError) {
        print("Failed to fetch Items \(String(describing: error))")
        
        UIAlertController.controller(with: NSLocalizedString("Error", comment: ""),
                                     and: NSLocalizedString("Couldn't fetch results", comment: ""),
                                     on: self)
    }
    
}

protocol ForecastView: AnyObject {
    func didFetchData(with snapshot: NSDiffableDataSourceSnapshot<ForecastSection, AnyHashable>)
    func didFailFetch(with error: ForecastError)
}

private extension CGFloat {
    static let scrollViewPrefetchInset: CGFloat = 300.0
}

private extension Int {
    static let initialPaginatedPageIndex: Int = 2
}

