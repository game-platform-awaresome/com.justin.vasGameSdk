//
//  PhoneRegViewController.swift
//  VasGameSDK
//
//  Created by justin on 16/1/15.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class PhoneRegViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var phoneCode: UITextField!;
    @IBOutlet weak var pass: UITextField!;
    @IBOutlet weak var getCodeBtn: ColorButton!
    @IBOutlet weak var regBtn: ColorButton!
    @IBOutlet weak var iV: UIView!;
    
    
    var aC:AutoComposingTextFieldHandle?;
    
    static let GOTO_PHONE_REG:String = "gotoPhoneReg";
    static let GET_CODE:String = "get_code";
    
    var t:NSTimer?;
    var s:Int = 60;
    var isCooling:Bool = false;
    
    var getCodeBtnInitTxt:String?;

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
        
        getCodeBtn.setBackgroundImageColor(UIColor.blackColor().CGColor , hColor: UIColor.grayColor().CGColor);
        regBtn.setBackgroundImageColor(ColorButton.oC , hColor: UIColor.grayColor().CGColor);
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        
        
        s = 60;
        
        getCodeBtnInitTxt = getCodeBtn.titleLabel?.text;
        
        RegProxy.sharedInstance.startWork();
        VerificationProxy.sharedInstance.startWork();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PhoneRegViewController.onVerificationPhoneCodeBack(_:)), name: VerificationProxy.VERIFICATION_PHONE_CODE_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PhoneRegViewController.onVerificationPhoneRegBack(_:)), name: VerificationProxy.VERIFICATION_PHONE_REG_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PhoneRegViewController.onRequestPhoneRegBack(_:)), name: RegProxy.REQUEST_PHONE_REG_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PhoneRegViewController.onRequestPhoneCodeBack(_:)), name: RegProxy.REQUEST_PHONE_CODE_BACK_EVENT, object: nil);
        
        
        NSNotificationCenter.defaultCenter().postNotificationName(PhoneRegViewController.GOTO_PHONE_REG, object: nil);
        
        aC = AutoComposingTextFieldHandle(view: iV, pView: self.view);
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
        
        
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated);
        
        if(t != nil)
        {
            t!.invalidate();
        }
        
        RegProxy.sharedInstance.stopWork();
        VerificationProxy.sharedInstance.stopWork();
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RegProxy.REQUEST_PHONE_REG_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RegProxy.REQUEST_PHONE_CODE_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VerificationProxy.VERIFICATION_PHONE_CODE_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VerificationProxy.VERIFICATION_PHONE_REG_BACK_EVENT, object: nil);

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder();
        
        if(textField == phoneCode)
        {
            pass.becomeFirstResponder();
        }
        else if(textField == pass)
        {
            let data = ["phone":phoneCode.text!, "code":pass.text!];
            
            NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_PHONE_REG_EVENT, object: nil, userInfo: data);
        }
        
        return true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onRegClick(sender: AnyObject)
    {
        let data = ["phone":phoneCode.text!, "code":pass.text!];
        
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_PHONE_REG_EVENT, object: nil, userInfo: data);
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.NEXT, object: nil, userInfo: ["fukey":BipProxy.PHONE_REG_PAGE, "ukey":BipProxy.PHONE_REG_PAGE]);
    }
    
    func onVerificationPhoneRegBack(n:NSNotification)
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
            if(UserProxy.sharedInstance.isGuest != 0 && UserProxy.sharedInstance.isGuest != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_PHONE_REG_EVENT, object: nil, userInfo: ["name":phoneCode.text!, "phonecheckcode":pass.text!, "bindname":UserProxy.sharedInstance.userName!, "bindid":(UserProxy.sharedInstance.userId?.description)!]);
            }
            else
            {
                NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_PHONE_REG_EVENT, object: nil, userInfo: ["name":phoneCode.text!, "phonecheckcode":pass.text!]);
            }
            
//            let data:Dictionary<String, String> = ["name":phoneCode.text!, "phonecheckcode":pass.text!];
//            
//            NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_PHONE_REG_EVENT, object: data);
            
            LoadingView.sharedInstance.startWork(self);
        }
    }
    
    @IBAction func onPhoneCodeClick(sender: AnyObject)
    {
        let data = ["phone":phoneCode.text!];
        
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_PHONE_CODE_EVENT, object: nil, userInfo: data);
        
        NSNotificationCenter.defaultCenter().postNotificationName(PhoneRegViewController.GET_CODE, object: nil);
    }
    
    func onTimer(t:NSTimer)
    {
        s -= 1;
        
        if(s == 0)
        {
            t.invalidate();
            
            isCooling = false;
            
            getCodeBtn.enabled = true;
            
            getCodeBtn.setTitle(getCodeBtnInitTxt, forState: UIControlState.Normal);
        }
        else
        {
            getCodeBtn.setTitle(s.description + "s", forState: UIControlState.Normal);
        }
    }

    
    func onVerificationPhoneCodeBack(n:NSNotification)
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
            let data:Dictionary<String, String> = ["name":phoneCode.text!];
            
            NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_PHONE_CODE_EVENT, object: data);

        }
    }
    
    func onRequestPhoneCodeBack(no:NSNotification)
    {
        dispatch_async(dispatch_get_main_queue(),
            {
                let data:NSDictionary? = no.object as? NSDictionary;
                
                let status = data!["status"] as! Int;
                var message = data!["message"] as! String;
                
                let title:String?;

                if(status != 1)
                {
                    title = "错误";
                    
                    if(message.rangeOfString("info") != nil)
                    {
                        message = "参数错误";
                    }
                    
                    AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
                }
                else
                {
                    if(!self.isCooling)
                    {
                        self.s = 60;
                        
                        self.t = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(AutoLoginViewController.onTimer(_:)), userInfo: nil, repeats: true);
                        
                        self.isCooling = true;
                        
                        self.getCodeBtn.enabled = false;
                    }
                }
                
                LoadingView.sharedInstance.stopWork();
        });
    }
    
    func onRequestPhoneRegBack(no:NSNotification)
    {
        dispatch_async(dispatch_get_main_queue(),
            {
                let data:NSDictionary? = no.object as? NSDictionary;
                
                let status = data!["status"] as! Int;
                let message = data!["message"] as! String;
                
                let title:String?;
                
                if(status != 1)
                {
                    title = "注册失败";
                    
                    AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
                }
                else
                {
                    BipProxy.sharedInstance.stat = "1";
                    BipProxy.sharedInstance.sendBip(BipProxy.LOGIN_SUC, fukey: BipProxy.LOGIN_PAGE, ukey: BipProxy.LOGIN_PAGE);
                    
                    SDKMain.sharedInstance.clearSDKUi();
                }
                
                LoadingView.sharedInstance.stopWork();
        });
    }

    @IBAction func onBack(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.BACK, object: nil, userInfo: ["fukey":BipProxy.PHONE_REG_PAGE, "ukey":BipProxy.REG_CHOOSE_PAGE]);

    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        aC?.textFieldDidBeginEditing(textField);
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        aC?.textFieldDidEndEditing(textField);
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
