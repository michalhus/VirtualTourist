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
    
    var loadingIndicator = UIActivityIndicatorView()

    func activityIndicator() {
        loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.center = self.imageCell.center
        self.imageCell.addSubview(loadingIndicator)
    }
    
    func isLoading(_ indicator: Bool) {

        if indicator {
            self.activityIndicator()
            loadingIndicator.startAnimating()
            loadingIndicator.backgroundColor = .white
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicator.hidesWhenStopped = true
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
