//
//  LoginChooseViewController.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/14.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class LoginChooseViewController: UIViewController
{
    @IBOutlet weak var iV: UIView!;
    
    static let GAME_CENTER:String = "game_center";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        LoginProxy.sharedInstance.startWork();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginChooseViewController.onRequestGameCenterLoginBack(_:)), name: LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil);
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated);
        
        LoginProxy.sharedInstance.stopWork();
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil);
        
    }
    
    @IBAction func onGameCenter(sender: AnyObject)
    {
        LoadingView.sharedInstance.startWork(self);
        
        NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_GAMECENTER_LOGIN_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(LoginChooseViewController.GAME_CENTER, object: nil, userInfo: ["fukey":BipProxy.LOGIN_CHOOSE_PAGE, "ukey":BipProxy.LOGIN_CHOOSE_PAGE]);
    }
    
    func onRequestGameCenterLoginBack(no:NSNotification)
    {
        LoadingView.sharedInstance.stopWork();
        
        let code = no.userInfo!["code"] as! Int;
        let message:String = no.userInfo!["message"] as! String;
        
        //        let vc = no.userInfo!["vc"];
        
        if(code == 100)
        {
            BipProxy.sharedInstance.stat = "3";
            BipProxy.sharedInstance.sendBip(BipProxy.LOGIN_SUC, fukey: BipProxy.LOGIN_CHOOSE_PAGE, ukey: BipProxy.LOGIN_CHOOSE_PAGE);
            
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
    }
    
    override func shouldAutorotate() -> Bool
    {
        return Common.shouldAutorotate;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return Common.supportedInterfaceOrientations;
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
