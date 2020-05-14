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
    var savedPhotoObjects = [Photo]()
    
    
    
    
    var pin: Pin!
    var searchResultPhotos: [SearchLocationPicture] = []
    var photoURLs: [String] = []
    
    
    
    let numberOfColumns: CGFloat = 3
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    @IBAction func newPhotoCollection(_ sender: Any) {
        //        print(photoURLs)
        getLocationRandomPhotos()
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        //        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        //        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let results = try? DataController.shared.viewContext.fetch(fetchRequest) {
            savedPhotoObjects = results
            
            
            
            for savedPhoto in savedPhotoObjects {
                
                if let url = savedPhoto.imageURL {
                    //                    add to the collection view cell
                    
                    
                    
                }
            }
            
            
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.addAnnotation(selectedPin)
        //this needs to retrive data from coredata for pics and if no pics than get random photos
        //        getLocationRandomPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView!.reloadData()
    }
    
    func getLocationRandomPhotos() {
        _ = Client.shared.getLocationPhotos(latitude: pin.latitude, longitude: pin.longitude, completion: { (photos, error) in
            if let error = error {
                DispatchQueue.main.sync {
                    print(error)
                }
            } else {
                if let photos = photos {
                    self.searchResultPhotos = photos
                    self.getPhotoURLs(photos: photos)
                    //                    self.clearPhotoCoreData(photoURLs)
                    self.savePhotosInCoreData(photoURLs: self.photoURLs)
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    func getPhotoURLs(photos: [SearchLocationPicture]) {
        for photo in photos {
            photoURLs.append("https://farm\(String(describing: photo.farm)).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")
        }
    }
    
    
    //    func clearPhotoCoreData() {
    //
    //    }
    
    func savePhotosInCoreData(photoURLs: [String]) {
        for photoURL in photoURLs {
            let photo = Photo(context: DataController.shared.viewContext)
            photo.imageURL = photoURL
            
            //            savedPhotoObjects.append(photo)
            
            DataController.shared.saveContext()
        }
    }
    
    
    
    
    
    
    
    
    
    //        @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: Properties
    //        var memes: [Meme]! {
    //            let object = UIApplication.shared.delegate
    //            let appDelegate = object as! AppDelegate
    //            return appDelegate.memes
    //        }
    
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
    
    
    
}

extension PhotoAlbumVC : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    // MARK: Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.savedPhotoObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photo Collection View Cell", for: indexPath) as! PhotoCollectionViewCell
        let savedPhoto = self.savedPhotoObjects[(indexPath as NSIndexPath).row]
        
        
        // Set the text and image
        cell.labelURL.text = savedPhoto.imageURL
        cell.initWithPhoto(savedPhoto)
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
