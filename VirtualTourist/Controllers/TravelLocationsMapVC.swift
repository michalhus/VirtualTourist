//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Michal Hus on 4/9/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class TravelLocationsMapVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [Pin]()
//    var pins = [MKPointAnnotation]()
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var latitude: Double?
    var longitude: Double?
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? DataController.shared.viewContext.fetch(fetchRequest) {
            annotations = result
            for annotation in annotations {
                let savedPin = MKPointAnnotation()
                if let lat = CLLocationDegrees(exactly: annotation.latitude), let lon = CLLocationDegrees(exactly: annotation.longitude) {
                    let coordinateLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    savedPin.coordinate = coordinateLocation
                    savedPin.title = "Photos"
//                    pins.append(savedPin)
                }
                mapView.addAnnotation(savedPin)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        setupFetchedResultsController()
    }
    
    @objc func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addPinAnnotation(location: locationOnMap)
        }
    }
    
    //MARK: Add pin and save it in Core Data
    func addPinAnnotation(location: CLLocationCoordinate2D){
        
        let pin = Pin(context: DataController.shared.viewContext)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        self.mapView.addAnnotation(annotation)
        
        pin.latitude = Double(annotation.coordinate.latitude)
        pin.longitude = Double(annotation.coordinate.longitude)
        pin.createdDate = Date()
        
        annotations.append(pin)
        DataController.shared.saveContext()
    }
}

extension TravelLocationsMapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = UIColor.black
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){}
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let photoAlbumVC = view.annotation?.title! {
                
                let vc = storyboard?.instantiateViewController(identifier: "PhotoAlbumVC") as! PhotoAlbumVC
                let locationLat = view.annotation?.coordinate.latitude
                let locationLon = view.annotation?.coordinate.longitude
                let myCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: locationLat!, longitude: locationLon!)
                let selectedPin: MKPointAnnotation = MKPointAnnotation()
                selectedPin.coordinate = myCoordinate
                
                for pin in annotations {
                    if pin.latitude == selectedPin.coordinate.latitude &&
                        pin.longitude == selectedPin.coordinate.longitude {
                        vc.pin = pin
                        navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}
