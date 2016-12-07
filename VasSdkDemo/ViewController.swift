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
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClear(sender: AnyObject)
    {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        userDefaults.removeObjectForKey("userDicArr");
        userDefaults.removeObjectForKey("vasGameSDKStartNum");
        userDefaults.removeObjectForKey("uuid");
        userDefaults.removeObjectForKey("gc");
        
        SDKMain.clearSDK();
        
        SDKMain.initSDK("msxq_m");
        
        uuid = userDefaults.stringForKey("uuid");
        
        uuidL.text = uuid;
    }

    @IBAction func onClick(sender: AnyObject)
    {
        SDKMain.initSDK("msxq_m", shouldAutorotate: true, supportedInterfaceOrientations: UIInterfaceOrientationMask.All);
        
        SDKMain.strartFirstUi(self);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onSdkClose(_:)), name: SDKMain.SDK_CLOSE , object: nil);
        
        print(SDKMain.adid);
    }
    
    func onSdkClose(n:NSNotification)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SDKMain.SDK_CLOSE , object: nil);
        
        print("sdk close, stat: \(n.userInfo!)");
    }
    
    @IBAction func onBuy(sender: AnyObject)
    {
        SDKMain.startApplePay(["com.pptv.vas.game.30y","com.pptv.vas.game.6y"], ifDisWin: true, parentVc: self);
    }
    @IBAction func onClearBuy(sender: AnyObject)
    {
        SDKMain.stopApplePay();
    }
    @IBAction func initBuy(sender: AnyObject)
    {
//        SDKMain.initApplePay();
    }
}

