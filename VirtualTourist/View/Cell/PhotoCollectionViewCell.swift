//
//  PhotosCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Michal Hus on 5/12/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import Foundation
import UIKit

protocol newCollectionStateDelegate {
    func buttonState(state: Bool)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageCell: UIImageView!
    var buttonStateDelegate: newCollectionStateDelegate?
    
    var isImageLoaded: Bool = false
    
    func downloadImage(from url: URL, size: CGSize) {
//        self.buttonStateDelegate?.buttonState(state: false)
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                guard let image = UIImage(data: data) else { return }
                self.imageScalling(imageSize: size, locationImage: image )
                self.buttonStateDelegate?.buttonState(state: true)
            

//                self.isImageLoaded = true
                
//                if (self?.imageCell.image != nil) {
//                   PhotoAlbumVC.shared.newCollectionButton.isEnabled = true
//                    } else {
//                        PhotoAlbumVC.shared.newCollectionButton.isEnabled = false
//                    }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func imageScalling(imageSize: CGSize, locationImage: UIImage) {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        locationImage.draw(in: CGRect(origin: CGPoint.zero, size: imageSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.imageCell.image = scaledImage
    }
}
