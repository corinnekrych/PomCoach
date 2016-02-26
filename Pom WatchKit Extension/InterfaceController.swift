//
//  InterfaceController.swift
//  Pom WatchKit Extension
//
//  Created by Corinne Krych on 26/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var startButton: WKInterfaceButton!
    var isStarted: Bool!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        isStarted = false
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onStartButton() {
        isStarted = !isStarted
        if isStarted == true {
            //startButton.
        }
    }
}
