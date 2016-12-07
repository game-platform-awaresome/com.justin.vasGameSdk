//
//  AutoLoginViewController.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/13.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class AutoLoginViewController: UIViewController {

    @IBOutlet weak var changeBtn: ColorButton!;
    @IBOutlet weak var iV: UIView!;
    @IBOutlet weak var name: UILabel!;
    @IBOutlet weak var time: UILabel!;
    
    static let CHANGE_USER:String = "change_user";
    
    var t:NSTimer?;
    var s:Int = 0;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
        
        changeBtn.setBackgroundImageColor(ColorButton.oC , hColor: UIColor.grayColor().CGColor);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        
        
        s = 5;
        
        LoginProxy.sharedInstance.startWork();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AutoLoginViewController.onRequestLoginBack(_:)), name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AutoLoginViewController.onRequestGameCenterLoginBack(_:)), name: LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil);
        
        t = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(AutoLoginViewController.onTimer(_:)), userInfo: nil, repeats: true);
        
        if(UserProxy.sharedInstance.gcDic != nil)
        {
            name.text = UserProxy.sharedInstance.gcDic!["alias"] as? String;
        }
        else
        {
            name.text = UserProxy.sharedInstance.userName;
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
        
        
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated);
        
        LoginProxy.sharedInstance.stopWork();
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil);
        
        t!.invalidate();
    }
    
    func onTimer(t:NSTimer)
    {
        s -= 1;
        
        if(s == 0)
        {
            LoadingView.sharedInstance.startWork(self);
            
            t.invalidate();
            
            if(UserProxy.sharedInstance.gcDic != nil)
            {
                LoadingView.sharedInstance.startWork(self);
                
                NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_GAMECENTER_LOGIN_EVENT, object: nil);
            }
            else
            {
                LoadingView.sharedInstance.startWork(self);
                
                let data:Dictionary<String, String>?;
                
                data = ["name":UserProxy.sharedInstance.userName!, "pass":UserProxy.sharedInstance.userPass!];
                
                NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_LOGIN_EVENT, object: data!);

            }
        }
        else
        {
            time.text = s.description + "s";
        }
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
                            AlertManager.sharedInstance.show("登陆失败", message: message, btnTitle: ["好的"], parentVc: self);
                        }
        });
    }
    
    func onRequestLoginBack(no:NSNotification)
    {
        dispatch_async(dispatch_get_main_queue(),
                       {
                        LoadingView.sharedInstance.stopWork();
                        
                        let data:NSDictionary? = no.object as? NSDictionary;
                        
                        let status = data!["status"] as! Int;
                        let message = data!["message"] as! String;
                        
                        let title:String?;
                        
                        if(status != 1)
                        {
                            title = "登录失败";
                            
                            AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
                        }
                        else
                        {
                            BipProxy.sharedInstance.stat = "1";
                            BipProxy.sharedInstance.sendBip(BipProxy.LOGIN_SUC, fukey: BipProxy.LOGIN_PAGE, ukey: BipProxy.LOGIN_PAGE);
                            
                            SDKMain.sharedInstance.clearSDKUi();
                        }
        });

    }

    @IBAction func onChange(sender: AnyObject)
    {
        self.performSegueWithIdentifier("gotoChoose", sender: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(AutoLoginViewController.CHANGE_USER, object: nil);
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
