//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Artem Androsenko on 21.12.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var place = Place()
    @IBOutlet var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacemark()
        
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupPlacemark() {
        guard let location = place.location else { return }
        // отвечает за преобразование гео координат и названий
        // будет преобразовывать адрес из location в гео координаты
        let geocoder = CLGeocoder()
        // получаем метку/метки
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            // получаем нашу метку адреса (здесь только координаты)
            let placemark = placemarks.first
            // опишем нашу метку на карте
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            // привяжем annotation к конкретной точке на карте
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            // задаем видимую область карты
            self.mapView.showAnnotations([annotation], animated: true)
            // выделяем метку
            self.mapView.selectAnnotation(annotation, animated: true)
            
        }
        
    }
    
}
