//
//  DataViewController.swift
//  MicCheck
//
//  Created by Eric Nash on 12/20/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var imgArtist: UIImageView!
    
    var dataObject: String = ""
    var dataImgArtist: UIImage!
    //    var dataObject: Event?
//    var dataArtist: String = ""
    
//        let lineUp = EventLineup.sharedInstance
//        var dataObject: Event = EventLineup.sharedInstance.events
//    var dataObject:
//    var dataObjectArtists: [String] = EventLineup.sharedInstance.events.ar
    
//    let lineUp = EventLineup.sharedInstance
//    var dataObject: Event = EventLineup.sharedInstance.events[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel.text = dataObject
        //        self.dataLabel!.text = dataArtist
//        self.dataLabel!.text = dataObject
//        self.dataImgArtist.image
//                self.imgArtist.image = dataObject.imgArtist
        self.imgArtist.image =  dataImgArtist
    }


}

