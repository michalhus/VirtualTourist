//
//  SearchLocationPicture.swift
//  VirtualTourist
//
//  Created by Michal Hus on 5/7/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import Foundation

struct JsonFlickrApi: Codable {
    let photos: SearchLocationPictures
}

struct SearchLocationPictures: Codable {
    let photo: [SearchLocationPicture]
}

struct SearchLocationPicture: Codable {
    let id : String
    let server: String
    let farm: Int
    let secret: String
}
