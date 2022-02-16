//
//  AccessoryBrowserViewController.swift
//  MyHome
//
//  Created by Benoit Briatte on 16/12/2021.
//

import UIKit
import HomeKit

protocol AccessoryBrowserViewControllerDelegate: AnyObject {
    func accessoryBrowserViewController(_ abvc: AccessoryBrowserViewController, didSelectNew accessory: HMAccessory) -> Void
}

class AccessoryBrowserViewController: UIViewController {

    @IBOutlet var accessoryTableView: UITableView!
    weak var delegate: AccessoryBrowserViewControllerDelegate?
    var accessoryBrowser: HMAccessoryBrowser!
    var accessories: [HMAccessory] = [] {
        didSet {
            self.accessoryTableView.reloadData()
        }
    }
    
    class func newInstance(delegate: AccessoryBrowserViewControllerDelegate?) -> AccessoryBrowserViewController {
        let abvc = AccessoryBrowserViewController()
        abvc.delegate = delegate
        return abvc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accessoryTableView.delegate = self
        self.accessoryTableView.dataSource = self
        self.accessoryTableView.backgroundColor = .clear
        self.accessoryBrowser = HMAccessoryBrowser()
        self.accessoryBrowser.delegate = self
        self.accessoryBrowser.startSearchingForNewAccessories()
    }
}

extension AccessoryBrowserViewController: HMAccessoryBrowserDelegate {
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        self.accessories.append(accessory)
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        guard let index = self.accessories.firstIndex(where: { acc in
            return acc.uniqueIdentifier == accessory.uniqueIdentifier
        }) else {
            return
        }
        self.accessories.remove(at: index)
    }
}

extension AccessoryBrowserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let acc = self.accessories[indexPath.row]
        self.delegate?.accessoryBrowserViewController(self, didSelectNew: acc)
    }
}

extension AccessoryBrowserViewController: UITableViewDataSource {
    static let accessoryCellId =  "acid"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AccessoryBrowserViewController.accessoryCellId) ?? UITableViewCell(style: .default, reuseIdentifier: AccessoryBrowserViewController.accessoryCellId)
        let accessory = self.accessories[indexPath.row]
        cell.textLabel?.text = "\(accessory.name)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accessories.count
    }
}
