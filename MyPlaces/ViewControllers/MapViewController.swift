//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Artem Androsenko on 21.12.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewContollerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewContollerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
    // для хранения предыдущего местоположения пользователя
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView,
                                                 and: previousLocation) { currentLocation  in
                self.previousLocation = currentLocation
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    @IBOutlet var routeInformation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
    }
    
    // при нажатии, карта отцентрируется по месту положения пользователя
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        getDirections()
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        // закрываем view controller
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        goButton.isHidden = true
        routeInformation.isHidden = true
        routeInformation.layer.cornerRadius = 10
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func getDirections() {
        let locationManager = CLLocationManager()
        guard let location = locationManager.location?.coordinate else {
            mapManager.showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        // включим режим постоянного отслеживания пользователя
        // после того как оно уже определено
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = mapManager.createDirectionsRequest(from: location) else {
            mapManager.showAlert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
        
        // убираем старые маршруты
        mapManager.resetMapView(withNew: directions, mapView: mapView)
        
        // создаем новый маршрут
        // расчёт маршрута
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.mapManager.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            // response содержит в себе массив маршрутов routes
            // так как мы запросили и альтернативные маршруты
            for route in response.routes {
                // создаем геометрическое наложение маршрута
                self.mapView.addOverlay(route.polyline)
                // определяем зону видимости карты, чтобы весь маршрут умещался на экране
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                // доболнительная информация, расстояние и время в пути
                let distance = String(format: "%.1f", route.distance / 1000)
                let time = String(format: "%.0f", route.expectedTravelTime / 60)
                print("Расстояние до места: \(distance) км.")
                print("Время в пути составит: \(time) минут.")
                self.routeInformation.isHidden = false
                self.routeInformation.text = "Расстояние до места: \(distance) км. \n Время в пути составит: \(time) минут."
            }
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    // возвращает view, связанное с указанным объектом аннотации.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        // объект view c аннотацией на карте
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        // image for our banner
        if let imageDate = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50 ))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageDate)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    
    // считывание центра местоположение
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        // освобождение ресурсов связанных с геокодированием
        // отмена отложенного запроса
        geocoder.cancelGeocode()
        
        // преобразуем координаты в адрес
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildName = placemark?.subThoroughfare
            // обновляем интерфейс в основном потоке асинхронно
            DispatchQueue.main.async {
                if streetName != nil && buildName != nil {
                    self.addressLabel.text = "\(streetName!), \(buildName!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    // подсветим построенные маршруты на карте
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

// отслеживание статуса местоположения в реальном времени
extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
}
