//
//  AccessoryViewController.swift
//  MyHome
//
//  Created by Benoit Briatte on 16/12/2021.
//

import UIKit
import HomeKit

class AccessoryViewController: UIViewController {
    
    var home: HMHome!
    var room: HMRoom!
    var accessories: [HMAccessory] = []
    @IBOutlet weak var seatCoverInput: UISwitch!
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
        self.accessories = self.room.accessories
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            self.updateTemp()
            self.updateMotion()
            self.updateCurrentDoorState()
        }
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
            self.tempLabel.text = "\(temp)"
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
            self.motionLabel.text = "\(isSitting)"
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
            self.seatCoverInput.isOn = isOn
        }
    }
    
    @IBAction func onSwitch(_ sender: UISwitch) {
        print(sender.isOn)
        guard let characteristicTargetSeatCover = self.getTargetSeatCoverCharacteristic() else {
            print("no target seat characteristics")
            return
        }
        
        characteristicTargetSeatCover.writeValue(sender.isOn) { err in
            print(err)
        }
        
    }
    
}
