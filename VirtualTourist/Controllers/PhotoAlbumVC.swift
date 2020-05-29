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

class PhotoAlbumVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    var selectedPin = MKPointAnnotation()
    var selectedPinCoreData: Pin!
    var savedPhotoObjects = [Photo]()
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var cellViewSize: CGFloat = 0
    var imageSize: CGSize = CGSize(width: 0, height: 0)
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: Outlets' Actions

    @IBAction func newPhotoCollection(_ sender: Any) {
//        deleteAllData()
        print("New Collection button pressed, need to clear data and get new one")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.addAnnotation(selectedPin)
                
        if let picFromCoreData = reloadSavedData() {
            savedPhotoObjects = picFromCoreData
            savedPhotoObjects.isEmpty ? getLocationRandomPhotos() : self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    // MARK: Core Data Fetching

    fileprivate func reloadSavedData() -> [Photo]? {
        var photos: [Photo] = []
            let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
            let predicate = NSPredicate(format: "pin == %@", argumentArray: [selectedPinCoreData!])
            fetchRequest.predicate = predicate
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            let photoCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            
            for index in 0..<photoCount {
                photos.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)))
            }
            return photos
            
        } catch {
            print("error performing fetch")
            return nil
        }
    }
    
    // MARK: Fetching API Responses
    
    func getLocationRandomPhotos() {
        _ = Client.shared.getLocationPhotos(latitude: selectedPin.coordinate.latitude, longitude: selectedPin.coordinate.longitude, completion: { (photos, error) in
            
            if let photos = photos {
                for photo in photos {
                    let photoCoreData = Photo(context: DataController.shared.viewContext)
                    photoCoreData.imageURL = "https://farm\(String(describing: photo.farm)).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
                    photoCoreData.creationDate = Date()
                    photoCoreData.pin = self.selectedPinCoreData
                    self.savedPhotoObjects.append(photoCoreData)
                    DataController.shared.saveContext()
                }
            }
            self.collectionView.reloadData()
        })
    }

//    func deleteAllData() {
//
//        for photo in savedPhotoObjects {
//            DataController.shared.viewContext.delete(photo)
//        }
//        savedPhotoObjects.removeAll()
//    }
    
}

// MARK: Collection View Data Source Extention

extension PhotoAlbumVC : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.savedPhotoObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photo Collection View Cell", for: indexPath) as! PhotoCollectionViewCell
        let savedPhoto = self.savedPhotoObjects[(indexPath as NSIndexPath).row]
        cell.downloadImage(from: URL(string: savedPhoto.imageURL ?? "")!, size: imageSize)

        return cell
    }
}

// MARK: Collection View FlowLayout Extention

extension PhotoAlbumVC : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + self.sectionInsets.left + self.sectionInsets.right + 30.0
        cellViewSize = (collectionView.frame.size.width - space) / itemsPerRow
        imageSize = CGSize(width: cellViewSize, height: cellViewSize)
        return imageSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: MapKit Extention

extension PhotoAlbumVC: MKMapViewDelegate {
    
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
}
