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
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var mapButton: UIButton?
    @IBOutlet weak var mapButtonWidthConstraint: NSLayoutConstraint?
    
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
        setupSearchBar()
        setupNavigationController()
        
        viewModel.view = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameChanged(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar?.becomeFirstResponder()
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
    
    private func setupSearchBar() {
        searchBar?.barTintColor = .white
        searchBar?.searchTextField.leftView?.tintColor = .lightGray
        searchBar?.searchTextField.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.00)
        searchBar?.searchTextField.textColor = .black
    }
    
    private func setupNavigationController() {
        guard let chevronBack = UIImage(systemName: "chevron.left") else { return }
        navigationController?.navigationBar.backIndicatorImage = UIImage()
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
        navigationItem.backBarButtonItem = UIBarButtonItem(image: chevronBack,
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @IBAction func loadData() {
        searchBar?.resignFirstResponder()
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
    
    @IBAction func showMap() {
        guard let viewController = UIStoryboard(name: MapViewController.storyboard, bundle: nil).instantiateInitialViewController() as? MapViewController else { return }
        viewController.location = viewModel.lastFetchedLocation
        navigationController?.pushViewController(viewController, animated: true)
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
                                             and: NSLocalizedString("There was an error fetching results.\n\nPlease change your search criteria and try again.", comment: ""),
                                             on: self)
            } else if let firstItem = response?.mapItems.first {
                searchBar.resignFirstResponder()
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

extension ForecastViewController {

    @objc private func keyboardFrameChanged(notification: NSNotification) {
        guard let keyboardFrameEnd = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        collectionViewBottomConstraint?.constant = keyboardFrameEnd.cgRectValue.height
        view.layoutIfNeeded()
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        collectionViewBottomConstraint?.constant = .zero
        view.layoutIfNeeded()
    }

}

extension ForecastViewController: ForecastView {
    func didFetchData(with snapshot: NSDiffableDataSourceSnapshot<ForecastSection, AnyHashable>) {
        datasource?.apply(snapshot, animatingDifferences: true, completion: nil)
        
        UIView.animate(withDuration: 0.3) {[ weak self] in
            self?.mapButtonWidthConstraint?.constant = 51.0
            self?.view.layoutIfNeeded()
        }
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

