//
//  ViewController.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/8.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import VasSdk

class ViewController: UIViewController {

    @IBOutlet weak var iV: UIImageView!;
    
    var uuid:String?;
    
    @IBOutlet weak var uuidL: UILabel!;
//    applePay
//    com.pptv.vas.game.30y
//    com.pptv.vas.game.6y
//    vasgame@pptv.com
//    2WAt6AxB
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        iV.image = UIImage(named: "game_bg");
        
        SDKMain.initSDK();
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        uuid = userDefaults.stringForKey("uuid");
        
        uuidL.text = uuid;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onSdkProduct(_:)), name: SDKMain.APPLE_PRODUCT_INFO_BACK , object: nil);
    }
    
    func onSdkProduct(n:NSNotification)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SDKMain.APPLE_PRODUCT_INFO_BACK , object: nil);
        
        print("apple product info: \(n.userInfo!)");
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onClearSdk(sender: AnyObject) {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        userDefaults.removeObjectForKey("userDicArr");
        userDefaults.removeObjectForKey("vasGameSDKStartNum");
        userDefaults.removeObjectForKey("uuid");
        userDefaults.removeObjectForKey("gc");
        
        SDKMain.clearSDK();
        
        SDKMain.initSDK("hdcq_m");
        
        uuid = userDefaults.stringForKey("uuid");
        
        uuidL.text = uuid;
    }

    @IBAction func onClick(sender: AnyObject)
    {
        SDKMain.initSDK("hdcq_m", shouldAutorotate: true, supportedInterfaceOrientations: UIInterfaceOrientationMask.All);
        
        SDKMain.strartFirstUi(self);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onSdkClose(_:)), name: SDKMain.SDK_CLOSE , object: nil);
        
        print(SDKMain.adid);
    }
    
    func onSdkClose(n:NSNotification)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SDKMain.SDK_CLOSE , object: nil);
        
        print("sdk close, stat: \(n.userInfo!)");
    }
    
    @IBAction func onClearBuy(sender: AnyObject)
    {
        SDKMain.stopApplePay();
    }
    
    @IBAction func onClickBuy(sender: AnyObject)
    {
        SDKMain.buyAppleProduct("cn.codegame.pptvhdwg.200109");
    }
    
    @IBAction func onInitBuy(sender: AnyObject)
    {
        SDKMain.initSDK("hdcq_m", shouldAutorotate: true, supportedInterfaceOrientations: UIInterfaceOrientationMask.All);
        
        SDKMain.startApplePay(["cn.codegame.pptvhdwg.200109","cn.codegame.pptvhdwg.200108","cn.codegame.pptvhdwg.200006"], ifDisWin: false, parentVc: self);

    }
}
