//
//  MapSelectionViewModel.swift
//  isBlum
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

class MapSelectionViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published State
    
    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    )
    
    @Published var centerCoordinate = CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234)
    @Published var selectedAddress: String = "Loading..."
    @Published var isMapMoving: Bool = false
    @Published var isIdleBouncing: Bool = false
    
    // MARK: - Private Properties
    
    private let geocoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    private var isInitialLocationSet = false
    
    // MARK: - Init
    
    override init() {
        super.init()
        setupLocationManager()
        setupSearchDebounce()
    }
    
    // MARK: - Map Movement Logic
    
    func setMapMoving(_ moving: Bool) {
        if isMapMoving != moving {
            isMapMoving = moving
            
            if moving {
                // Stop idle bounce and show placeholder when map starts moving
                isIdleBouncing = false
                selectedAddress = "Determining address..."
            } else {
                // Restart idle bounce when map stops
                startIdleBounce()
            }
        }
    }
    
    private func startIdleBounce() {
        // Delay slightly to allow the "landing" animation to finish first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isIdleBouncing = true
        }
    }
    
    // MARK: - Location Manager Setup
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, !isInitialLocationSet else { return }
        
        // Stop updates after finding the user to save battery
        locationManager.stopUpdatingLocation()
        
        DispatchQueue.main.async {
            self.cameraPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            )
            self.centerCoordinate = location.coordinate
            self.isInitialLocationSet = true
            self.startIdleBounce()
        }
    }
    
    // MARK: - Search Debounce
    
    private func setupSearchDebounce() {
        $centerCoordinate
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates(by: { lhs, rhs in
                // Compare coordinates with precision tolerance
                abs(lhs.latitude - rhs.latitude) < 0.00001 &&
                abs(lhs.longitude - rhs.longitude) < 0.00001
            })
            .sink { [weak self] coordinate in
                self?.reverseGeocode(coordinate)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Helper Methods
    
    func centerOnUser() {
        guard let userLocation = locationManager.location?.coordinate else { return }
        
        withAnimation(.easeInOut(duration: 0.4)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            )
        }
        centerCoordinate = userLocation
    }
    
    // MARK: - Reverse Geocoding
    
    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        geocoder.cancelGeocode()
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let p = placemarks?.first else { return }
            
            let street = p.thoroughfare ?? ""
            let number = p.subThoroughfare ?? ""
            let city = p.locality ?? ""
            
            DispatchQueue.main.async {
                let fullAddress = "\(street) \(number), \(city)"
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                self?.selectedAddress = fullAddress.isEmpty ? "Point on map" : fullAddress
            }
        }
    }
}
