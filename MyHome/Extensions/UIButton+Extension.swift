//
//  UIButton+Extension.swift
//  PeePooPee
//
//  Created by Cindy Nguyen on 13/02/2022.
//

import Foundation
import UIKit

extension UIButton {
    func setUpRoundedButton(title: String) {
        backgroundColor = UIColor(red: 0.03, green: 0.62, blue: 0.91, alpha: 1.00)
        layer.cornerRadius = 5
        tintColor = .white
        setTitle(title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        
    }
}
