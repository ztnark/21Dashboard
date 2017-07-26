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
    var numberFormatter = NumberFormatter()
    var alamoFireManager : Alamofire.SessionManager?
    var url = ""
    var auth = ""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var screenRect = UIScreen.main.bounds
        var screenWidth = screenRect.size.width
        var screenHeight = screenRect.size.height
        
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        self.splashScreen = UIImageView(image: UIImage(named: "SplashScreen"))
        
        self.splashScreen?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
       self.view.addSubview(splashScreen!)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // seconds
        self.alamoFireManager = Alamofire.SessionManager(configuration: configuration)

        
    }
    
    
    func get21Data(_ url: String){
        let headers = [
            "Content-Type": "application/json"
        ]
        //LoadingOverlay.shared.showOverlay(self.view)
        var url = MyVariables.url + "/dashboard"
        let parameters: Parameters = ["code":MyVariables.auth]
        
        
        
        self.alamoFireManager!.request(url, method: .get,parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let data):
            //LoadingOverlay.shared.hideOverlayView()
            if let value = response.result.value {
                let json = JSON(value)
                let onChain = json["status_wallet"]["onchain"].int! as NSNumber
                let balance = json["status_wallet"]["twentyone_balance"].int! as NSNumber
                let flushing = json["status_wallet"]["flushing"].int! as NSNumber
                print("JSON: \(json)")
                if response.response!.statusCode == 200 {
                    self.addressLabel.text = json["status_account"]["address"].stringValue
                    self.onchainLabel.text = self.numberFormatter.string(from: onChain)
                    self.offchainLabel.text = self.numberFormatter.string(from: balance)
                    self.flushingLabel.text =  self.numberFormatter.string(from: flushing)
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
            case .failure(let error):
                self.splashScreen!.removeFromSuperview()
                print(error);
            }
        }

    }
    
    func presentAlert(_ alert: String){
        let alert = UIAlertController(title: "Error", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    


    @IBAction func onchainaction(_ sender: AnyObject) {
        offchainLabel.isHidden = true
        flushingLabel.isHidden = true
        onchainLabel.isHidden = false
        
        offchainBtn.setTitleColor(UIColor.gray, for: UIControlState())
        flushingBtn.setTitleColor(UIColor.gray, for: UIControlState())
        onchainBtn.setTitleColor(UIColor.white, for: UIControlState())
    }
    
    
    @IBAction func offchainaction(_ sender: AnyObject) {
        flushingLabel.isHidden = true
        onchainLabel.isHidden = true
        offchainLabel.isHidden = false
        
        flushingBtn.setTitleColor(UIColor.gray, for: UIControlState())
        onchainBtn.setTitleColor(UIColor.gray, for: UIControlState())
        offchainBtn.setTitleColor(UIColor.white, for: UIControlState())
    }
    
    
    @IBAction func flushingaction(_ sender: AnyObject) {
        onchainLabel.isHidden = true
        offchainLabel.isHidden = true
        flushingLabel.isHidden = false
        
        onchainBtn.setTitleColor(UIColor.gray, for: UIControlState())
        offchainBtn.setTitleColor(UIColor.gray, for: UIControlState())
        flushingBtn.setTitleColor(UIColor.white, for: UIControlState())
    }
    
    @IBAction func mine(_ sender: AnyObject) {
        let headers = [
            "Content-Type": "application/json"
        ]
        LoadingOverlay.shared.showOverlay(self.view)
        var url = MyVariables.url + "/mine"
        let parameters: Parameters = ["code":MyVariables.auth]
        
        self.alamoFireManager!.request(url, method: .get,parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            LoadingOverlay.shared.hideOverlayView()
            switch response.result {
            case .success(let data):
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            if let value = response.result.value {
                let json = JSON(value)
                let onChain = json["status_wallet"]["onchain"].int! as NSNumber
                let balance = json["status_wallet"]["twentyone_balance"].int! as NSNumber
                let flushing = json["status_wallet"]["flushing"].int! as NSNumber
                print("JSON: \(json)")
                if response.response!.statusCode == 200 {
                    self.addressLabel.text = json["status_account"]["address"].stringValue
                    self.onchainLabel.text = self.numberFormatter.string(from: onChain)
                    self.offchainLabel.text = self.numberFormatter.string(from: balance)
                    self.flushingLabel.text = self.numberFormatter.string(from: flushing)
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
                
            case .failure(let error):
                self.presentAlert(error.localizedDescription)
            }

        }
    }

    @IBAction func flush(_ sender: AnyObject) {
        let headers = [
            "Content-Type": "application/json"
        ]
        LoadingOverlay.shared.showOverlay(self.view)
        var url = MyVariables.url + "/flush"
        let parameters: Parameters = ["code":MyVariables.auth]
        
        self.alamoFireManager!.request(url, method: .get,parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            LoadingOverlay.shared.hideOverlayView()
            
            if let value = response.result.value {
                
                let json = JSON(value)
                print("JSON: \(json)")
                let onChain = json["status_wallet"]["onchain"].int! as NSNumber
                let balance = json["status_wallet"]["twentyone_balance"].int! as NSNumber
                let flushing = json["status_wallet"]["flushing"].int! as NSNumber
                print("JSON: \(json)")
                if response.response!.statusCode == 200 {
                    self.addressLabel.text = json["status_account"]["address"].stringValue
                    self.onchainLabel.text = self.numberFormatter.string(from: onChain)
                    self.offchainLabel.text = self.numberFormatter.string(from: balance)
                    self.flushingLabel.text = self.numberFormatter.string(from: flushing)
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
    
    override func viewDidAppear(_ animated: Bool) {
        //self.navigationController?.navigationBar.tintColor = UIColor.whiteColor();
        var headerView = UIView(frame:CGRect(x: 0, y: 0, width: 40, height: 40))
        var image = UIImage(named:"21co.png")
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.image = image
        
        headerView.addSubview(imageView)
        
        self.navigationItem.titleView = headerView
        
        navigationController?.navigationBar.barTintColor = UIColor.black
            //UIColor(colorLiteralRed: 205.0/255.0, green: 0.0/255.0, blue: 15.0/255.0, alpha: 1.0)
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        let defaults = UserDefaults.standard
        var endArr: [NSString] = [NSString]()
        var test = [AnyObject?]()

        if let test : AnyObject? = defaults.object(forKey: "test") as AnyObject?? {
            print(test)
            if (test != nil && test!.count > 0){
                var endpoints = defaults.object(forKey: "test") as! NSArray
                MyVariables.url = endpoints[0] as! String
                MyVariables.auth = endpoints[1] as! String
                get21Data(url)
            }else{
                self.splashScreen!.removeFromSuperview()
                changePrefs()
            }
        }

    }
    
    @IBAction func settings(_ sender: AnyObject) {
        changePrefs()
    }
    func changePrefs(){
        let defaults = UserDefaults.standard
        var endArr: [NSString] = [NSString]()
        
        let alert = UIAlertController(title: "New Endpoint", message: "Enter the endpoint for your 21 computer.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "21 Endpoint"
        }
        
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Authorization Code"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ (alertAction:UIAlertAction!) in
            let textf = alert.textFields![0] as UITextField
            let authf = alert.textFields![1] as UITextField
            MyVariables.url = textf.text!
            MyVariables.auth = authf.text!
            endArr.append(MyVariables.url as NSString)
            endArr.append(MyVariables.auth as NSString)
            defaults.set(endArr, forKey: "test")
            self.get21Data(MyVariables.url)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }


}

