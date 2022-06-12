//
//  MapViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 9/6/22.
//

/// Clase para el mapa de la ubicacion, asi cuando se pulse la ubicacion se vea en pantalla completa

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    //MARK: - Variables
    var location: CLLocation?
    var mapView: MKMapView!
    
    //MARK: - Ciclo de vida del view
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTitle()
        configureMapView()
        configureLeftBarButton()
       
    }
    
    //MARK: - Configuraciones
    private func configureMapView(){
        
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        mapView.showsUserLocation = true
        
        if location != nil {
            mapView.setCenter(location!.coordinate, animated: false)
            mapView.addAnnotation(MapAnnotation(title: nil, coordinate: location!.coordinate))
        }
        
        // Añadimos el mapa a la vista
        view.addSubview(mapView)
    }
    
    // Boton para volver atras
    private func configureLeftBarButton(){
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))
    }
    
    // Titlo de la view
    private func configureTitle(){
        
        self.title = "Map"
    }
    
    //MARK: - Acciones
    @objc func backButtonPressed(){
        
        self.navigationController?.popViewController(animated: true)
    }
}
