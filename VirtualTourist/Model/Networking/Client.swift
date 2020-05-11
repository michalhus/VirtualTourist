//
//  Client.swift
//  VirtualTourist
//
//  Created by Michal Hus on 5/7/20.
//  Copyright © 2020 Michal Hus. All rights reserved.
//

import Foundation

class Client {
    
    let base = "https://www.flickr.com/services/rest/"
    let apiKey = "07791be27ed201d33cfff3bdf4c45266"
    let locationPhotosEndpoint = "flickr.photos.search"
    
    func getLocationPhotos(latitude: Double, longitude: Double, completion: @escaping ([String: Any]?, String?) -> Void )  {
        
        guard var components = URLComponents(string: base) else {
            completion(nil, nil)
            return
        }
        
        let endpointQuery = URLQueryItem(name: "method", value: locationPhotosEndpoint)
        let apiKeyQuery = URLQueryItem(name: "api_key", value: apiKey)
        let latitudeQuery = URLQueryItem(name: "lat", value: String(latitude))
        let longitudeQuery = URLQueryItem(name: "lon", value: String(longitude))
        let formatQuery = URLQueryItem(name: "format", value: "json")
        
        components.queryItems = [endpointQuery, apiKeyQuery, latitudeQuery, longitudeQuery, formatQuery]

        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
               let request = URLRequest(url: components.url!)

               let task = URLSession.shared.dataTask(with: request) { data, response, error in
                   guard let data = data,                            // is there data
                       let response = response as? HTTPURLResponse,  // is there HTTP response
                       (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                       error == nil else {                           // was there no error, otherwise ...
                        completion(nil, error?.localizedDescription)
                           return
                   }
                   let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                   completion(responseObject, nil)
               }
               task.resume()        
    }
    
        
//        https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
        
//        [{"id":"49867047867","owner":"94246031@N00","secret":"43d016d680","server":"65535","farm":66,"title":"","ispublic":1,"isfriend":0,"isfamily":0},
        
}
