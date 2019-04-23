//
//  UITextField.swift
//  SimBeacon
//
//  Created by Jean Sarda on 23/04/2019.
//  Copyright © 2019 Jean Sarda. All rights reserved.
//

import UIKit

extension UITextField {
    
    func darkSetting(placeholder: String) {
        self.backgroundColor = UIColor.black
        self.textColor = UIColor.lightGray
        self.borderStyle = .roundedRect
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5
        
        let attributedText = NSMutableAttributedString(string:placeholder)
        let range = NSRange(location: 0, length: placeholder.count)
        
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: range)
        
        self.attributedPlaceholder = attributedText
    }
    
}

