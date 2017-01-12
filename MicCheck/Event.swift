//
//  Event.swift
//  MicCheck
//
//  Created by Eric Nash on 12/20/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import Foundation
import SwiftyJSON

class Event {
    
    let venue: String?
    let imgVenue: String?
    let urlVenue: String?
    let addressVenue: String?
    let distanceFromVenue: String?
    
    var eventHappeningTonight = false
    var urlEvent = ""
    let xPathUrlEvent: String?
    
    let testUrlEvent: String?
    let testArtist: String?
    let testImgArtist: String?
    let testPrice: String?
    
    var artist = ""
    let xPathArtist: String?
    
    var imgArtist: UIImage?
    let xPathImgArtist: String?
    var descriptionArtist: String?
    
    let vIDArtist: String?
    var vIDItems: Array<Dictionary<NSObject, AnyObject>> = []
    
    var price: String?
    let boolPriceShown: String?
    let xPathPrice: String?
    
    let date: String?
    let dateFormat: String?
    let xPathDate: String?
    
    
    init(Dictionary: NSDictionary) {
        
        // The immutable variables will contain the prerequisite data living in events.json
        // I'll use them to scrape the venue website and popoulate the variables
        
        venue                   = Dictionary["venue"]                   as? String
        imgVenue                = Dictionary["imgVenue"]                as? String
        urlVenue                = Dictionary["urlVenue"]                as? String
        addressVenue            = Dictionary["addressVenue"]            as? String
        distanceFromVenue       = Dictionary["distanceFromVenue"]       as? String
        
        xPathUrlEvent           = Dictionary["xPathUrlEvent"]           as? String
        
        testUrlEvent            = Dictionary["testUrlEvent"]            as? String
        testArtist              = Dictionary["testArtist"]              as? String
        testImgArtist           = Dictionary["testImgArtist"]           as? String
        testPrice               = Dictionary["testPrice"]               as? String
        
        
        xPathArtist             = Dictionary["xPathArtist"]             as? String
        xPathImgArtist          = Dictionary["xPathImgArtist"]          as? String
        descriptionArtist       = Dictionary["descriptionArtist"]       as? String
        vIDArtist               = Dictionary["vIDArtist"]               as? String
        
        
        boolPriceShown          = Dictionary["boolPriceShown"]          as? String
        xPathPrice              = Dictionary["xPathPrice"]              as? String
        date                    = Dictionary["date"]                    as? String
        dateFormat              = Dictionary["dateFormat"]              as? String
        xPathDate               = Dictionary["xPathDate"]               as? String
        
    }

    // MARK: YouTube API Functions
    func getVideosForArtist(completion: (() -> Void)!) {
        
//        print("   Event.swift - getVideosForArtist start")
        
        let apiKey = "AIzaSyABMIvminGXw9pQ_P1OsKxsO8aaNkvWBak"
        
        // Form the Request URL String
        var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(self.artist)+music+live&type=video&&maxResults=4&key=\(apiKey)"
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        // Create a URL Object using the string above
        let targetURL = URL(string: urlString)

        // Create the Async Request
        let task = URLSession.shared.dataTask(with: targetURL!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("   Event.swift - Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
//            print(json)
        
        }
        
        task.resume()
        
    }

    
}
