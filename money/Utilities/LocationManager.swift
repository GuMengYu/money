import Combine  // For ObservableObject
import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let manager = CLLocationManager()

  @Published var locationCoordinate: CLLocationCoordinate2D? = nil
  @Published var authorizationStatus: CLAuthorizationStatus
  @Published var isLoading: Bool = false
  @Published var locationError: Error? = nil

  override init() {
    authorizationStatus = manager.authorizationStatus
    super.init()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest  // Or kCLLocationAccuracyNearestTenMeters for less power consumption
  }

  func requestLocationPermission() {
    if authorizationStatus == .notDetermined {
      print("Requesting When In Use authorization")
      manager.requestWhenInUseAuthorization()
    }
  }

  func requestLocation() {
    guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    else {
      print("Location permission not granted. Status: \(authorizationStatus.rawValue)")
      // Optionally, guide user to settings if denied
      if authorizationStatus == .denied || authorizationStatus == .restricted {
        // Consider showing an alert to guide user to settings
        print("Location permission denied or restricted. Guide user to settings.")
      }
      // If not determined, and we are trying to get location, we should have called requestLocationPermission first.
      // If permission is not determined here, it implies requestLocationPermission wasn't called or hasn't completed.
      return
    }
    print("Requesting location update")
    isLoading = true
    locationError = nil
    manager.requestLocation()  // For a one-time location update
  }

  // MARK: - CLLocationManagerDelegate methods

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    isLoading = false
    guard let location = locations.first else {
      locationError = NSError(
        domain: "LocationManagerError", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "No location found"])
      print("No location found in update")
      return
    }
    locationCoordinate = location.coordinate
    print("Location fetched: \(location.coordinate.latitude), \(location.coordinate.longitude)")
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    isLoading = false
    locationError = error
    print("Failed to get location: \(error.localizedDescription)")
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    DispatchQueue.main.async {
      let newStatus = manager.authorizationStatus
      print("Location authorization status changed to: \(newStatus.rawValue)")
      self.authorizationStatus = newStatus
      if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
        print("Location permission granted or already available.")
        // If user is actively trying to include location and permission was just granted,
        // they might need to tap the button again or we could auto-trigger requestLocation().
        // For now, AddTransactionView handles re-requesting if includeLocation is true.
      } else {
        print(
          "Location permission not granted (denied, restricted, or not determined). Status: \(newStatus.rawValue)"
        )
      }
    }
  }
}
