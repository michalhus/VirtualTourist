//
//  TravelLocationsMapVC+MapKitExtension.swift
//  VirtualTourist
//
//  Created by Michal Hus on 5/14/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import MapKit

extension TravelLocationsMapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.black
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    //    NEED TO ADD DESELECT OF THE PIN AFTER BACK BUTTON IS PRESSED IN ONTHER VC
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        let selectedPin = MKPointAnnotation()
        let vc = storyboard?.instantiateViewController(identifier: "PhotoAlbumVC") as! PhotoAlbumVC
        let selectedPinCoordinates = view.annotation?.coordinate
        selectedPin.coordinate = selectedPinCoordinates!
        vc.selectedPin = selectedPin
        navigationController?.pushViewController(vc, animated: true)
    }
}
