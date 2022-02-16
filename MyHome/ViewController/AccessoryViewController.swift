//
//  AccessoryViewController.swift
//  MyHome
//
//  Created by Benoit Briatte on 16/12/2021.
//

import UIKit
import HomeKit
import WatchConnectivity
import Lottie
import Charts

class AccessoryViewController: UIViewController {
    var home: HMHome!
    var room: HMRoom!
    var accessories: [HMAccessory] = []
    var timers:[(Double, String)] = []
    var timer = Timer()
    var counter = 0.0
    @IBOutlet weak var seatCoverInput: UISwitch!
    @IBOutlet weak var fanInput: UISwitch!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var fanView: UIView!
    @IBOutlet weak var fanLabel: UILabel!
    @IBOutlet weak var seatView: UIView!
    @IBOutlet weak var seatAnimation: AnimationView!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var fanAnimation: AnimationView!
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var motionView: UIView!
    @IBOutlet weak var motionLabel: UILabel!
    @IBOutlet weak var seatOpenAnimationView: AnimationView!
    @IBOutlet weak var barChartView: BarChartView!
    
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
        configureFanAnimation(isOn: fanInput.isOn)
        configureSeatAnimation()
    }
    
    func configureComponents() {
        view.setGradientBackground()
        seatView.layer.cornerRadius = 20
        seatView.backgroundColor = .white
        seatLabel.textColor = .orange
        
        fanView.layer.cornerRadius = 20
        fanView.backgroundColor = .white
        fanLabel.textColor = .orange
        
        tempView.layer.cornerRadius = 20
        tempView.backgroundColor = .white
        tempLabel.textColor = .orange
        
        motionView.layer.cornerRadius = 20
        motionView.backgroundColor = .white
        motionLabel.textColor = .orange
        
        seatOpenAnimationView.isHidden = true
    }
    
    func configureFanAnimation(isOn: Bool) {
        fanAnimation.backgroundColor = .clear
        fanAnimation!.frame = view.bounds
        fanAnimation!.contentMode = .scaleAspectFit
        fanAnimation!.loopMode = .loop
        if fanInput.isOn {
            fanAnimation!.play()
        }
        fanAnimation!.animationSpeed = 0.5
        let keypath = AnimationKeypath(keys: ["**", "Fill", "**", "Color"])
        let colorProvider = ColorValueProvider(UIColor.orange.lottieColorValue)
        fanAnimation.setValueProvider(colorProvider, keypath: keypath)
    }
    
    func configureSeatAnimation() {
        seatAnimation.backgroundColor = .clear
        seatAnimation!.frame = view.bounds
        seatAnimation!.contentMode = .scaleAspectFill
        seatAnimation!.loopMode = .playOnce
        seatAnimation!.animationSpeed = 0.5
        seatAnimation!.play()
        
        seatOpenAnimationView.backgroundColor = .clear
        seatOpenAnimationView!.frame = view.bounds
        seatOpenAnimationView!.contentMode = .scaleAspectFill
        seatOpenAnimationView!.loopMode = .playOnce
        seatOpenAnimationView!.animationSpeed = 0.5
        seatOpenAnimationView!.play()
        
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
                self.tempLabel.text = "Error Tempature"
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
                self.motionLabel.text = "Error motion data"
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
            
            if isSitting {
                self.motionLabel.text = "Occupied ⛔️"
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: false)
                
                
            } else {
                self.motionLabel.text = "Vacant ✅"
                if self.counter != 0.0 {
                    self.timer.invalidate()
                    self.timers.append((self.counter, String(self.counter)))
                    self.counter = 0.0
                    self.updateGraph()
                }
                
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
            self.seatAnimation.isHidden = isOn
            self.seatOpenAnimationView.isHidden = !isOn
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
            
            if (WCSession.default.isReachable) {
                let message = ["isFanOn": isOn]
                WCSession.default.sendMessage(message, replyHandler: nil)
            }
            
            self.configureFanAnimation(isOn: isOn)
            if self.fanInput.isOn == false {
                self.fanAnimation.pause()
            }
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
    
    func updateGraph() {
        
        var barChartEntry = [BarChartDataEntry]()
        
        for i in 0..<timers.count {
            
            print("i = \(i)")
            print(timers.count)
            print(timers[i].0)
            let value = BarChartDataEntry(x: Double(i), y: timers[i].0 , data: timers[i].1)
            barChartEntry.append(value)
            
        }
        
        print("update graph")
        var set1:BarChartDataSet! = nil
        
        set1 = BarChartDataSet(entries: barChartEntry, label: "PeePooTime")
        set1.colors = ChartColorTemplates.material()
        set1.drawValuesEnabled = false
        
        let data = BarChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.barWidth = 0.9
        barChartView.data = data
    }
    
    
    @objc func updateTimer() {
        counter = counter + 0.1
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
        
        if message.first?.key == "isOn" {
            
            guard let isOn = message["isOn"] as? Bool else {
                return
            }
            DispatchQueue.main.async {
                self.seatCoverInput.isOn = isOn
                self.onSwitch(self.seatCoverInput)
            }
            
        }
        
        if message.first?.key == "isFanOn" {
            guard let isOn = message["isFanOn"] as? Bool else {
                return
            }
            DispatchQueue.main.async {
                self.fanInput.isOn = isOn
                self.onFanInputSwitch(self.fanInput)
            }
        }
        
       
    }
}
