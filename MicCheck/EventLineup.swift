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
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = JSON(data: data)
                if jsonObj != JSON.null {
                    print("jsonData:\(jsonObj)")
                } else {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
        
    }

}
