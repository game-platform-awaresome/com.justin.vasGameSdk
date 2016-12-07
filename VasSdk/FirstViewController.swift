//
//  FirstViewController.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/11.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import iAd

class FirstViewController: UIViewController,UIAlertViewDelegate, ADBannerViewDelegate
{

    @IBOutlet weak var iV: UIView!;
    @IBOutlet weak var iAD: ADBannerView!
//    @IBOutlet weak var bg: UIImageView!;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
        
//        bg.image = UIImage(named: "game_bg");
        
        iAD.hidden = !Common.iADDis;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        IADProxy.sharedInstance.startWork();
        LoginProxy.sharedInstance.startWork();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.onRequestGuestBack(_:)), name: UserProxy.REQUEST_GUEST_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.onRequestGameCenterLoginBack(_:)), name: LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.onIadInfoBack(_:)), name: IADProxy.REQUEST_IAD_INFO_BACK, object: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(IADProxy.REQUEST_IAD_INFO, object: nil, userInfo: nil);
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated);
        
        IADProxy.sharedInstance.stopWork();
        LoginProxy.sharedInstance.stopWork();
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UserProxy.REQUEST_GUEST_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IADProxy.REQUEST_IAD_INFO_BACK, object: nil);
        
//        iAD.hidden = true;
    }

    @IBAction func onGcClick(sender: AnyObject)
    {
        LoadingView.sharedInstance.startWork(self);
        
        NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_GAMECENTER_LOGIN_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(LoginChooseViewController.GAME_CENTER, object: nil, userInfo: ["fukey":BipProxy.FIRST_PAGE, "ukey":BipProxy.FIRST_PAGE]);
    }
    
    func onRequestGameCenterLoginBack(no:NSNotification)
    {
        dispatch_async(dispatch_get_main_queue(),
                       {
                        LoadingView.sharedInstance.stopWork();
                        
                        let code = no.userInfo!["code"] as! Int;
                        let message:String = no.userInfo!["message"] as! String;
                        
                        //        let vc = no.userInfo!["vc"];
                        
                        if(code == 100)
                        {
                            BipProxy.sharedInstance.stat = "3";
                            BipProxy.sharedInstance.sendBip(BipProxy.LOGIN_SUC, fukey: BipProxy.FIRST_PAGE, ukey: BipProxy.FIRST_PAGE);
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(UserDefaultsProxy.UPDATE_GC_INFO, object: nil, userInfo: ["data":no.userInfo!["data"]!]);
                            
                            if(no.userInfo!["vc"] is NSNull)
                            {
                                SDKMain.sharedInstance.clearSDKUi();
                            }
                            else
                            {
                                let vc = no.userInfo!["vc"] as! UIViewController;
                                
                                self.presentViewController(vc, animated: true, completion: nil);
                            }
                        }
                        else
                        {
//                            AlertManager.sharedInstance.show("登陆失败", message: message, btnTitle: ["好的"], parentVc: self);
                            
                            if(!(no.userInfo!["vc"] is NSNull))
                            {
                                let vc = no.userInfo!["vc"] as! UIViewController;
                                
                                self.presentViewController(vc, animated: true, completion: nil);
                            }
                            else
                            {
                                AlertManager.sharedInstance.show("登陆失败", message: message, btnTitle: ["好的"], parentVc: self);
                            }
                        }
        });
    }
    
    @IBAction func onQuickGameClick(sender: AnyObject)
    {
        UserProxy.sharedInstance.startWork();
        
        AlertManager.sharedInstance.show("游客登陆", message: "确认以游客身份登陆游戏?", btnTitle: ["好的", "取消"], parentVc: self, handle: [okClilkHandle]);
    }
    
    @available(iOS 8.0, *)
    func okClilkHandle(a:UIAlertAction)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(UserProxy.REQUEST_GUEST_EVENT, object: nil);
        
        LoadingView.sharedInstance.startWork(self);
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        if(buttonIndex == 0)
        {
            NSNotificationCenter.defaultCenter().postNotificationName(UserProxy.REQUEST_GUEST_EVENT, object: nil);
        }
    }
    
    func onRequestGuestBack(no:NSNotification)
    {
        UserProxy.sharedInstance.stopWork();
        
        dispatch_async(dispatch_get_main_queue(),
                       {
                        let data:NSDictionary? = no.object as? NSDictionary;
                        
                        let status = data!["status"] as! Int;
                        let message = data!["message"] as! String;
                        
                        let title:String?;
                        
                        if(status != 1)
                        {
                            title = "获取游客身份失败";
                            
                            AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
                        }
                        else
                        {
                            BipProxy.sharedInstance.stat = "2";
                            BipProxy.sharedInstance.sendBip(BipProxy.LOGIN_SUC, fukey: BipProxy.FIRST_PAGE, ukey: BipProxy.FIRST_PAGE);
                            
                            let sdk = SDKMain.sharedInstance;
                            
                            sdk.clearSDKUi();
                        }
                        
                        LoadingView.sharedInstance.stopWork();
        });
    }
    
    func onIadInfoBack(no:NSNotification)
    {
//        let data = no.userInfo;
//        
////        print("\(data)");
//        
//        let status = data!["status"] as! Int;
//        
//        if(status == 0)
//        {
//            let idfaDic = data!["data"] as! NSDictionary;
//            
//            let idfa = idfaDic["idfa"] as! String;
//            
//            if(idfa == "0")
//            {
//                iAD.hidden = true;
//            }
//            else
//            {
//                iAD.hidden = false;
//            }
//        }
    }

    override func shouldAutorotate() -> Bool
    {
        return Common.shouldAutorotate;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return Common.supportedInterfaceOrientations;
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!)
    {
        print("Ad Banner will load ad.");
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!)
    {
        print("Ad Banner did load ad.");
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!)
    {
        print("Unable to show ads. Error: \(error)");
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
