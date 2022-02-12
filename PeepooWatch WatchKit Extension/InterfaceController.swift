//
//  InterfaceController.swift
//  PeepooWatch WatchKit Extension
//
//  Created by Oudjama on 12/02/2022.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    
    
    @IBOutlet weak var seatCover: WKInterfaceSwitch!
    @IBOutlet weak var tempLabel: WKInterfaceLabel!
    @IBOutlet weak var isSomeoneSitting: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        
        print("watch is supported : \(WCSession.isSupported())")
        
        if WCSession.isSupported() {
            let wcsession = WCSession.default
            wcsession.delegate = self
            wcsession.activate()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    @IBAction func seatWriter(_ value: Bool) {
        if (WCSession.default.isReachable) {
            let message = ["isOn": value]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
    }
    
}




extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message.first?.key == "temp" {
            guard let temp = message["temp"] as? String else {
                return
            }
            self.tempLabel.setText(temp)
        } else if message.first?.key == "isSitting" {
            guard let isSitting = message["isSitting"] as? String else {
                return
            }
            self.isSomeoneSitting.setText(isSitting)
        } else {
            guard let isOn = message["isOn"] as? Bool else {
                return
            }
            self.seatCover.setOn(isOn)
        }
        
    }
}
