//
//  AccessoryViewController.swift
//  MyHome
//
//  Created by Benoit Briatte on 16/12/2021.
//

import UIKit
import HomeKit
import WatchConnectivity

class AccessoryViewController: UIViewController {
    var home: HMHome!
    var room: HMRoom!
    var accessories: [HMAccessory] = []
    @IBOutlet weak var seatCoverInput: UISwitch!
    @IBOutlet weak var fanInput: UISwitch!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var motionLabel: UILabel!
    
    var accessory: HMAccessory!
    
    class func newInstance(room: HMRoom, home: HMHome, accessory: HMAccessory) -> AccessoryViewController {
        let avc = AccessoryViewController()
        avc.room = room
        avc.home = home
        avc.accessory = accessory
        return avc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            let wcsession = WCSession.default
            wcsession.delegate = self
            wcsession.activate()
        }
        
        let session = WCSession.default
        print("session reachable ? : \(session.isReachable)")
        
        self.accessories = self.room.accessories
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            self.updateTemp()
            self.updateMotion()
            self.updateCurrentDoorState()
            self.updateFanState()
        }
        
        configureComponents()
    }
    
    func configureComponents() {
        view.setGradientBackground()
        
    }
    
    func getTempCharacteristic() -> HMCharacteristic? {
        for accessory in self.accessories {
            for service in accessory.services {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypeCurrentTemperature {
                        return characteristic
                    }
                }
            }
        }
        return nil
    }
    
    func getMotionDetection() -> HMCharacteristic? {
        for accessory in self.accessories {
            for service in accessory.services {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypeMotionDetected {
                        return characteristic
                    }
                }
            }
        }
        return nil
    }
    
    func getSeatCoverStatusCharacteristic() -> HMCharacteristic? {
        for accessory in self.accessories {
            for service in accessory.services {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypeCurrentDoorState {
                        return characteristic
                    }
                }
            }
        }
        return nil
    }
    
    
    func getFanCharacteristic() -> HMCharacteristic? {
        for accessory in self.accessories {
            for service in accessory.services {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypeActive {
                        return characteristic
                    }
                }
            }
        }
        return nil
    }
    
    func getTargetSeatCoverCharacteristic() -> HMCharacteristic? {
        for accessory in self.accessories {
            for service in accessory.services {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypeTargetDoorState {
                        return characteristic
                    }
                }
            }
        }
        return nil
    }
    
    func updateTemp() {
        guard let characteristicCurrentTemp = self.getTempCharacteristic() else {
            print("no temp characteristics")
            return
        }
        
        characteristicCurrentTemp.readValue { err in
            guard err == nil else {
                self.tempLabel.text = "Erreur capteur temp"
                return
            }
            guard let temp = characteristicCurrentTemp.value as? Double else {
                self.tempLabel.text = "404"
                return
            }
            
            if (WCSession.default.isReachable) {
                let message = ["temp": "\(temp)"]
                WCSession.default.sendMessage(message, replyHandler: nil)
            }
            
            self.tempLabel.textColor = .black
            self.tempLabel.text = "\(temp)°C"
        }
    }
    
    func updateMotion() {
        guard let characteristicMotion = self.getMotionDetection() else {
            print("no motion characteristics")
            return
        }
        characteristicMotion.readValue { err in
            guard err == nil else {
                self.motionLabel.text = "Erreur capteur motion"
                return
            }
            guard let isSitting = characteristicMotion.value as? Bool else {
                self.motionLabel.text = "erreur"
                return
            }
            
            if (WCSession.default.isReachable) {
                let message = ["isSitting": "\(isSitting)"]
                WCSession.default.sendMessage(message, replyHandler: nil)
            }
            
            self.motionLabel.textColor = .black
            
            if isSitting {
                self.motionLabel.text = "The throne is used"
            } else {
                self.motionLabel.text = "Free to use 🧻"
            }
        }
    }
    
    func updateCurrentDoorState() {
        guard let characteristicSeatCover = self.getSeatCoverStatusCharacteristic() else {
            print("no seat characteristics")
            return
        }
        characteristicSeatCover.readValue { err in
            guard err == nil else {
                self.seatCoverInput.isOn = false
                return
            }
            guard let isOn = characteristicSeatCover.value as? Bool else {
                self.seatCoverInput.isOn = false
                return
            }
            
            if (WCSession.default.isReachable) {
                let message = ["isOn": isOn]
                WCSession.default.sendMessage(message, replyHandler: nil)
            }
            self.seatCoverInput.isOn = isOn
        }
    }
    
    func updateFanState() {
        guard let characteristicFan = self.getFanCharacteristic() else {
            print("no fan characteristics")
            return
        }
        characteristicFan.readValue { err in
            guard err == nil else {
                self.fanInput.isOn = false
                return
            }
            guard let isOn = characteristicFan.value as? Bool else {
                self.fanInput.isOn = false
                return
            }
            print("fan isOn : \(isOn)")
            self.fanInput.isOn = isOn
        }
    }
    
    @IBAction func onSwitch(_ sender: UISwitch) {
        guard let characteristicTargetSeatCover = self.getTargetSeatCoverCharacteristic() else {
            print("no target seat characteristics")
            return
        }
        
        characteristicTargetSeatCover.writeValue(sender.isOn) { err in
            return
        }
        
    }
    
    @IBAction func onFanInputSwitch(_ sender: UISwitch) {
        guard let characteristicTargetSeatCover = self.getFanCharacteristic() else {
            print("no target seat characteristics")
            return
        }
        
        characteristicTargetSeatCover.writeValue(sender.isOn) { err in
            return
        }
    }
}

extension AccessoryViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let isOn = message["isOn"] as? Bool else {
            return
        }
        
        DispatchQueue.main.async {
            self.seatCoverInput.isOn = isOn
            self.onSwitch(self.seatCoverInput)
        }
    }
}
