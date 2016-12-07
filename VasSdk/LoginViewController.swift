//
//  LoginViewController.swift
//  VasGameSDK
//
//  Created by justin on 15/12/22.
//  Copyright © 2015年 justin. All rights reserved.
//

import UIKit

public class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var pass: UITextField!;
    @IBOutlet weak var loginBtn: ColorButton!
    @IBOutlet weak var iV: UIView!
    
    static let GOTO_LOGIN:String = "goto_login";
    
    var aC:AutoComposingTextFieldHandle?;
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
        
        loginBtn.setBackgroundImageColor(ColorButton.oC , hColor: UIColor.grayColor().CGColor);
        
    }
    
    override public func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        
        
        LoginProxy.sharedInstance.startWork();
        VerificationProxy.sharedInstance.startWork();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.onRequestLoginBack(_:)), name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.onVerificationLoginBack(_:)), name: VerificationProxy.VERIFICATION_LOGIN_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(LoginViewController.GOTO_LOGIN, object: nil);
    }
    
    override public func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
        
        aC = AutoComposingTextFieldHandle(view: iV, pView: self.view);
    }
    
    override public func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated);
        
        LoginProxy.sharedInstance.stopWork();
        VerificationProxy.sharedInstance.stopWork();
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VerificationProxy.VERIFICATION_LOGIN_BACK_EVENT, object: nil);
    }


    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder();
        
        if(textField == name)
        {
            pass.becomeFirstResponder();
        }
        else if(textField == pass)
        {
            let data = ["name":name.text!, "pass":pass.text!];
            
            NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_LOGIN_EVENT, object: nil, userInfo: data);
        }
        
        return true;
    }
    
    @IBAction func onLogin(sender: AnyObject)
    {
        let data = ["name":name.text!, "pass":pass.text!];
        
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_LOGIN_EVENT, object: nil, userInfo: data);
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.NEXT, object: nil, userInfo: ["fukey":BipProxy.LOGIN_PAGE, "ukey":BipProxy.LOGIN_PAGE]);
    }
    
    func onVerificationLoginBack(n:NSNotification)
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
            pass.resignFirstResponder();
            
            let data:Dictionary<String, String> = ["name":name.text!, "pass":pass.text!];
            NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_LOGIN_EVENT, object: data);
            
            LoadingView.sharedInstance.startWork(self);
        }
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

    @IBAction func onBack(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.BACK, object: nil, userInfo: ["fukey":BipProxy.LOGIN_PAGE, "ukey":BipProxy.LOGIN_CHOOSE_PAGE]);
    }
    
    @IBAction func onReg(sender: AnyObject)
    {
        self.performSegueWithIdentifier("loginGotoReg", sender: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(RegChooseViewController.GOTO_REG_CHOOSE, object: nil, userInfo: ["fukey":BipProxy.LOGIN_PAGE, "ukey":BipProxy.REG_CHOOSE_PAGE]);

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    public func textFieldDidBeginEditing(textField: UITextField)
    {
        aC?.textFieldDidBeginEditing(textField);
    }
    
    public func textFieldDidEndEditing(textField: UITextField)
    {
        aC?.textFieldDidEndEditing(textField);
    }
    
    override public func shouldAutorotate() -> Bool
    {
        return Common.shouldAutorotate;
    }
    
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return Common.supportedInterfaceOrientations;
    }
}
