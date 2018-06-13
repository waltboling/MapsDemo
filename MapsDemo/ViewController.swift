//
//  ViewController.swift
//  MapsDemo
//
//  Created by Jon Boling on 5/30/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocations()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let overlayRenderer = MKPolylineRenderer(overlay: overlay)
        overlayRenderer.strokeColor = .red
        overlayRenderer.lineWidth = 4.0
        
        return overlayRenderer
    }
    
    func showAlert() {
        let locationErrorAlert = UIAlertController(title: "No User Location Found", message: "If Using Xcode Simulator, Simulate Location and Click Try Again", preferredStyle: .alert)
        locationErrorAlert.addAction(UIAlertAction(title:"Ok", style: .default, handler: nil))
        locationErrorAlert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: reloadLocations))
        
        DispatchQueue.main.async {
        self.present(locationErrorAlert, animated: true)
        }
    }
    
    func reloadLocations(alert: UIAlertAction!){
        getLocations()
    }
    
    func getLocations() {
        mapView.delegate = self
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            userLocation = locationManager.location?.coordinate
        }
        
        if userLocation != nil {
            let developerLocation = CLLocationCoordinate2D(latitude: 39.328212, longitude: -76.616205)
            
            let startPlacemark = MKPlacemark(coordinate: developerLocation, addressDictionary: nil)
            let endPlacemark = MKPlacemark(coordinate: userLocation!, addressDictionary: nil)
            
            let startMapItem = MKMapItem(placemark: startPlacemark)
            let endMapItem = MKMapItem(placemark: endPlacemark)
            
            let startAnnotation = MKPointAnnotation()
            startAnnotation.title = "Developer Location"
            
            if let location = startPlacemark.location {
                startAnnotation.coordinate = location.coordinate
            }
            
            let endAnnotation = MKPointAnnotation()
            endAnnotation.title = "User Location"
            
            if let location = endPlacemark.location {
                endAnnotation.coordinate = location.coordinate
            }
            
            mapView.showAnnotations([startAnnotation, endAnnotation], animated: true )
            
            let directionReq = MKDirectionsRequest()
            directionReq.source = startMapItem
            directionReq.destination = endMapItem
            directionReq.transportType = .automobile
            
            let directions = MKDirections(request: directionReq)
            
            directions.calculate {
                (res, err) -> Void in
                
                guard let res = res else {
                    if let err = err {
                        print("Error: \(err)")
                    }
                    return
                }
                
                let route = res.routes[0]
                self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            }
        } else {
            print("No User Location Found")
            showAlert()
        }
    }
}

