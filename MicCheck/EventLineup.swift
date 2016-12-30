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
    
    // a singleton pattern I'm trying from: https://www.raywenderlich.com/86477/introducing-ios-design-patterns-in-swift-part-1
    class var sharedInstance: EventLineup {
        
        struct Singleton {
            
            // Declaring a property as static means this property only exists once
            static let instance = EventLineup()
            
        }
    
        return Singleton.instance
    }
    
    // a toggle for testing UI and interactions without making calls to external websites
    let testMode: Bool = false
    
    // Array for the Events.  They may be real Events or test events, depending on testMode
    var events: [Event] = []
    
    private init() {
        //I'm making the getTodaysEvents call in ModelController, but may move it to a ViewController later
        //self.getTodaysEvents()
    }
    
    func getTodaysEvents() {
        
        // print(" EventLineup.swift - getTodaysEvents() - start")
        // print(" = = = = = = = = = = = =")

        // MARK: Make an array of event nodes from the local JSON file
        guard let path = Bundle.main.path(forResource: "events", ofType: "json") else {
            print(" EventLineup.swift - Invalid filename/path. Stopping")
            return
        }
        guard let data = NSData(contentsOf: URL(fileURLWithPath: path)) as? Data else {
            print(" EventLineup.swift - Could not get data from the file.  Make sure there's data in the file")
            return
        }
        let json = JSON(data: data as Data)
        guard json != JSON.null else {
            print(" EventLineup.swift - Could not generate JSON from the data.  Make sure your syntax is correct")
            return
        }
        guard let jsonlineup = json["events"].array else {
            print(" EventLineup.swift – could not generate lineup array from JSON")
            return
        }
        
        // MARK: Use the jsonlineup array to generate a new array of intialized Event objects
        eventLoop: for currentEvent in jsonlineup {
            
            let eventDictionary: NSDictionary = currentEvent.object as! NSDictionary
            let event = Event(Dictionary: eventDictionary)
            events.append(event)
            
        }

        // MARK: Run back through the array to initialize each Event with real or test values, depending on testMode
        //       If we're using real values, then we'll need to remove some Events that aren't happening today
        //       It's cleaner to do removals from the bottom since the index don't change

        eventLoop: for (index, currentEvent) in self.events.enumerated().reversed() {

            print("\r\n - - - - - - - - - - - -")
            print(" \(currentEvent.venue!)")
            print(" \(currentEvent.urlVenue!)")
            
            if self.testMode == true {

                currentEvent.eventHappeningTonight = true
                currentEvent.urlEvent = jsonlineup[index]["testUrlEvent"].string!
                currentEvent.artist = jsonlineup[index]["testArtist"].string!
                currentEvent.imgArtist = UIImage(named: jsonlineup[index]["testImgArtist"].string!)
                currentEvent.price = jsonlineup[index]["testPrice"].string!
                
            } else {  // self.testMode == false
                
                // use the Venue URL to access the venue website and populate other areas
                guard let venueURLString = currentEvent.urlVenue else {
                    print(" EventLineup.swift – Could not get the URL String from the Event object. Going to next event.")
                    continue eventLoop
                }
                
                // make sure that the URL is valid
                guard let venueURL = NSURL(string: venueURLString) else {
                    print(" EventLineup.swift – \(venueURLString) URL is not a valid URL.  Going to next event.")
                    continue eventLoop
                }
                
                // make sure there's HTML returend by the URL.  
                // try? means that if the operation fails, the method returns an optional without a value. 
                // If it succeeds, the optional contains a value
                guard let venueHTMLString = try? String(contentsOf: venueURL as URL, encoding: String.Encoding.utf8) else {
                    print(" EventLineup.swift – \(venueURLString) is not a valid URL.  Going to next event.")
                    continue eventLoop
                }
                guard let doc = HTML(html: venueHTMLString, encoding: .utf8) else {
                    print(" EventLineup.swift – \(venueURLString) URL is not returning any HTML.  Going to next event.")
                    continue eventLoop
                }

                // Check the date of the venue's most recent upcoming event, 
                // if happening today, add it to events array,
                // otherwise, purge it from the events array
                let nodes = doc.xpath(currentEvent.xPathDate!)
                guard nodes.count > 0 else {
                    print(" EventLineup.swift – No date at xPath for \(venueURLString). Removing and going to next event")
                    self.events.remove(at: index)
                    continue eventLoop
                }
                
                for node in nodes {
                    
                    // create a trimmed version of the HTML String without any excess characters
                    print(" EventLineup.swift – Raw Date: \(node.text!)")
                    var trimmedStrEventDate = node.text!.replacingOccurrences(of: "\r\n", with: "")
                    trimmedStrEventDate = trimmedStrEventDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    print(" EventLineup.swift - Trim Date: \(trimmedStrEventDate)")
                    
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
                        }

                        // update the parsed date to the same date but with the correct calendar components
                        parsedDate = Calendar.current.date(from: parsedDateComponents) as Date!
                    }
                    
                    print(" EventLineup.swift - Parsed Date: \(eventDateFormatter.string(from: parsedDate))")

                    print(" EventLineup.swift - Today: \(eventDateFormatter.string(from: todayDate))")
                    
                    switch Calendar.current.compare(parsedDate, to: todayDate, toGranularity: .day) {
                    case .orderedAscending:
                        currentEvent.eventHappeningTonight = false
                        print(" EventLineup.swift - Past Event: \(eventDateFormatter.string(from: parsedDate))")
                    case .orderedDescending:
                        currentEvent.eventHappeningTonight = false
                        print(" EventLineup.swift - Future Event: \(eventDateFormatter.string(from: parsedDate))")
                    case .orderedSame:
                        currentEvent.eventHappeningTonight = true
                        print(" EventLineup.swift - Event Today: \(eventDateFormatter.string(from: parsedDate))")
                    }
                    
                    // remove the array items that aren't happening tonight
                    if (currentEvent.eventHappeningTonight == false) {
                        //print(" Event.swift - event not happening so removing \(index)")
                        self.events.remove(at: index)
                        continue eventLoop
                    }
                    
                } // end for node loop

                
                // Event is happening today, so populate from website

                
                
                
            } // end testMode conditional
            
        } // end eventLoop
        
    } // end getTodaysEvents()

}
