//
//  EventLineup.swift
//  MicCheck
//
//  Created by Eric Nash on 12/20/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import Foundation
import Kanna
import SwiftyJSON

class EventLineup {
    
    static let sharedInstance = EventLineup()
    
    // a toggle for testing UIvard interactions without making calls to external websites
    let testMode: Bool = false
    
    // Array for the Events.  They may be real Events or test events, depending on testMode
    var events: [Event] = []
    
    private init() {
        self.getVenueList()
    }

    // MARK: Populate events array with Event objects initialized from values in a local JSON file.
    //       I had originally combined this with the filterTodaysEvents in the same function, 
    //       but splitting them in two was the only way I could make it work with multithreading.
    
    func getVenueList() {
        
        guard let path = Bundle.main.path(forResource: "events", ofType: "json") else {
            print("  EventLineup.swift - Invalid filename/path. Stopping")
            return
        } // end guard
        
        guard let data = NSData(contentsOf: URL(fileURLWithPath: path)) as Data? else {
            print("  EventLineup.swift - Could not get data from the file.  Make sure there's data in the file")
            return
        } // end guard
        
        let json = try? JSON(data: data as Data)
        
        guard json != JSON.null else {
            print("  EventLineup.swift - Could not generate JSON from the data.  Make sure your syntax is correct")
            return
        } // end guard
        
        guard let jsonlineup = json!["events"].array else {
            print("  EventLineup.swift – could not generate lineup array from JSON")
            return
        } // end guard

        eventLoop: for (index, currentEvent) in jsonlineup.enumerated() {
            let eventDictionary: NSDictionary = currentEvent.object as! NSDictionary
            let event = Event(Dictionary: eventDictionary)
            event.eventHappeningTonight = true
            event.urlEvent = jsonlineup[index]["testUrlEvent"].string!
            event.artist = jsonlineup[index]["testArtist"].string!
            event.descriptionArtist = jsonlineup[index]["testArtistDescription"].string!
            event.imgArtist = UIImage(named: jsonlineup[index]["testImgArtist"].string!)
            event.price = jsonlineup[index]["testPrice"].string!
            events.append(event)
        } // end eventLoop

        print("  EventLineup.swift - Finished getVenueList() \r\n")
        
    } // end getVenueList()


    
    // MARK: Run back through the array to initialize each Event with real or test values, depending on testMode
    //       If we're using real values, then we'll need to remove some Events that aren't happening today
    
