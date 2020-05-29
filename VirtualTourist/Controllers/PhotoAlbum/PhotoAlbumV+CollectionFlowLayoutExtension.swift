//
//  PhotoAlbumV+CollectionFlowLayoutExtension.swift
//  VirtualTourist
//
//  Created by Michal Hus on 5/29/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import UIKit

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
