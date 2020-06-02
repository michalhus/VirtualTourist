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
    @IBOutlet weak var imageCell: UIImageView!
    
    func isLoading(_ indicator: Bool) {

        if indicator {
            print("Laoding Indicator")
        } else {
            print("Image Loaded")
        }
    }
    
    func downloadImage(from url: URL, size: CGSize) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                guard let image = UIImage(data: data) else { return }
                self?.imageScalling(imageSize: size, locationImage: image )
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

        self.isLoading(false)
        self.imageCell.image = scaledImage
    }
}