    func filterTodaysEvents() {
        // if testMode is true, then there's no need to do more processessing
        guard (testMode == false) else {

            print("  EventLineup.swift - filterTodaysEvents() - In Test Mode...No Filtering")
            print("  = = = = = = = = = = = =")
            
            return
        } // end guard

        print("  EventLineup.swift - Starting filterTodaysEvents()")
        
        // It's cleaner to do removals from the bottom since the index don't change
        eventLoop: for (index, currentEvent) in self.events.enumerated().reversed() {
            
            print("\r\n  - - - - - - - - - - - -")
            print("  \(currentEvent.venue!)")
            print("  \(currentEvent.urlVenue!)")
            
            // use the Venue URL to access the venue website and populate other areas
            guard let venueURLString = currentEvent.urlVenue else {
                print("  EventLineup.swift – Could not get the URL String from the Event object. Going to next event.")
                continue eventLoop
            } // end guard
            
            // make sure that the URL is valid
            guard let venueURL = NSURL(string: venueURLString) else {
                print("  EventLineup.swift – \(venueURLString) URL is not a valid URL.  Going to next event.")
                continue eventLoop
            } // end guard
            
            // make sure there's HTML returend by the URL.  
            // try? means that if the operation fails, the method returns an optional without a value. 
            // If it succeeds, the optional contains a value
            guard let venueHTMLString = try? String(contentsOf: venueURL as URL, encoding: String.Encoding.utf8) else {
                print("  EventLineup.swift – \(venueURLString) is not a valid URL.  Going to next event.")
                continue eventLoop
            } // end guard
            
            guard let doc = try? HTML(html: venueHTMLString, encoding: .utf8) else {
                print("  EventLineup.swift – \(venueURLString) URL is not returning any HTML.  Going to next event.")
                continue eventLoop
            } // end guard

            // Check the date of the venue's most recent upcoming event, 
            // if happening today, add it to events array,
            // otherwise, purge it from the events array
            let nodeDates = doc.xpath(currentEvent.xPathDate!)
            guard nodeDates.count > 0 else {
                print("  EventLineup.swift – No date at xPath for \(venueURLString). Removing and going to next event")
                self.events.remove(at: index)
                continue eventLoop
            }
            
            for nodeDate in nodeDates {
                // create a trimmed version of the HTML String without any excess characters
                // print(" EventLineup.swift – Raw Date: \(dateNode.text!)")
                var trimmedStrEventDate = nodeDate.text!.replacingOccurrences(of: "\r\n", with: "")
                trimmedStrEventDate = trimmedStrEventDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                // print(" EventLineup.swift - Trim Date: \(trimmedStrEventDate)")
                
                // parse an actual Date from the trimmed String
                let eventDateFormatter = DateFormatter()
                eventDateFormatter.dateFormat = currentEvent.dateFormat
                var parsedDate = eventDateFormatter.date(from: trimmedStrEventDate)! as Date
                // print(" EventLineup.swift - Parsed Date: \(parsedDate)")
                
                // pull out the day, month, and year components from the parsed date
                var parsedDateComponents = Calendar.current.dateComponents([.day , .month , .year], from: parsedDate)
                
                // pull out the day, month, and year components from today's date
                let todayDate = Date()
                let todayDateComponents = Calendar.current.dateComponents([.day , .month , .year], from: todayDate)
                
                // if year is not specified in HTML (e.g., 12/30), it will set to '2000' so need to update it
                if (parsedDateComponents.year! < todayDateComponents.year!) {
                    if (parsedDateComponents.month! < todayDateComponents.month!) {
                        let parsedDateWithNewYear = Calendar.current.date(byAdding: .year, value: 1, to: todayDate)
                        parsedDate = parsedDateWithNewYear!
                    } else { // equal months or parsed month comes after today's month
                        parsedDateComponents.year = todayDateComponents.year
                    } // end else

                    // update the parsed date to the same date but with the correct calendar components
                    parsedDate = Calendar.current.date(from: parsedDateComponents) as Date!
                } // end if
                
                // print(" EventLineup.swift - Parsed Date: \(eventDateFormatter.string(from: parsedDate))")
                // print(" EventLineup.swift - Today: \(eventDateFormatter.string(from: todayDate))")
                
                switch Calendar.current.compare(parsedDate, to: todayDate, toGranularity: .day) {
                case .orderedAscending:
                    currentEvent.eventHappeningTonight = false
                    print("  EventLineup.swift - Past Event: \(eventDateFormatter.string(from: parsedDate))")
                case .orderedDescending:
                    currentEvent.eventHappeningTonight = false
                    print("  EventLineup.swift - Future Event: \(eventDateFormatter.string(from: parsedDate))")
                case .orderedSame:
                    currentEvent.eventHappeningTonight = true
                    print("  EventLineup.swift - Event Today: \(eventDateFormatter.string(from: parsedDate))")
                } // end switch
                
                // remove the array items that aren't happening tonight
                if (currentEvent.eventHappeningTonight == false) {
                    //print(" Event.swift - event not happening so removing \(index)")
                    self.events.remove(at: index)
                    continue eventLoop
                } // end if
            } // end for node loop
            
            // Event is happening today, so populate from website
            // **************************************************
            
            // MARK: Add Artist Name
            // **************************************************
            let nodeArtists = doc.xpath(currentEvent.xPathArtist!)
            guard nodeArtists.count > 0 else {
                print("  EventLineup.swift – No artist at xPath for \(venueURLString). Removing and going to next event")
                self.events.remove(at: index)
                continue eventLoop
            } // end guard
            
            for nodeArtist in nodeArtists {
                // remove whitespace characters
                var trimmedStrArtist = nodeArtist.text!.replacingOccurrences(of: "\r\n", with: "")
                trimmedStrArtist = nodeArtist.text!.replacingOccurrences(of: "\n", with: "")
                trimmedStrArtist = trimmedStrArtist.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                currentEvent.artist = trimmedStrArtist
                print("\r\n  \(trimmedStrArtist)")
            } // end for

            // MARK: Add Event URL
            // **************************************************
            let nodeUrlEvents = doc.xpath(currentEvent.xPathUrlEvent!)
            if nodeUrlEvents.count == 0 {
                currentEvent.urlEvent = "http://www.google.com/#q=" + currentEvent.artist
                print("  EventLineup.swift – No event page at xPath for \(venueURLString). Using Google search instead")
            } else {

                for nodeUrlEvent in nodeUrlEvents {
                    // check for valid Event URLs
                    let urlEvent = NSURL(string: nodeUrlEvent.text!)
                    let strEvent = urlEvent?.absoluteString

                    // var eventUrlData = NSData(contentsOf: eventUrl!) as? Data
                    // eventStrUrl = makeVerifiedURL(urlString: eventStrUrl!)

                    if let verifiedStrEvent = makeVerifiedUrl(strPathUrl: strEvent, strVenueUrl: currentEvent.urlVenue) {
                        currentEvent.urlEvent = verifiedStrEvent
                    } else {
                        let fallback = "http://www.google.com/#q=" + currentEvent.artist
                        currentEvent.urlEvent = fallback
                    } // end else
                    
                    print("  EventLineup.swift – currentEvent.urlEvent = \(currentEvent.urlEvent)")
                } // end for nodeUrlEvent
                
            } // end else

            // MARK: Add Artist Image
            // **************************************************
            
            let nodeUrlImgArtists = doc.xpath(currentEvent.xPathImgArtist!)

            if (nodeUrlImgArtists.count == 0) {
                currentEvent.imgArtist = UIImage(named: "image.not.available")!
                print(" EventLineup.swift – Could not fetch Artist Image")
            } else {
                for nodeUrlImgArtist in nodeUrlImgArtists {
                    
                    // check for valid Event URLs
                    let urlImgArtist = NSURL(string: nodeUrlImgArtist.text!)
                    let strImgArtist = urlImgArtist?.absoluteString
                    
                    // var eventUrlData = NSData(contentsOf: eventUrl!) as? Data
                    // eventStrUrl = makeVerifiedURL(urlString: eventStrUrl!)
                    
                    if var verifiedStrImgArtist = makeVerifiedUrl(strPathUrl: strImgArtist, strVenueUrl: currentEvent.urlVenue) {

                        // get larger version of image if a small one has been provided
                        if verifiedStrImgArtist.range(of: "atsm.") != nil {
                            verifiedStrImgArtist = verifiedStrImgArtist.replacingOccurrences(of: "atsm.", with: "atlg.")
                        }                            
                        
                        let verifiedUrlImgArtist = URL(string: verifiedStrImgArtist)
                        let dataImgArtist = NSData(contentsOf: verifiedUrlImgArtist! as URL)
                        let imgArtist = UIImage(data: dataImgArtist! as Data)
                        currentEvent.imgArtist = imgArtist!
                            
                        print("  EventLineup.swift – currentEvent.imgArtist = \(verifiedStrImgArtist)")
                        
                    } else {
                        currentEvent.imgArtist = UIImage(named: "image.not.available")!
                        print("  EventLineup.swift – Verified Image Not Available")
                    } // end else
                    
                } // end for nodeUrlImgArtist
                
            } // end urlImgArtistNodes conditional
            
            
            // MARK: Add Price
            // **************************************************
            guard (currentEvent.boolPriceShown == "true") else {
                currentEvent.price = ""
                print("  EventLineup.swift – Price not shown on this site.  Going to next event.")
                continue eventLoop
            } // end guard
            
            let nodePrices = doc.xpath(currentEvent.xPathPrice!)
            
            if (nodePrices.count == 0) {
                currentEvent.price = ""
                print("  EventLineup.swift – Could not fetch price.  Going to next event.")
                continue eventLoop
            } else {
                for nodePrice in nodePrices {
                    // remove whitespace characters
                    var trimmedStrPrice = nodePrice.text!.replacingOccurrences(of: "\n", with: "")
                    trimmedStrPrice = nodePrice.text!.replacingOccurrences(of: "Tickets", with: "")
                    trimmedStrPrice = nodePrice.text!.replacingOccurrences(of: ".00", with: "")
                    trimmedStrPrice = trimmedStrPrice.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    currentEvent.price = trimmedStrPrice
                    
                    print("  EventLineup.swift – currentEvent.price = \(trimmedStrPrice)")
                } // end for
            } // end else
            
        } // end eventLoop


        // MARK: No Events Today
        // **************************************************
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

        print("  EventLineup.swift - filterTodaysEvents() Finished")
        print("\r\n  = = = = = = = = = = = =\r\n")
        
    } // end getTodaysEvents()


