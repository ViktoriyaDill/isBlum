import SwiftUI
import MapKit
import Combine
import CoreLocation


class AddressViewModel: NSObject, ObservableObject {
    @Published var searchText = ""
    @Published var results: [AddressModel] = []
    @Published var isAddressSelected = false
    
    private var cancellables = Set<AnyCancellable>()
    private let completer = MKLocalSearchCompleter()
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    private var isManualLocationRequest = false
    private var isProgrammaticChange = false
    

    
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
                
                if self.isProgrammaticChange {
                    self.isProgrammaticChange = false
                    return
                }
                
                self.isAddressSelected = false  // ← додати
                
                if text.isEmpty {
                    self.results = []
                } else {
                    self.completer.queryFragment = text
                }
            }
            .store(in: &cancellables)
    }
    
    func clearSearch() {
        withAnimation(.none) {
            searchText = ""
            results = []
        }
    }
    
    func requestLocation() {
        isManualLocationRequest = true
        results = []
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func selectAddress(_ address: AddressModel) {
        isProgrammaticChange = true
        searchText = address.title
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.isProgrammaticChange = false
        }
    }
    
    private func updateSearchText(_ text: String) {
        isProgrammaticChange = true
        searchText = text
    }


}

// MARK: - MKLocalSearchCompleterDelegate
extension AddressViewModel: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        guard !isAddressSelected else { return } 
        DispatchQueue.main.async {
            self.results = completer.results.map { suggestion in
                AddressModel(street: suggestion.title, city: suggestion.subtitle)
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
        guard isManualLocationRequest else { return }
        guard let location = locations.first else { return }
        isManualLocationRequest = false
        locationManager.stopUpdatingLocation()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                let street = placemark.thoroughfare ?? ""
                let number = placemark.subThoroughfare ?? ""
                let city = placemark.locality ?? ""
                
                let fullAddress = "\(street) \(number)".trimmingCharacters(in: .whitespaces)
                
                DispatchQueue.main.async {
                    self?.updateSearchText(fullAddress)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard isManualLocationRequest else { return }
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    

    func confirmSelection(coordinator: AppCoordinator) {
        if let firstResult = results.first {
            selectAddress(firstResult)
        }
    }
}
