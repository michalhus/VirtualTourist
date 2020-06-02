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
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    // MARK: Outlets' Actions

    @IBAction func newPhotoCollection(_ sender: Any) {
        deleteAllData()
        getLocationRandomPhotos()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        newCollectionButton.isEnabled = false
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.addAnnotation(selectedPin)
        loadData()
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
    
    // MARK: Data Loading
    func loadData() {
        if let picFromCoreData = reloadSavedData() {
            savedPhotoObjects = picFromCoreData
            savedPhotoObjects.isEmpty ? getLocationRandomPhotos() : self.collectionView.reloadData()
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

    // MARK: CORE DATA AND COLLECTION VIEW'S ARRAY CLEAN UP
    func deleteAllData() {
        for photo in savedPhotoObjects {
            DataController.shared.viewContext.delete(photo)
        }
        savedPhotoObjects.removeAll()
    }
    
    func deletePicture(index: Int) {
        newCollectionButton.isEnabled = false
        for (id, photo) in savedPhotoObjects.enumerated() {
            if ( id == index ) {
                DataController.shared.viewContext.delete(photo)
            }
        }
        savedPhotoObjects.remove(at:index)
        loadData()
    }
}

extension PhotoAlbumVC: NewCollectionStateDelegate {
    func buttonState(state: Bool) {
        if state {
            newCollectionButton.isEnabled = true
        }else {
            newCollectionButton.isEnabled = false
        }
    }
}
