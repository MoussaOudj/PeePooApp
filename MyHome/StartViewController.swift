//
//  StartViewController.swift
//  MyHome
//
//  Created by Benoit Briatte on 18/11/2021.
//

import UIKit
import HomeKit

class StartViewController: UIViewController {

    var homeManager: HMHomeManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let manager = HMHomeManager()
        manager.delegate = self
        print("count : \(manager.homes.count)")
        if manager.homes.count == 0 {
            manager.addHome(withName: "PeePooPee") { home, err in
                print(home)
            }
        }else {
            
        }
        self.homeManager = manager
    }
    
    @IBAction func handleSelectHome() {
        guard let maizon = self.homeManager.homes.first(where: { home in
            print(home)
            return home.name == "PeePooPee"
        }) else {
            return
        }
        let hvc = HomeViewController.newInstance(home: maizon)
        self.navigationController?.pushViewController(hvc, animated: true)
    }
}

extension StartViewController: HMHomeManagerDelegate {
    func homeManager(_ manager: HMHomeManager, didUpdate status: HMHomeManagerAuthorizationStatus){
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
    }
}
