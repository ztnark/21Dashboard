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

struct MyVariables {
    static var url = ""
    static var auth = ""
}

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
    @IBOutlet var mineBtn: UIButton!
    @IBOutlet var flushBtn: UIButton!
    var splashScreen: UIImageView?
    var numberFormatter = NSNumberFormatter()
    var alamoFireManager : Alamofire.Manager?
    var url = ""
    var auth = ""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var screenRect = UIScreen.mainScreen().bounds
        var screenWidth = screenRect.size.width
        var screenHeight = screenRect.size.height
        
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        self.splashScreen = UIImageView(image: UIImage(named: "SplashScreen"))
        
        self.splashScreen?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
       self.view.addSubview(splashScreen!)
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 30 // seconds
        self.alamoFireManager = Alamofire.Manager(configuration: configuration)

        
    }
    
    
    func get21Data(url: String){
        let headers = [
            "Content-Type": "application/json"
        ]
        //LoadingOverlay.shared.showOverlay(self.view)
        print(MyVariables.auth)
        self.alamoFireManager!.request(.GET, MyVariables.url + "/dashboard", parameters: ["code":MyVariables.auth], headers: headers).responseJSON { response in
            switch response.result {
            case .Success(let data):
            //LoadingOverlay.shared.hideOverlayView()
            if let value = response.result.value {
                let json = JSON(value)
                print("JSON: \(json)")
                if response.response!.statusCode == 200 {
                    self.addressLabel.text = json["status_account"]["address"].stringValue
                    self.onchainLabel.text = self.numberFormatter.stringFromNumber(json["status_wallet"]["onchain"].int!)
                    self.offchainLabel.text = self.numberFormatter.stringFromNumber(json["status_wallet"]["twentyone_balance"].int!)
                    self.flushingLabel.text =  self.numberFormatter.stringFromNumber(json["status_wallet"]["flushing"].int!)
                    self.hashrateLabel.text = json["status_mining"]["hashrate"].stringValue
                    var qrCode = QRCode(json["status_account"]["address"].stringValue)
                    self.qrImage.image = qrCode?.image
                    self.splashScreen!.removeFromSuperview()

                }
                else if response.response!.statusCode == 401 {
                    var text = json["text"].stringValue
                    self.presentAlert(text)
                    return
                }
            }
            case .Failure(let error):
                self.splashScreen!.removeFromSuperview()
                print(error);
            }
        }

    }
    
    func presentAlert(alert: String){
        let alert = UIAlertController(title: "Error", message: alert, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
    
    @IBAction func mine(sender: AnyObject) {
        let headers = [
            "Content-Type": "application/json"
        ]
        LoadingOverlay.shared.showOverlay(self.view)
        self.alamoFireManager!.request(.GET, MyVariables.url + "/mine", parameters: ["code":MyVariables.auth], headers: headers).responseJSON { response in
            LoadingOverlay.shared.hideOverlayView()
            switch response.result {
            case .Success(let data):
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            if let value = response.result.value {
                let json = JSON(value)
                print("JSON: \(json)")
                if response.response!.statusCode == 200 {
                    self.addressLabel.text = json["status_account"]["address"].stringValue
                    self.onchainLabel.text = self.numberFormatter.stringFromNumber(json["status_wallet"]["onchain"].int!)
                    self.offchainLabel.text = self.numberFormatter.stringFromNumber(json["status_wallet"]["twentyone_balance"].int!)
                    self.flushingLabel.text = self.numberFormatter.stringFromNumber(json["status_wallet"]["flushing"].int!)
                    self.hashrateLabel.text = json["status_mining"]["hashrate"].stringValue
                    var qrCode = QRCode(json["status_account"]["address"].stringValue)
                    self.qrImage.image = qrCode?.image
                }
                else if response.response!.statusCode == 401 {
                    var text = json["text"].stringValue
                    self.presentAlert(text)
                    return
                }
                
            }
                
            case .Failure(let error):
                self.presentAlert(error.localizedDescription)
            }

        }
    }

    @IBAction func flush(sender: AnyObject) {
        let headers = [
            "Content-Type": "application/json"
        ]
        LoadingOverlay.shared.showOverlay(self.view)
        self.alamoFireManager!.request(.GET, MyVariables.url + "/flush", parameters: ["code":MyVariables.auth], headers: headers).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            LoadingOverlay.shared.hideOverlayView()
            
            if let value = response.result.value {
                
                let json = JSON(value)
                print("JSON: \(json)")
                if response.response!.statusCode == 200 {
                    self.addressLabel.text = json["status_account"]["address"].stringValue
                    self.onchainLabel.text = self.numberFormatter.stringFromNumber(json["status_wallet"]["onchain"].int!)
                    self.offchainLabel.text = self.numberFormatter.stringFromNumber(json["status_wallet"]["twentyone_balance"].int!)
                    self.flushingLabel.text = self.numberFormatter.stringFromNumber(json["status_wallet"]["flushing"].int!)
                    self.hashrateLabel.text = json["status_mining"]["hashrate"].stringValue
                    var qrCode = QRCode(json["status_account"]["address"].stringValue)
                    self.qrImage.image = qrCode?.image
                }
                else if response.response!.statusCode == 401 {
                    var text = json["text"].stringValue
                    self.presentAlert(text)
                    return
                }
            }

        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.navigationController?.navigationBar.tintColor = UIColor.whiteColor();
        var headerView = UIView(frame:CGRect(x: 0, y: 0, width: 40, height: 40))
        var image = UIImage(named:"21co.png")
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.image = image
        
        headerView.addSubview(imageView)
        
        self.navigationItem.titleView = headerView
        
        navigationController?.navigationBar.barTintColor = UIColor(rgba: "#000")
            //UIColor(colorLiteralRed: 205.0/255.0, green: 0.0/255.0, blue: 15.0/255.0, alpha: 1.0)
        
        self.navigationController?.navigationBar.translucent = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var endArr: [NSString] = [NSString]()
        var test = []

        if let test : AnyObject? = defaults.objectForKey("test") {
            print(test)
            if (test != nil && test!.count > 0){
                var endpoints = defaults.objectForKey("test") as! NSArray
                MyVariables.url = endpoints[0] as! String
                MyVariables.auth = endpoints[1] as! String
                get21Data(url)
            }else{
                self.splashScreen!.removeFromSuperview()
                changePrefs()
            }
        }

    }
    
    @IBAction func settings(sender: AnyObject) {
        changePrefs()
    }
    func changePrefs(){
        let defaults = NSUserDefaults.standardUserDefaults()
        var endArr: [NSString] = [NSString]()
        var test = []
        
        var alert = UIAlertController(title: "New Endpoint", message: "Enter the endpoint for your 21 computer.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "21 Endpoint"
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.secureTextEntry = true
            textField.placeholder = "Authorization Code"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler:{ (alertAction:UIAlertAction!) in
            let textf = alert.textFields![0] as UITextField
            let authf = alert.textFields![1] as UITextField
            MyVariables.url = textf.text!
            MyVariables.auth = authf.text!
            endArr.append(MyVariables.url)
            endArr.append(MyVariables.auth)
            defaults.setObject(endArr, forKey: "test")
            self.get21Data(MyVariables.url)
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }


}

