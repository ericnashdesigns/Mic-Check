//
//  Event.swift
//  MicCheck
//
//  Created by Eric Nash on 12/20/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import Foundation
import Kanna
import SwiftyJSON

class LineUp {
    
    static let sharedInstance = LineUp()
    
    let testMode: Bool = false
    
    var events: [Event] = []
    
    private init() {
        self.loadVenuesFromJSON()
    }
    
    
    func loadVenuesFromJSON() {
        
        // MARK: Create Array of Event objects from eventlist.json and load in test data
        // print(" Event.swift - loadVenuesFromJSON() - start")
        // print(" = = = = = = = = = = = =")
        
        
        if let path = Bundle.main.path(forResource: "events", ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                let json = JSON(data: data as Data, options: JSONSerialization.ReadingOptions.allowFragments, error: nil)
                
                if let lineup = json["events"].array {
                    
                    eventLoop: for currentEvent in lineup {
                        //print(" Event.swift - populating currentEvent in lineup")
                        
                        let eventDictionary: NSDictionary = currentEvent.object as! NSDictionary
                        
                        let event = Event(Dictionary: eventDictionary)
                        event.eventHappeningTonight = true
                        event.urlEvent = event.testUrlEvent!
                        event.artist = event.testArtist!
                        event.imgArtist = UIImage(named: event.testImgArtist!)
                        event.price = event.testPrice!
                        
                        //print(" = = = = = = = =")
                        //print(event.urlEvent)
                        //print(event.artist)
                        //print(event.price)
                        
                        events.append(event)
                        
                    }
                    
                } else {
                    print(" Events.swift – could not create lineup array from data")
                }
                
            } else {
                print(" Events.swift – could not create data from path")
            }
        } else {
            print(" Events.swift – could not create path")
        }
        
