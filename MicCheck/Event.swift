//
//  Event.swift
//  MicCheck
//
//  Created by Eric Nash on 12/20/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIImageColors

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
    var strArtistVidImgUrls: Array<String> = []
    let xPathImgArtist: String?
    var descriptionArtist: String?
    
    let vIDArtist: String?
    var strVIDs: Array<String> = []
    
    var price: String?
    let boolPriceShown: String?
    let xPathPrice: String?
    
    let date: String?
    let dateFormat: String?
    let xPathDate: String?
    
    var colorsArtistimageColors: UIImageColors? = nil
    
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

    func getDescriptionForArtist(completionHandler: @escaping (String?, NSError?) -> Void ) -> Void {
        // if the artist description is already populated, then no need to run through the Wikipedia API
        if self.descriptionArtist != nil {
            print("   Event.swift - description already populated as \(self.descriptionArtist)")
            completionHandler(descriptionArtist, nil)
            return
        }
        
        var urlString = "https://en.wikipedia.org/w/api.php?action=opensearch&search=\(self.artist)&limit=1&format=json"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

        // Create a URL Object using the string above
        let targetURL = URL(string: urlString)
        
        // Create the Async Request
        let task = URLSession.shared.dataTask(with: targetURL!) { data, response, error in
            // check for any errors
            guard error == nil else {
                print(error!)
                completionHandler(nil, error as NSError?)
                return
            }
            // make sure we got data
            guard let data = data else {
                print("   Event.swift - Wikipedia data was not received")
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            let json = JSON(data: data)
            
            //Getting a string from JSON
            if let parsedDescription = json[2][0].string {
                
                self.descriptionArtist = parsedDescription
                //print("   Event.swift - descriptionArtist Added: \(self.descriptionArtist!)")
                
                completionHandler(self.descriptionArtist, nil)
                return
                
            } else {
                
                print("   Event.swift - Could not get the descriptionArtist from the Wikipedia JSON")
                return
                
            } // end if
            
        } // end URLSession.shared.dataTask completionHandler
        
        task.resume()
        return

    }
    
    
    
    // MARK: YouTube API Functions
    // Query the YouTube API to return the JSON blob of videos, then store these into an array within the Event
    
    func getVideosForArtist(completionHandler: @escaping (Array<String>?, NSError?) -> Void ) -> Void {
        
        // if the video IDs are already populated, then no need to run through the YouTube API
        guard strVIDs.isEmpty else {
            print("   Event.swift - strVIDs already populated")
            completionHandler(strVIDs, nil)
            return
        }        
        
        let apiKey = "AIzaSyABMIvminGXw9pQ_P1OsKxsO8aaNkvWBak"
        
        // Form the Request URL String
        var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(self.artist)+music+live&type=video&&maxResults=4&key=\(apiKey)"
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        // Create a URL Object using the string above
        let targetURL = URL(string: urlString)
        
        // Create the Async Request
        let task = URLSession.shared.dataTask(with: targetURL!) { data, response, error in
            // check for any errors
            guard error == nil else {
                print(error!)
                completionHandler(nil, error as NSError?)
                return
            }
            // make sure we got data
            guard let data = data else {
                print("   Event.swift - YouTube data was not received")
                return
            }

            // parse the result as JSON, since that's what the API provides
            let json = JSON(data: data)
            
            //Getting an array of string from a JSON Array
            
            if let items = json["items"].array {
                for item in items {
                    
                    // grab the videoIDs and store them in the Event
                    if let strVID = item["id"]["videoId"].string {
                        
                        self.strVIDs.append(strVID)
                        
                    } else {
                        
                        print("   Event.swift - Could not get the videoId string from the YouTube items array")
                        
                    } // end if
                    
                    // also grab the Artist video thumbs and store them in the event
                    if let strArtistVidImgUrl = item["snippet"]["thumbnails"]["high"]["url"].string {
                        
                        //print("strArtistVidImgUrl: \(strArtistVidImgUrl)")
                        self.strArtistVidImgUrls.append(strArtistVidImgUrl)
                        
                    } else {
                        
                        print("   Event.swift - Could not get the Artsit Video URLs from the YouTube items array")
                        
                    } // end if
                    
                } // end for statement

                print("   Event.swift - \(self.strVIDs.count) strVIDs Added ")
                
                completionHandler(self.strVIDs, nil)
                return
                
            } else {

                print("   Event.swift - Could not get the YouTube items array")
                return

            } // end if
            
        } // end URLSession.shared.dataTask completionHandler
        
        task.resume()
        return
    }

    func getColorsForArtistImage() -> UIImageColors? {
        
        // if the artist image colors are already populated, then no need to run through it again
        if self.colorsArtistimageColors != nil {
            //print("   Event.swift - getColorsForArtistImage() Already Populated \r\n")
            return colorsArtistimageColors
        }
        
        self.colorsArtistimageColors = self.imgArtist?.getColors()
        //print("   Event.swift – getColorsForArtistImage() Finished \r\n")
        
        return colorsArtistimageColors
        
    }
    
    
}
