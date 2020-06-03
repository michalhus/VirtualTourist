//
//  PhotosCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Michal Hus on 5/12/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import Foundation
import UIKit

protocol NewCollectionStateDelegate: class {
    func buttonState(state: Bool)
    func loadedCounter()
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageCell: UIImageView!
    weak var buttonStateDelegate: NewCollectionStateDelegate?
    
    var isImageLoaded: Bool = false
    
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
            self.buttonStateDelegate?.buttonState(state: false)
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicator.hidesWhenStopped = true
            self.buttonStateDelegate?.buttonState(state: true)
        }
    }
    
    func downloadImage(from url: URL, size: CGSize) {
        
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: url) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading a picture: \(e)")
            } else {
                if let res = response as? HTTPURLResponse {
                    print("Downloaded picture with response code \(res.statusCode)")
                    if let imageData = data {
                        DispatchQueue.main.async() {
                            guard let image = UIImage(data: imageData) else { return }
                            self.imageScalling(imageSize: size, locationImage: image )
                        }
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        downloadPicTask.resume()
    }
    
    func imageScalling(imageSize: CGSize, locationImage: UIImage) {
        
        self.buttonStateDelegate?.buttonState(state: false)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        locationImage.draw(in: CGRect(origin: CGPoint.zero, size: imageSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.isLoading(false)
        self.buttonStateDelegate?.loadedCounter()
        self.imageCell.image = scaledImage
    }
}