        print("\r\n Event.swift - loadVenuesFromJSON() - completed")
    }
    
    
    func filterTodaysEvents() {
        
        // MARK: Remove items from the Array of Event objects if the event date on the website isn't today
        print("\r\n Event.swift - filterTodaysEvents() - start")
        
        // Since I'm removing items from the array, go in reverse so that indexes won't shift
        eventLoop: for (index, currentEvent) in self.events.enumerated().reversed() {
            
            print("\r\n - - - - - - - - - - - -")
            print(" \(currentEvent.venue!)")
            
            // use the Venue URL in the JSON File to access the venue website and populate other areas
            let venueURLString = currentEvent.urlVenue
            let venueURL = NSURL(string: venueURLString!)
            var venueHTMLString: String?
            do {
                venueHTMLString = try String(contentsOfURL: venueURL!, encoding: String.Encoding.utf8)
            } catch {
                venueHTMLString = nil
                print(" \(venueURLString!) URL is not returning anything.  Going to next event.")
                continue eventLoop
            }
            
            //
            //            guard let venueHTMLString = try String(contentsOfURL: venueURL!, encoding: NSUTF8StringEncoding) else {
            //                print(" \(venueURLString!) URL is not returning anything.  Going to next event.")
            //                continue eventLoop
            //            }
            
            if let doc = Kanna.HTML(html: venueHTMLString!, encoding: String.Encoding.utf8) {
                
                // Check the date of the venue's event, if happening today add it to events array, otherwise
                var nodes = doc.xpath(currentEvent.xPathDate!)
                if (nodes.count > 0) { // make sure there is an image
                    for node in nodes {
                        
                        // pull out the components from the string and make them a parsed date
                        var trimmedStrEventDate = node.text!.stringByReplacingOccurrencesOfString("\r\n", withString: "", options: NSString.CompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        trimmedStrEventDate = trimmedStrEventDate.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        //print(" Event.swift - Trim Date : \(trimmedStrEventDate)")
                        
                        let eventDateFormatter = DateFormatter()
                        eventDateFormatter.dateFormat = currentEvent.dateFormat
                        eventDateFormatter.dateFromString(trimmedStrEventDate)
                        var parsedDate = eventDateFormatter.dateFromString(trimmedStrEventDate) as NSDate!
                        
                        // use the parsed date to create calandar components
                        let calendar = NSCalendar.current
                        let parsedDateComponents = calendar.components([.Day , .Month , .Year], fromDate: parsedDate)
                        
                        // update the calendar components year to the current year
                        let todayDate = NSDate()
                        let todayDateComponents = calendar.components([.Day , .Month , .Year], fromDate: todayDate)
                        parsedDateComponents.year = todayDateComponents.year
                        
                        // reset the parsed date to the same date but with the correct calendar components
                        parsedDate = calendar.dateFromComponents(parsedDateComponents) as NSDate!
                        //print(" Event.swift - Event Date: \(eventDateFormatter.stringFromDate(parsedDate))")
                        
                        // if the event date doesn't match up with todays date, just loop to the next event
                        let order = NSCalendar.currentCalendar().compareDate(todayDate, toDate: parsedDate,
                                                                             toUnitGranularity: .Day)
                        switch order {
                        case .OrderedDescending:
                            currentEvent.eventHappeningTonight = false
                            print(" Last Event: \(eventDateFormatter.stringFromDate(parsedDate))")
                        case .OrderedAscending:
                            currentEvent.eventHappeningTonight = false
                            print(" Future Event: \(eventDateFormatter.stringFromDate(parsedDate))")
                        case .OrderedSame:
                            currentEvent.eventHappeningTonight = true
                            print(" Event Today: \(eventDateFormatter.stringFromDate(parsedDate))")
                        }
                        
                        // remove the array items that aren't happening tonight
                        if (currentEvent.eventHappeningTonight == false) {
                            //print(" Event.swift - event not happening so removing \(index)")
                            self.events.remove(at: index)
                            continue eventLoop
                        }
                        
                    }
                } else {
                    //currentEvent.artist = "Artist Unknown"
                    print(" Event.swift – xPath could not select date for this event, removing it and skipping to next event")
                    self.events.remove(at: index)
                    continue eventLoop
                }
                
                
                // Event is happening today, so populate from website
                
                // Add Artist Name to the Event
                nodes = doc.xpath(currentEvent.xPathArtist!)
                if (nodes.count > 0) { // make sure there was an artist
                    for node in nodes {
                        // remove whitespace characters
                        var trimmedString = node.text!.stringByReplacingOccurrencesOfString("\r\n", withString: "", options: NSString.CompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        trimmedString = trimmedString.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        currentEvent.artist = trimmedString
                        print("\r\n \(trimmedString)")
                    }
                } else {
                    currentEvent.artist = "Artist Not Available"
                    print(" Could not fetch Artist")
                }
                
                
                
                // Add URL for Event to the Event
                nodes = doc.xpath(currentEvent.xPathUrlEvent!)
                if (nodes.count > 0) { // make sure there was an event url
                    for node in nodes {
                        
                        let event_url = NSURL(string: node.text!)
                        var event_url_string = event_url?.absoluteString
                        let event_data = NSData(contentsOf: event_url! as URL)
                        
                        // if URL is fine as is, then go ahead and set it in the event
                        if ((event_data) != nil) {
                            
                            currentEvent.urlEvent = node.text!
                            
                        } else {
                            
                            // add protocol prefix if there double slash has been provided
                            if (event_url_string!.rangeOfString("//") != nil) {
                                
                                event_url_string = "http:" + event_url_string!
                                currentEvent.urlEvent = event_url_string!
                                
                                // double slash not provided, so it's relative path and venue website prefix should be added
                            } else {
                                
                                currentEvent.urlEvent = currentEvent.urlVenue! + event_url_string!
                                
                            }
                            
                            // if it still doesn't work then default to event not available
                            if let _ = NSURL(string: currentEvent.urlEvent) {
                                
                            } else {
                                currentEvent.urlEvent = "http://www.google.com/#q=" + currentEvent.artist
                                print(" Could not fetch Event Detail Page")
                            }
                            
                        }
                        
                        print(" \(currentEvent.urlEvent)")
                        
                    }
                } else {
                    currentEvent.urlEvent = "http://www.google.com/#q=" + currentEvent.artist
                    print(" Could not fetch Event Detail Page")
                }
                
                
                
                // Add Artist Image to the Event
                nodes = doc.xpath(currentEvent.xPathImgArtist!)
                if (nodes.count > 0) { // make sure there is an image
                    for node in nodes {
                        //print(node.text!)
                        
                        
                        var image_url = NSURL(string: node.text!)
                        var image_url_string = image_url?.absoluteString
                        var image_data = NSData(contentsOf: image_url! as URL)
                        if ((image_data) != nil) {
                            let image = UIImage(data: image_data! as Data)
                            currentEvent.imgArtist = image!
                        } else  {
                            
                            // add protocol prefix if there double slash has been provided
                            if (image_url_string!.rangeOfString("//") != nil) {
                                image_url_string = "http:" + image_url_string!
                                image_url = NSURL(string: image_url_string!)
                                image_data = NSData(contentsOf: image_url! as URL)
                                
                                // double slash not provided, so it's relative path and venue website prefix should be added
                            } else {
                                
                                let image_url_string_full = currentEvent.urlVenue
                                let part_to_clip = image_url_string_full!.rangeOfString("/", options: .BackwardsSearch)?.startIndex
                                let image_url_string_remainder = image_url_string_full!.substringToIndex(part_to_clip!)
                                
                                image_url_string = image_url_string_remainder + "/" + image_url_string!
                                image_url = NSURL(string: image_url_string!)
                                image_data = NSData(contentsOf: image_url! as URL)
                            }
                            
                            
                            // get larger version of image if a small one has been provided
                            if (image_url_string!.rangeOfString("atsm.") != nil) {
                                image_url_string = image_url_string!.stringByReplacingOccurrencesOfString("atsm.", withString: "atlg.", options: NSString.CompareOptions.LiteralSearch, range: nil)
                                image_url = NSURL(string: image_url_string!)
                                image_data = NSData(contentsOf: image_url! as URL)
                            }
                            
                            // if event URL is facebook, then go scrape that page for the better image
                            if currentEvent.urlEvent.rangeOfString("facebook.com") != nil {
                                
                                print(" there is a facebook pic for \(currentEvent.urlEvent)")
                                
                                
                            }
                            
                            if ((image_data) != nil) {
                                let image = UIImage(data: image_data! as Data)
                                currentEvent.imgArtist = image!
                            } else {
                                // if it still doesn't work then default to image not available
                                currentEvent.imgArtist = UIImage(named: "image.not.available")!
                            }
                            
                        }
                        
                        print(" \(image_url_string!)")
                        //print("the image is \(event.imgArtist?.size.width) x \(event.imgArtist?.size.height)")
                        
                    }
                } else {
                    currentEvent.imgArtist = UIImage(named: "image.not.available")!
                    print(" Could not fetch Artist Image")
                }
                
                
                
                // Add Price to the Event
                if (currentEvent.boolPriceShown == "true") {
                    nodes = doc.xpath(currentEvent.xPathPrice!)
                    
                    if (nodes.count > 0) { // make sure there is an image
                        for node in nodes {
                            // remove whitespace characters
                            var trimmedString = node.text!.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSString.CompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                            trimmedString = trimmedString.stringByReplacingOccurrencesOfString("Tickets ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            
                            trimmedString = trimmedString.stringByReplacingOccurrencesOfString(".00", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            
                            if trimmedString.rangeOfString("$") == nil{
                                //trimmedString = "Price Not Given"
                            }
                            
                            currentEvent.price = trimmedString
                            print(" \(trimmedString)")
                        }
                    } else {
                        currentEvent.price = ""
                        print(" Event.swift – Could not fetch Price")
                    }
                    
                } else {
                    currentEvent.price = ""
                    print(" Event.swift – Price not shown on this site")
                }
                
            }
            
        }
        
        print(" Event.swift - filterTodaysEvents() - end with \(self.events.count) items")
        
        // if there's no events after going through the array, then just create a single blank event row to display
        // this will push the footer down to the bottom of the page and looks better
        if self.events.count == 0 {
            
            let blankDictionary = ["venue": "noVenuesToday"] // venue is immutable, so I cant' set it like the others below
            let event = Event(Dictionary: blankDictionary as NSDictionary)
            event.artist = ""
            event.imgArtist = nil
            event.price = ""
            
            events.append(event)
            
        }
        
    }
    
}


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
    
    let vIDArtist: String?
    var vIDItems: Array<Dictionary<NSObject, AnyObject>> = []
    
    var price: String?
    let boolPriceShown: String?
    let xPathPrice: String?
    
    let date: String?
    let dateFormat: String?
    let xPathDate: String?
    
    
    init(Dictionary: NSDictionary) {
        
        // These variables will contain the prerequisite data living in events.json
        // With it, I'll scrape the venue website and popoulate the other variables
        
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
        vIDArtist               = Dictionary["vIDArtist"]               as? String
        
        
        boolPriceShown          = Dictionary["boolPriceShown"]          as? String
        xPathPrice              = Dictionary["xPathPrice"]              as? String
        date                    = Dictionary["date"]                    as? String
        dateFormat              = Dictionary["dateFormat"]              as? String
        xPathDate               = Dictionary["xPathDate"]               as? String
        
    }
    
    
    
    // MARK: YouTube API Functions
    func getVideosForArtist(completion: (() -> Void)!) {
        
        print("   Event.swift - getVideosForArtist start")
        
        let apiKey = "AIzaSyABMIvminGXw9pQ_P1OsKxsO8aaNkvWBak"
        
        // Form the Request URL String
        var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(self.artist)+music+live&type=video&&maxResults=4&key=\(apiKey)"
        //print(urlString)
        
        urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        // Create an NSURL Object using the string above
        let targetURL = NSURL(string: urlString)
        
        //print("   Event.swift - getVideosForArtst - performGetRequest start for \(self.artist)")
        performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {  // ensure there’s JSON data by checking HTTP code and error object
                
                // Convert the JSON Data to a Dictionary using the Swift 2.0 error handling system
                do {
                    if let resultsDict = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? NSDictionary {
                        //                        print(resultsDict)
                        
                        // Get all search result items ("items" array).
                        let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
                        
                        // Use a loop to go through all video items.
                        for i in 0 ..< items.count {
                            let snippetDict = items[i]["snippet"] as! Dictionary<NSObject, AnyObject>
                            
                            var videoDetailsDict = Dictionary<NSObject, AnyObject>()
                            videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                            videoDetailsDict["videoID"] = (items[i]["id"] as! Dictionary<NSObject, AnyObject>)["videoId"]
                            
                            // append the desiredPlaylistItemDataDict dictionary to the videos array
                            //tempVIDItems.append(videoDetailsDict)
                            //print("\(self.artist) \(videoDetailsDict["thumbnail"])")
                            self.vIDItems.append(videoDetailsDict)
                            //print("   Event.swift - getVideosForArtist() – the videoID for \(self.artist) is \(self.vIDItems[i]["videoID"]!)")
                        }
                        
                        //print("   Event.swift – getVideosForArtist() - the videoID count for \(self.artist) is \(self.vIDItems.count)")
                        
                        // run the completion handler specified in DataViewController to load the new videos into the UI
                        completion()
                        
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            } else {    // HTTP status code is other than 200, or an error has occurred
                print(" HTTP Status Code = \(HTTPStatusCode)")
                print(" Error while loading the channel details \(error)")
                
            }
            
            // Hide the activity indicator.
            //self.viewWait.hidden = true
            
        })
        
        //print("   Event.swift - getVideosForArtst - end for \(self.artist)")
        
    }
    
    // Create the Request
    func performGetRequest(targetURL: NSURL!, completion: @escaping (_ data: NSData?, _ HTTPStatusCode: Int, _ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: targetURL as URL)
        request.httpMethod = "GET"
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfiguration)
        
        let task = session.dataTaskWithRequest(request as URLRequest, completionHandler: { (data: NSData?, response: URLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data, (response as! HTTPURLResponse).statusCode, error)
            })
        })
        
        task.resume()
        
    }
    
    
}
