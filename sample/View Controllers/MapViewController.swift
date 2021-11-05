import Foundation
import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    static let storyboard = "MapViewController"
    
    @IBOutlet weak var mapView: MKMapView?
    
    var location: CLLocation?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadLocation()
    }
    
    func loadLocation () {
        if let annotations = mapView?.annotations {
            mapView?.removeAnnotations(annotations)
        }
        
        guard let location = location else { return }
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                       longitude: location.coordinate.longitude)
        
        mapView?.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: annotation.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView?.region = region
        
    }
    
}
