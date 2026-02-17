import SwiftUI
import MapKit
import Combine
import CoreLocation


class AddressViewModel: NSObject, ObservableObject {
    @Published var searchText = ""
    @Published var results: [AddressModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let completer = MKLocalSearchCompleter()
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        
        completer.delegate = self
        completer.resultTypes = .address
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty {
                    self.results = []
                } else {
                    self.completer.queryFragment = text
                }
            }
            .store(in: &cancellables)
    }
    
    func requestLocation() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func selectAddress(_ address: AddressModel) {
        searchText = address.street
        results = []
        print("Selected: \(address.street), \(address.city)")
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension AddressViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = completer.results.map { suggestion in
                AddressModel(
                    street: suggestion.title,
                    city: suggestion.subtitle
                )
            }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Completer error: \(error.localizedDescription)")
    }
}

// MARK: - CLLocationManagerDelegate
extension AddressViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationManager.stopUpdatingLocation()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                let street = placemark.thoroughfare ?? ""
                let number = placemark.subThoroughfare ?? ""
                let city = placemark.locality ?? ""
                
                let fullAddress = "\(street) \(number)".trimmingCharacters(in: .whitespaces)
                
                DispatchQueue.main.async {
                    self?.searchText = fullAddress
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    

    func confirmSelection() {
        if let firstResult = results.first {
            selectAddress(firstResult)
        }
    }
}
