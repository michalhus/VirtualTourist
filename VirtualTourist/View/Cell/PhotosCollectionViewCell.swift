//
//  PhotosCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Michal Hus on 5/12/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let shared = PhotoCollectionViewCell()
    
    @IBOutlet weak var labelURL: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
    
    
//    func downloadImage(coreDataPhotoEntity: Photo) {
//        let request = URLRequest(url: URL(string: coreDataPhotoEntity.imageURL!)!)
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//
//            print(error?.localizedDescription)
//            if error == nil {
//                DispatchQueue.main.async {
//
//                    do {
//                        coreDataPhotoEntity.imageData = data
//                        try DataController.shared.viewContext.save()
//                    } catch {
//                        print("saving photo image failed")
//                    }
//
//                    //                        self.imageCell.image = UIImage(data: data!)
//                    //                    PhotoCollectionViewCell.imageCell.image = UIImage(data: data! as Data)
//                    //                    self.saveImageDataToCoreData(photo, imageData: data! as Data)
//                }
//            }
//        }
//        .resume()
//
//    }
    
    
    func initWithPhoto(_ photo: Photo) {
        
        if photo.imageData != nil {
            
            DispatchQueue.main.async {
                
                self.imageCell.image = UIImage(data: photo.imageData! as Data)
            }
            
        } else {
            
            downloadImage(photo)
        }
    }
    
    //Download Images
    
    func downloadImage(_ photo: Photo) {
        
        URLSession.shared.dataTask(with: URL(string: photo.imageURL!)!) { (data, response, error) in
            
            if error == nil {
                DispatchQueue.main.async {
                    self.imageCell.image = UIImage(data: data! as Data)
                    self.saveImageDataToCoreData(photo, imageData: data! as Data)
                }
            }
        }
        .resume()
    }
    
    func saveImageDataToCoreData(_ photo: Photo, imageData: Data) {
        
        do {
            photo.imageData = imageData
            try DataController.shared.viewContext.save()
        } catch {
            print("saving photo image failed")
        }
    }
    
}
