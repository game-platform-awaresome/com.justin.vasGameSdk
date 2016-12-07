//
//  PassViewController.swift
//  VasGameSDK
//
//  Created by justin on 16/1/27.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class PassViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var name: UITextField!;
    @IBOutlet weak var next: ColorButton!;
    @IBOutlet weak var iV: UIView!

//    @IBOutlet weak var oPass: UITextField!;
//    @IBOutlet weak var nPass: UITextField!;
//    @IBOutlet weak var code: UITextField!;
//    @IBOutlet weak var codeImg: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        NSNotificationCenter.defaultCenter().postNotificationName(PassProxy.REQUEST_REPASS_CODE_EVENT, object: nil, userInfo: nil);
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PassViewController.onRepassCodeBack(_:)), name: PassProxy.REQUEST_PEPASS_CODE_BACK_EVENT, object: nil);
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PassViewController.onRepassBack(_:)), name: PassProxy.REQUEST_PEPASS_BACK_EVENT, object: nil);
        
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
        
        next.setBackgroundImageColor(ColorButton.oC , hColor: UIColor.grayColor().CGColor);
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        next.setBackgroundImageColor(UIColor.orangeColor().CGColor , hColor: UIColor.grayColor().CGColor);
        
        PassProxy.sharedInstance.startWork();
        VerificationProxy.sharedInstance.startWork();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PassViewController.onBindInfoBack(_:)), name: PassProxy.REQUEST_BIND_INFO_BACK, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PassViewController.onVBack(_:)), name: VerificationProxy.VERIFICATION_NAME_BACK, object: nil);
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated);
        
        PassProxy.sharedInstance.stopWork();
        VerificationProxy.sharedInstance.stopWork();
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VerificationProxy.VERIFICATION_NAME_BACK, object: nil);
    }
    
    func onVBack(n:NSNotification)
    {
        let result = n.userInfo;
        let status = result!["status"] as! Int;
        
        if(status != 1)
        {
            let message = result!["message"] as! String;
            let title:String? = "错误";
            
            AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
        }
        else
        {
            name.resignFirstResponder();
            
            NSNotificationCenter.defaultCenter().postNotificationName(PassProxy.REQUEST_BIND_INFO, object: nil, userInfo: ["name":name.text!]);
            
            LoadingView.sharedInstance.startWork(self);
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder();
        
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_NAME, object: nil, userInfo: ["name":name.text!]);
        
//        LoadingView.sharedInstance.startWork(self);
        
        return true;
    }
    
    @IBAction func onBack(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.BACK, object: nil, userInfo: ["fukey":BipProxy.FORGET_PASS_PAGE, "ukey":BipProxy.LOGIN_PAGE]);
    }

    @IBAction func onNextClick(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_NAME, object: nil, userInfo: ["name":name.text!]);
        
//        LoadingView.sharedInstance.startWork(self);
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.NEXT, object: nil, userInfo: ["fukey":BipProxy.FORGET_PASS_PAGE, "ukey":BipProxy.FORGET_PASS_WEB_PAGE]);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "gotoPassWeb")
        {
            let v = ((segue.destinationViewController as! UINavigationController).topViewController) as! PassWebViewController;
            v.name = name.text;
        }
        else if(segue.identifier == "gotoPassWebEV")
        {
            let v = ((segue.destinationViewController as! UINavigationController).topViewController) as! PassWebEVViewController;
            v.name = name.text;
        }
    }
    
    func onBindInfoBack(n:NSNotification)
    {
        let result = n.userInfo;
        let status = result!["status"] as! Int;
        
        dispatch_async(dispatch_get_main_queue(),
                       {
                        if(status != 100)
                        {
                            let message = result!["message"] as! String;
                            let title:String? = "错误";
                            
                             AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
                        }
                        else
                        {
                            let data = result!["data"] as! NSDictionary;
                            
                            if(!(data["mobile"] is NSNull))
                            {
                                if(data["mobile"] as! String == "")
                                {
                                    let message = "您的帐号未采取安全措施，暂时无法为您找回密码";
                                    let title:String? = "少侠抱歉";
                                    
                                    AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
                                }
                                else
                                {
                                    self.performSegueWithIdentifier("gotoPassWeb", sender: self);
                                }
                            }
                            else
                            {
                                let message = "您的帐号未采取安全措施，暂时无法为您找回密码";
                                let title:String? = "少侠抱歉";
                                
                                AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
                            }
                            
                        }
                        
                        LoadingView.sharedInstance.stopWork();

        });
        
    }
    
    override func shouldAutorotate() -> Bool
    {
        return Common.shouldAutorotate;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return Common.supportedInterfaceOrientations;
    }
}
