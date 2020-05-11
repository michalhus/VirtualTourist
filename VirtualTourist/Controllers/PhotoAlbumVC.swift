//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Michal Hus on 5/11/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentLatitude: Double?
    var currentLongitude: Double?
    var pin: Pin!
    var savedPhotoObjects = [Photo]()
    var searchResultPhotos: [searchLocationPicture] = []
    let numberOfColumns: CGFloat = 3
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    @IBAction func newPhotoCollection(_ sender: Any) {
        print("WIP - call to API happens and new photos are showns that overwrite old photo array collection")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let selectedPin = MKPointAnnotation()
        if let lat = CLLocationDegrees(exactly: pin.latitude), let lon = CLLocationDegrees(exactly: pin.longitude) {
            let coordinateLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            selectedPin.coordinate = coordinateLocation
        }
        mapView.addAnnotation(selectedPin)
    }

    
}
