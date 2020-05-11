//
//  x.swift
//  VirtualTourist
//
//  Created by Michal Hus on 5/11/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    var currentLatitude: Double?
    var currentLongitude: Double?
    var pin: Pin!
    var savedPhotoObjects = [Photo]()
    var searchResultPhotos: [searchLocationPicture] = []
    let numberOfColumns: CGFloat = 3
    var fetchedResultsController: NSFetchedResultsController<Photo>!
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        print("tapped on pin ")
    }
    
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
                }
                vc.currentLatitude = pin.latitude
                vc.currentLongitude = pin.longitude
            }
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
}
