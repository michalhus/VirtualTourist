//
//  PhotoAlbumV+CollectionDataSourceExtension.swift
//  VirtualTourist
//
//  Created by Michal Hus on 5/29/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import UIKit

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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let indexOfPicture = (indexPath as NSIndexPath).row
        deletePicture(index: indexOfPicture)
    }
}