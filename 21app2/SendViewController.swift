//
//  SendViewController.swift
//  21app2
//
//  Created by Jeff Krantz on 1/6/16.
//  Copyright © 2016 Jeff Krantz. All rights reserved.
//IDEAS
// Ability to add new endpoints
//Ability to make and receive both on-chain and off-chain payments

import UIKit
import Alamofire
import UIColor_Hex_Swift
import SwiftyJSON
import QRCode
import QRCodeReader
import AVFoundation

class SendViewController: UIViewController, QRCodeReaderViewControllerDelegate, UITextFieldDelegate {

    @IBOutlet var amountField: UITextField!
    @IBOutlet var addressField: UITextField!
    
    var address = ""
    var url = ""
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SendViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }

    @IBAction func cancel(_ sender: AnyObject) {

        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func send(_ sender: AnyObject) {
        let headers = [
            "Content-Type": "application/json"
        ]
        
        let amount:Int? = Int(amountField.text!)
        
        let parameters : [String : AnyObject] = [
            "address": self.addressField.text! as AnyObject,
            "amount": amount! as AnyObject,
            "code":MyVariables.auth as AnyObject,
        ]
        
        LoadingOverlay.shared.showOverlay(self.view)
        let url = MyVariables.url + "/send"
        
        Alamofire.request(url, method: .post,parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            LoadingOverlay.shared.hideOverlayView()
            
            if let value = response.result.value {
                let json = JSON(value)
                print("JSON: \(json)")
                if response.response!.statusCode == 401 {
                    let text = json["text"].stringValue
                    self.presentAlert(text)
                }
            }
            
        }
    }
    
//    lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    
    
    @IBAction func scanAction(_ sender: AnyObject) {
        guard checkScanPermissions() else { return }

        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self as! QRCodeReaderViewControllerDelegate
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            self.address = result!.value
            
            self.addressField.text = self.address
            
        }
        
        // Presents the reader as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func presentAlert(_ alert: String){
        let alert = UIAlertController(title: "Error", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - QRCodeReader Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        if let cameraName = newCaptureDevice.device.localizedName {
            print("Switching capturing to: \(cameraName)")
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        print("here");
        self.dismiss(animated: true, completion: nil)
    }
    
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController?
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert?.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                
                alert?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            case -11814:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert?.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            default:
                alert = nil
            }
            
            guard let vc = alert else { return false }
            
            present(vc, animated: true, completion: nil)
            
            return false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        
        if let userData : AnyObject? = defaults.object(forKey: "test") as AnyObject?? {
            if (userData != nil && userData!.count > 0){
                let endpoints = defaults.object(forKey: "test") as! NSArray
                self.url = endpoints[0] as! String
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    
}

