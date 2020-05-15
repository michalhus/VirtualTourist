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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedPin = MKPointAnnotation()
    var selectedPinCoreData: Pin!
    var savedPhotoObjects = [Photo]()

    let numberOfColumns: CGFloat = 3
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    @IBAction func newPhotoCollection(_ sender: Any) {
//        clearOldCollection
//        get new items
        getLocationRandomPhotos()
    }
    
    fileprivate func reloadSavedData() -> [Photo]? {
        var photos: [Photo] = []
            let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
            let predicate = NSPredicate(format: "pin == %@", argumentArray: [selectedPinCoreData!])
            fetchRequest.predicate = predicate
            let sortDescriptor = NSSortDescriptor(key: "imageURL", ascending: true)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.addAnnotation(selectedPin)
        
        if reloadSavedData()!.isEmpty {
            getLocationRandomPhotos()
        } else {
            savedPhotoObjects = reloadSavedData()!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView!.reloadData()
    }
    
    func getLocationRandomPhotos() {
        _ = Client.shared.getLocationPhotos(latitude: selectedPin.coordinate.latitude, longitude: selectedPin.coordinate.longitude, completion: { (photos, error) in
            
            if let photos = photos {
                for photo in photos {
                    let photoCoreData = Photo(context: DataController.shared.viewContext)
                    photoCoreData.imageURL = "https://farm\(String(describing: photo.farm)).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
                    photoCoreData.pin = self.selectedPinCoreData
                    self.downloadImage(from: photoCoreData)
                    DataController.shared.saveContext()
                }
            }
        })
    }
        
    func getData(from photo: Photo, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        if let urlString = photo.imageURL, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        }
    }
    
    func downloadImage(from photo: Photo) {
        getData(from: photo) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                photo.imageData = data
                DataController.shared.saveContext()
                self?.savedPhotoObjects.append(photo)
                self?.collectionView.reloadData()
            }
        }
    }
}












extension PhotoAlbumVC : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    // MARK: Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.savedPhotoObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photo Collection View Cell", for: indexPath) as! PhotoCollectionViewCell
        let savedPhoto = self.savedPhotoObjects[(indexPath as NSIndexPath).row]
        
        // Set image
        cell.imageCell.image = UIImage(data: savedPhoto.imageData!)
        return cell
    }
}

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



//        @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
   
   
   // MARK: Life Cycle
   //        override func viewDidLoad() {
   //            super.viewDidLoad()
   //
   //            let space:CGFloat = 3.0
   //            let dimension = (view.frame.size.width - (2 * space)) / 3.0
   //
   //            flowLayout.minimumInteritemSpacing = space
   //            flowLayout.minimumLineSpacing = space
   //            flowLayout.itemSize = CGSize(width: dimension, height: dimension)
   //        }
   
   //        override func viewWillAppear(_ animated: Bool) {
   //            super.viewWillAppear(animated)
   //            self.tabBarController?.tabBar.isHidden = false
   //            collectionView!.reloadData()
   //        }
