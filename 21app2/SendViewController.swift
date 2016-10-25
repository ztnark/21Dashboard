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
        
        Alamofire.request(.POST, MyVariables.url + "/send", parameters: parameters, encoding: .json, headers: headers).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            LoadingOverlay.shared.hideOverlayView()
            
            if let value = response.result.value {
                let json = JSON(value)
                print("JSON: \(json)")
                if response.response!.statusCode == 401 {
                    var text = json["text"].stringValue
                    self.presentAlert(text)
                }
            }
            
        }
    }
    
    lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    
    @IBAction func scanAction(_ sender: AnyObject) {
        // Retrieve the QRCode content
        // By using the delegate pattern
        reader.delegate = self
        
        // Or by using the closure pattern
        reader.completionBlock = { (result: QRCodeReaderResult?) in
            self.address = result!.value
            
            self.addressField.text = self.address
            
        }
        
        // Presents the reader as modal form sheet
        reader.modalPresentationStyle = .formSheet
        present(reader, animated: true, completion: nil)
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
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        print("here");
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        var endArr: [NSString] = [NSString]()
        var test = []
        
        if let test : AnyObject? = defaults.object(forKey: "test") as AnyObject?? {
            if (test != nil && test!.count > 0){
                let endpoints = defaults.object(forKey: "test") as! NSArray
                print("here")
                self.url = endpoints[0] as! String
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    
}

