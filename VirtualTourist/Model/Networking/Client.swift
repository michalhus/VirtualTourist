//
//  Client.swift
//  VirtualTourist
//
//  Created by Michal Hus on 5/7/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import UIKit
import Foundation

class Client {
    
    static let shared = Client()
    
    let base = "https://www.flickr.com/services/rest/"
    let apiKey = "07791be27ed201d33cfff3bdf4c45266"
    let locationPhotosEndpoint = "flickr.photos.search"
    
    func
        getLocationPhotos(latitude: Double, longitude: Double, completion: @escaping ([SearchLocationPicture]?, String?) -> Void ) {
        
        guard var components = URLComponents(string: base) else {
            completion(nil, "Invalid URLComponent(s)")
            return
        }
        
        let endpointQuery = URLQueryItem(name: "method", value: locationPhotosEndpoint)
        let apiKeyQuery = URLQueryItem(name: "api_key", value: apiKey)
        let formatQuery = URLQueryItem(name: "format", value: "json")
        let radiusQuery = URLQueryItem(name: "radius", value: "10")
        let noCallBackQuery = URLQueryItem(name: "nojsoncallback", value: "1")
        let latitudeQuery = URLQueryItem(name: "lat", value: String(latitude))
        let longitudeQuery = URLQueryItem(name: "lon", value: String(longitude))
        //        let pageQuery = URLQueryItem(name: "page", value: String(page))
        
        components.queryItems = [endpointQuery, apiKeyQuery, latitudeQuery, longitudeQuery, formatQuery, radiusQuery, noCallBackQuery]
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: components.url!)
        
        _ = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    completion(nil, error?.localizedDescription)
                    return
            }
            
            let decoder = JSONDecoder()
            let responseObject = try! decoder.decode(JsonFlickrApi.self, from: data)
            
            DispatchQueue.main.async {
                let photos = Array(responseObject.photos.photo.shuffled().prefix(12))
                completion(photos, nil)
            }
        }.resume()
    }
    
    
        
        
        
//        URLSession.shared.dataTask(with: URL(string: photo.imageURL!)!) { (data, response, error) in
//
//            if error == nil {
//                DispatchQueue.main.async {
//                    self.photoImage.image = UIImage(data: data! as Data)
//                    self.saveImageDataToCoreData(photo, imageData: data! as Data)
//                }
//            }
//        }
//        .resume()

//        let downloadTask = URLSession.shared.downloadTask(with: request) {
//            urlOrNil, responseOrNil, errorOrNil in
//            // check for and handle errors:
//            // * errorOrNil should be nil
//            // * responseOrNil should be an HTTPURLResponse with statusCode in 200..<299
//
//            guard let fileURL = urlOrNil else { return }
//            do {
//                let documentsURL = try
//                    FileManager.default.url(for: .documentDirectory,
//                                            in: .userDomainMask,
//                                            appropriateFor: nil,
//                                            create: false)
//                let savedURL = documentsURL.appendingPathComponent(fileURL.lastPathComponent)
//                try FileManager.default.moveItem(at: fileURL, to: savedURL)
////                coreDataPhotoEntity.imageData =
//
//            } catch {
//                print ("file error: \(error)")
//            }
//        }
//        downloadTask.resume()
//    }
}
