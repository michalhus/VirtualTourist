//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Michal Hus on 4/9/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var latitude: Double?
    var longitude: Double?
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // MARK: CORE DATA Fetch
        // This retrive or fetches an Array of enteties in this case type of Pin so [Pin]
        if let results = try? DataController.shared.viewContext.fetch(fetchRequest) {
            for result in results {
                // Define new MapKit Annotation obj to populate its info form CoreData and to display it on the Map
                let pinAnnotation = MKPointAnnotation()
                if let lat = CLLocationDegrees(exactly: result.latitude), let lon = CLLocationDegrees(exactly: result.longitude) {
                    let coordinateLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    pinAnnotation.coordinate = coordinateLocation
                }
                mapView.addAnnotation(pinAnnotation)
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
    
    // MARK: Add pin and save it in Core Data
    // NOTE: Core Data entety is not of same type as pin annotatin "MKPointAnnotation()" hence, stored data is not same format
    // and will need to be coverted to proper format when retriving it.
    func addPinAnnotation(location: CLLocationCoordinate2D){
        
        // How to call/create new entity
        let pin = Pin(context: DataController.shared.viewContext)
        
        // How to create a new MapKit Pin object
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        // Added annotation to the mapView, mapView is an Outlet for the map
        self.mapView.addAnnotation(annotation)
        
        pin.latitude = Double(annotation.coordinate.latitude)
        pin.longitude = Double(annotation.coordinate.longitude)
        pin.createdDate = Date()
        DataController.shared.saveContext()
    }
}
