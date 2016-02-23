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

class SendViewController: UIViewController, QRCodeReaderViewControllerDelegate {

    @IBOutlet var amountField: UITextField!
    @IBOutlet var addressField: UITextField!
    
    var address = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    @IBAction func cancel(sender: AnyObject) {

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func send(sender: AnyObject) {
        let headers = [
            "Content-Type": "application/json"
        ]
        
        let amount:Int? = Int(amountField.text!)
        
        let parameters : [String : AnyObject] = [
            "address": self.addressField.text!,
            "amount": amount!,
        ]
        
        Alamofire.request(.POST, "http://205.178.81.58:3456/send", parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            if let value = response.result.value {
                let json = JSON(value)
                print("JSON: \(json)")
            }
            
        }
    }
    
    lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    
    @IBAction func scanAction(sender: AnyObject) {
        // Retrieve the QRCode content
        // By using the delegate pattern
        reader.delegate = self
        
        // Or by using the closure pattern
        reader.completionBlock = { (result: QRCodeReaderResult?) in
            self.address = result!.value
            
            self.addressField.text = self.address
            
        }
        
        // Presents the reader as modal form sheet
        reader.modalPresentationStyle = .FormSheet
        presentViewController(reader, animated: true, completion: nil)
    }
    
    // MARK: - QRCodeReader Delegate Methods
    
    func reader(reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController) {
        print("here");
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
//        //self.navigationController?.navigationBar.tintColor = UIColor.whiteColor();
//        var headerView = UIView(frame:CGRect(x: 0, y: 0, width: 150, height: 27))
//        var image = UIImage(named:"TextLogo.png")
//        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 27))
//        imageView.image = image
//        
//        headerView.addSubview(imageView)
//        
//        self.navigationItem.titleView = headerView
//        
//        navigationController?.navigationBar.barTintColor = UIColor(rgba: "#EF3131")
//        //UIColor(colorLiteralRed: 205.0/255.0, green: 0.0/255.0, blue: 15.0/255.0, alpha: 1.0)
//        
//        self.navigationController?.navigationBar.translucent = false
    }
    
    
}

