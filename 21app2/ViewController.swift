//
//  ViewController.swift
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

class ViewController: UIViewController {
    @IBOutlet var qrImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var onchainLabel: UILabel!
    @IBOutlet var offchainLabel: UILabel!
    @IBOutlet var flushingLabel: UILabel!
    @IBOutlet var hashrateLabel: UILabel!
    @IBOutlet var onchainBtn: UIButton!
    @IBOutlet var offchainBtn: UIButton!
    @IBOutlet var flushingBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let defaults = NSUserDefaults.standardUserDefaults()
        var endArr: [NSString] = [NSString]()
        var test = []
        var url = ""
        
        
        if let test : AnyObject? = defaults.objectForKey("test") {
            if (test != nil && test!.count > 0){
                var endpoints = defaults.objectForKey("test") as! NSArray
                print("here")
                let url = endpoints[0] as! String
                
            }else{
//                var alert = UIAlertController(title: "New Endpoint", message: "Enter the endpoint for your 21 computer.", preferredStyle: UIAlertControllerStyle.Alert)
//                
//                alert.addTextFieldWithConfigurationHandler { (textField) in
//                    textField.placeholder = "Endpoint"
//                }
//                
//                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler:{ (alertAction:UIAlertAction!) in
//                    let textf = alert.textFields![0] as UITextField
//                    let url = textf.text!
//                    
//                }))
//                
//                self.presentViewController(alert, animated: true, completion: nil)
                
                self.get21Data("http://205.178.81.58:3456/dashboard")

            }
        }
        
//        if test.count == 0 {
//             var alert = UIAlertController(title: "New Endpoint", message: "Enter the endpoint for your 21 computer.", preferredStyle: UIAlertControllerStyle.Alert)
//        
//            alert.addTextFieldWithConfigurationHandler { (textField) in
//                textField.placeholder = "Endpoint"
//            }
//
//            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler:{ (alertAction:UIAlertAction!) in
//                let textf = alert.textFields![0] as UITextField
//                endArr.append(textf.text!)
//            }))
//        
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
        
        //endArr.append("http://205.178.81.58:3456/dashboard")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func get21Data(url: String){
        let headers = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(.GET, url, headers: headers).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            
            if let value = response.result.value {
                let json = JSON(value)
                print("JSON: \(json)")
                self.addressLabel.text = json["status_account"]["address"].stringValue
                self.onchainLabel.text = json["status_wallet"]["onchain"].stringValue
                self.offchainLabel.text = json["status_wallet"]["twentyone_balance"].stringValue
                self.flushingLabel.text = json["status_wallet"]["flushing"].stringValue
                self.hashrateLabel.text = json["status_mining"]["hashrate"].stringValue
                var qrCode = QRCode(json["status_account"]["address"].stringValue)
                self.qrImage.image = qrCode?.image
                
            }
        }

    }

    @IBAction func onchainaction(sender: AnyObject) {
        offchainLabel.hidden = true
        flushingLabel.hidden = true
        onchainLabel.hidden = false
        
        offchainBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        flushingBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        onchainBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    
    @IBAction func offchainaction(sender: AnyObject) {
        flushingLabel.hidden = true
        onchainLabel.hidden = true
        offchainLabel.hidden = false
        
        flushingBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        onchainBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        offchainBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    
    @IBAction func flushingaction(sender: AnyObject) {
        onchainLabel.hidden = true
        offchainLabel.hidden = true
        flushingLabel.hidden = false
        
        onchainBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        offchainBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        flushingBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.navigationController?.navigationBar.tintColor = UIColor.whiteColor();
        var headerView = UIView(frame:CGRect(x: 0, y: 0, width: 150, height: 27))
        var image = UIImage(named:"TextLogo.png")
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 27))
        imageView.image = image
        
        headerView.addSubview(imageView)
        
        self.navigationItem.titleView = headerView
        
        navigationController?.navigationBar.barTintColor = UIColor(rgba: "#EF3131")
            //UIColor(colorLiteralRed: 205.0/255.0, green: 0.0/255.0, blue: 15.0/255.0, alpha: 1.0)
        
        self.navigationController?.navigationBar.translucent = false
    }


}

