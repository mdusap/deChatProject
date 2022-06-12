//
//  LocationManager.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 9/6/22.
//

/// Clase model para localizacion

import Foundation
import CoreLocation

// Informa cuando la localizacion va cambiando
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D?
    
    private override init(){
        super.init()
        // Preguntar por permisos
        permissionLocation()
        
    }
    
    func permissionLocation(){
        if locationManager == nil {
            print("Manager de la Ubicacion")
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            // Posicion lo mas exacta posible
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            // Solo se vera la localizacion cuando el usuario este usando la app
            locationManager!.requestWhenInUseAuthorization()
        }else{
            print("Existe el Manager de la Ubicacion")
        }
    }
    
    // Recibir cambios acerca del cambio de la localizacion
    func startUpdating(){
        locationManager!.startUpdatingLocation()
    }
    // Dejar de reecibir cambios acerca del cambio de la localizacion
    func stopUpdating(){
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }
    
    //MARK: - Delegados
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error en obtener la ubicacion")
    }
    
    // Coger la ubicacion mas reciente
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations.last!.coordinate
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if manager.authorizationStatus == .notDetermined {
            
            self.locationManager!.requestWhenInUseAuthorization()
        }
    }
}