    // MARK: Getting Colors
    // **************************************************
    func getColorsForArtistImages() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            for event in self.events {
                
                if event.colorsFromArtistImage == nil {
                    
                    event.colorsFromArtistImage = event.getColorsForArtistImage()
                    //print("  EventLineup.swift – getColorsForArtistImages() Run for: \(event.artist)")
                    
                } // end if
                
            } // end for
            
            print("  EventLineup.swift – getColorsForArtistImages() Finished \r\n ")
            
        } // end Dispatch.global
        
    }

    // MARK: Getting Descriptions
    // **************************************************
    func getArtistDescriptions() {

        // create a separate thread to chug through and populate the artist descriptions
        DispatchQueue.global(qos: .userInitiated).async {
            
            for event in self.events {
                                    
                event.descriptionArtist = event.getArtistDescription(testMode: self.testMode)
                
            } // end for
            
            print("  EventLineup.swift – getArtistDescriptions() Finished \r\n ")
            
        } // end Dispatch.global
    
        return
    }
    
    // MARK: Verfied URLs
    // **************************************************
    func makeVerifiedUrl(strPathUrl: String?, strVenueUrl: String?) -> String? {
        
        // Check the URL to see if it's valid, as is
        if verifyUrl(urlString: strPathUrl!) {
            return strPathUrl!
        } else {
            // not valid URL, so we need to construct one
            var strCandidate: String?
            if (strPathUrl!.range(of: "//") != nil) {
                // a double slash means we just add protocol prefix
                strCandidate = "http:" + strPathUrl!
            } else {
                // no double slash, so it's relative path; use venue website to contstruct absolute path
                // example: /event/1315901-nye-bonobo-dj-set-plus-san-francisco/
                strCandidate = strVenueUrl! + strPathUrl!
            } // end else

            if verifyUrl(urlString: strCandidate) {
                return strCandidate
            }  // end if

            return nil
        } // end else
        
    }  // end makeVerifiedURL

    func verifyUrl(urlString: String?) -> Bool {

        let url = URL(string: urlString!)
        if urlString != nil {
            // create NSURL instance
            if (NSData(contentsOf: url!) as Data?) != nil  {
                // check if your application can open the NSURL instance
                return true
            }
        } // end if

        return false

    } // end verifyUrl
    
}
