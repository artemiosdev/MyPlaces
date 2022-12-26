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
    var mapViewControllerDelegate: MapViewContollerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.0
    var incomeSegueIdentifier = ""
    // принимает координаты заведения
    var placeCoordinate: CLLocationCoordinate2D?
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }
    // при нажатии, карта отцентрируется по месту положения пользователя
    @IBAction func centerViewInUserLocation() {
        showUserLocation()
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
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
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
            self.placeCoordinate = placemarkLocation.coordinate
            // задаем видимую область карты
            self.mapView.showAnnotations([annotation], animated: true)
            // выделяем метку
            self.mapView.selectAnnotation(annotation, animated: true)
            
        }
        
    }
    
    // проверяем геолокационные службы на устройстве
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // create and show alert controller about setup geolocation
            // позволяет отложить запуск alert на 1 секунду
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert( title: "Your Location is not Available",
                                message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
        }
    }
    
    // настройка местоположения пользователя
    private func setupLocationManager() {
        locationManager.delegate = self
        // определение местоположени пользователя
        // повышенная точность
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    // проверка статуса, разрешение на использование геопозиции от пользователя
    private func checkLocationAuthorization() {
        let manager = CLLocationManager()
        switch manager.authorizationStatus {
            // когда приложению разрешено использовать геолокацию
            // в момент его использования
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
            // статус, когда приложению отказано в использовании служб геолокации,
            // или они отключены в настройках
        case .denied:
            // show alert controller about setup geolocation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your Location is not Available",
                               message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
            break
            // статус неопределен,
            // пользователь неопеределился с выбором
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            // если приложение не авторизовано для служб геолокации
        case .restricted:
            // show alert controller about setup geolocation
            break
            // когда разрешение на использование геолокации получено
        case .authorizedAlways:
            break
            // если в будущем появится новый case
        @unknown default:
            print("New case is available")
        }
    }
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            // определим регион местоположение, в 10 км
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
        // расчёт маршрута
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
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
//                print("Расстояние до места: \(distance) км.")
//                print("Время в пути составит: \(time) минут.")
                
//                изменить под свой label
//                self.addressLabel.isHidden = false
//                self.addressLabel.text = "Расстояние до места: \(distance) км. Время в пути составит: \(time) минут."
                
            }
        }
        
        
        
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        // определяем точки начала и конца маршрута
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        // создаем запрос на простроение маршрута между точками
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        // зададим тип транспорта для построения маршрута
        request.transportType = .automobile
        // позволяет строить несколько альтернативных маршрутов если есть их варианты
        request.requestsAlternateRoutes = true
        return request
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let longitude = mapView.centerCoordinate.longitude
        let latitude = mapView.centerCoordinate.latitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
        
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
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
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
    // устаревший метод
    //    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    //
    //    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
