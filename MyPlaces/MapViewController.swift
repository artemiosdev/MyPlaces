//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Artem Androsenko on 21.12.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.0
    let incomeSegueIdentifier = ""
    @IBOutlet var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    private func setupMapView() {
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
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
            if incomeSegueIdentifier == "getAdress" { showUserLocation() }
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
