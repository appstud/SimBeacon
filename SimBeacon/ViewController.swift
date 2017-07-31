//
//  ViewController.swift
//  myFakeBeacon
//
//  Created by Jean Sarda on 31/07/2017.
//  Copyright © 2017 Jean Sarda. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController {
    
    //MARK: - Variables
    var peripheralManager: CBPeripheralManager?
    var regionData: [String:Any]?
    
    //MARK: - Outlets
    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var minorTextField: UITextField!
    @IBOutlet weak var identifierTextField: UITextField!
    
    @IBOutlet weak var saveSettingsSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    //MARK: - Actions
    @IBAction func startAdvertising(_ sender: Any) {
        guard let uuid = uuidTextField.text,
            let majorString = majorTextField.text,
            let minorString = minorTextField.text,
            let id = identifierTextField.text else {
                return
        }
        guard uuid != "", majorString != "", minorString != "", id != "" else {
            self.statusLabel.text = "Missing fields"
            return
        }
        guard let proximityUUID = UUID(uuidString: uuid) else {
            self.statusLabel.text = "Badly formatted UUID"
            return
        }
        let major = UInt16(majorString, radix: 10)!
        let minor = UInt16(minorString, radix: 10)!
        
        
        let region = CLBeaconRegion(proximityUUID: proximityUUID,
                                    major: major,
                                    minor: minor,
                                    identifier: id)
        self.advertiseDevice(region: region)
        self.saveSettings()
    }
    
    @IBAction func saveSettingsToggled(_ sender: Any) {
        let settingsSwitch = sender as! UISwitch
        UserDefaults.standard.set(settingsSwitch.isOn, forKey: "Save_Settings")
    }
    
    //MARK: - View Lifecycle
    deinit {
        self.removeObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addObservers()
        self.setDelegates()
        self.restoreSettings()
        self.statusLabel.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Private
    private func advertiseDevice(region: CLBeaconRegion) {
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        let peripheralData = region.peripheralData(withMeasuredPower: nil)
        self.regionData = (peripheralData as NSDictionary) as? [String:Any]
    }
    
    //MARK: - Setup & Observers
    private func setDelegates() {
        self.uuidTextField.delegate = self
        self.majorTextField.delegate = self
        self.minorTextField.delegate = self
        self.identifierTextField.delegate = self
    }
    
    private func addObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(keyboardWillHide(notif:)),
                       name: Notification.Name.UIKeyboardWillHide,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(keyboardWillChangeFrame(notif:)),
                       name: Notification.Name.UIKeyboardWillChangeFrame,
                       object: nil)
    }
    
    private func removeObservers() {
        let nc = NotificationCenter.default
        nc.removeObserver(self,
                          name: Notification.Name.UIKeyboardDidHide,
                          object: nil)
        nc.removeObserver(self,
                          name: Notification.Name.UIKeyboardWillChangeFrame,
                          object: nil)
    }
    
    @objc private func keyboardWillHide(notif: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 20
        }
    }
    
    @objc private func keyboardWillChangeFrame(notif: Notification) {
        guard let userInfo = notif.userInfo else {
            return
        }
        let rect = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
        let height = rect.size.height
        self.bottomConstraint.constant = height + 20
    }
    
    //MARK: - Settings
    private func saveSettings() {
        guard self.saveSettingsSwitch.isOn else {
            return
        }
        let defaults = UserDefaults.standard
        defaults.set(self.uuidTextField.text, forKey: "Beacon_UUID")
        defaults.set(self.majorTextField.text, forKey: "Beacon_Major")
        defaults.set(self.minorTextField.text, forKey: "Beacon_Minor")
        defaults.set(self.identifierTextField.text, forKey: "Beacon_ID")
    }
    
    private func restoreSettings() {
        let defaults = UserDefaults.standard
        if let uuid = defaults.string(forKey: "Beacon_UUID") {
            self.uuidTextField.text = uuid
        }
        if let major = defaults.string(forKey: "Beacon_Major") {
            self.majorTextField.text = major
        }
        if let minor = defaults.string(forKey: "Beacon_Minor") {
            self.minorTextField.text = minor
        }
        if let id = defaults.string(forKey: "Beacon_ID") {
            self.identifierTextField.text = id
        }
        self.saveSettingsSwitch.isOn = defaults.bool(forKey: "Save_Settings")
    }
    
    //MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension ViewController: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state.rawValue == 5 {
            self.peripheralManager?.startAdvertising(self.regionData)
            self.statusLabel.text = "Advertising Beacon"
        } else {
            self.statusLabel.text = "Unknown state : \(peripheral.state.rawValue)"
        }
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
