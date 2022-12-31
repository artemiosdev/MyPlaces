//
//  MapManager.swift
//  MyPlaces
//
//  Created by Artem Androsenko on 31.12.2022.
//

import UIKit
import MapKit

class MapManager {
    let locationManager = CLLocationManager()
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeters = 1000.0
    // место хранения маршрутов kCLLocationAccuracyBest
    private var directionsArray: [MKDirections] = []
    
    func setupPlacemark(place: Place, mapView: MKMapView) {
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
            annotation.title = place.name
            annotation.subtitle = place.type
            // привяжем annotation к конкретной точке на карте
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            // задаем видимую область карты
            mapView.showAnnotations([annotation], animated: true)
            // выделяем метку
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // проверяем геолокационные службы на устройстве
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        // настройка местоположения пользователя
        if CLLocationManager.locationServicesEnabled() {
            // определение местоположение пользователя, повышенная точность
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            // create and show alert controller about setup geolocation
            // позволяет отложить запуск alert на 1 секунду
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert( title: "Your Location is not Available",
                                message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
        }
    }
    
    // проверка статуса, разрешение на использование геопозиции от пользователя
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        let manager = CLLocationManager()
        switch manager.authorizationStatus {
            // когда приложению разрешено использовать геолокацию
            // в момент его использования
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            // определим регион местоположение
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        // включим режим постоянного отслеживания пользователя
        // после того как оно уже определено
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
        
        // убираем старые маршруты
        resetMapView(withNew: directions, mapView: mapView)
        
        // создаем новый маршрут
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
                mapView.addOverlay(route.polyline)
                // определяем зону видимости карты, чтобы весь маршрут умещался на экране
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                // доболнительная информация, расстояние и время в пути
//                let distance = String(format: "%.1f", route.distance / 1000)
//                let timeInterval = String(format: "%.0f", route.expectedTravelTime / 60)
//                self.mapViewController.routeInformation.isHidden = false
//                self.mapViewController.routeInformation.text = "Расстояние до места: \(distance) км. \n Время в пути составит: \(timeInterval) минут."
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        closure(center)

    }
    
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView ) {
        // перед наложением нового маршрута
        // удалим старый наложенный маршрут с карт
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        // отменим у каждого элемента из массива маршрут
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let longitude = mapView.centerCoordinate.longitude
        let latitude = mapView.centerCoordinate.latitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds )
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}
