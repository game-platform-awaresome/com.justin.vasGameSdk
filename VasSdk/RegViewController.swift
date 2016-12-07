//
//  RegViewController.swift
//  VasGameSDK
//
//  Created by justin on 16/1/7.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class RegViewController: UIViewController, UITextFieldDelegate{

    static let REQUEST_REG:String = "request_reg";
    static let GOTO_REG:String = "goto_reg";
    
    @IBOutlet weak var name: UITextField!;
    @IBOutlet weak var pass: UITextField!;
    @IBOutlet weak var rePass: UITextField!;
    @IBOutlet weak var iV: UIView!;
    @IBOutlet weak var regBtn: ColorButton!;
    
    var aC:AutoComposingTextFieldHandle?;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
        
        regBtn.setBackgroundImageColor(ColorButton.oC , hColor: UIColor.grayColor().CGColor);
        
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        regBtn.setBackgroundImageColor(UIColor.orangeColor().CGColor , hColor: UIColor.grayColor().CGColor);
        
        RegProxy.sharedInstance.startWork();
        VerificationProxy.sharedInstance.startWork();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegViewController.onRequestRegBack(_:)), name: RegProxy.REQUEST_REG_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegViewController.onVerificationBack(_:)), name: VerificationProxy.VERIFICATION_REG_BACK_EVENT, object: nil);
        
         NSNotificationCenter.defaultCenter().postNotificationName(RegViewController.GOTO_REG, object: nil);
        
        aC = AutoComposingTextFieldHandle(view: iV, pView: self.view);
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
        
        
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated);
        
        RegProxy.sharedInstance.stopWork();
        VerificationProxy.sharedInstance.stopWork();
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RegProxy.REQUEST_REG_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VerificationProxy.VERIFICATION_REG_BACK_EVENT, object: nil);
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder();
        
        if(textField == name)
        {
            pass.becomeFirstResponder();
        }
        else if(textField == pass)
        {
            rePass.becomeFirstResponder();
        }
        else if(textField == rePass)
        {
            let data:NSDictionary = NSDictionary(objects: [pass.text!, rePass.text!, name.text!], forKeys: ["pass", "rePass", "name"]);
            
            NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_REG_EVENT, object: data);
        }
        
        return true;
    }
    
    @IBAction func onRegClick(sender: AnyObject)
    {
        let data:NSDictionary = NSDictionary(objects: [pass.text!, rePass.text!, name.text!], forKeys: ["pass", "rePass", "name"]);
        
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_REG_EVENT, object: data);
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.NEXT, object: nil, userInfo: ["fukey":BipProxy.REG_PAGE, "ukey":BipProxy.REG_PAGE]);
    }
    
    func onVerificationBack(no:NSNotification)
    {
        let data:NSDictionary = no.object as! NSDictionary;
        
        let status:Int = data["status"] as! Int;
        let message:String = data["message"] as! String;
        
        let title:String?;
        
        if(status == 1)
        {
//            let data:Dictionary<String, String> = ["name":name.text!, "pass":pass.text!];
            if(UserProxy.sharedInstance.isGuest != 0 && UserProxy.sharedInstance.isGuest != nil)
            {
                NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_REG_EVENT, object: nil, userInfo: ["name":name.text!, "pass":pass.text!, "bindname":UserProxy.sharedInstance.userName!, "bindid":(UserProxy.sharedInstance.userId?.description)!]);
            }
            else
            {
                NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_REG_EVENT, object: nil, userInfo: ["name":name.text!, "pass":pass.text!]);
            }
            
            LoadingView.sharedInstance.startWork(self);
            
            NSNotificationCenter.defaultCenter().postNotificationName(RegViewController.REQUEST_REG, object: nil);
        }
        else
        {
            title = "错误";
            
            AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
        }
    }
    
    func onRequestRegBack(no:NSNotification)
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
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.BACK, object: nil, userInfo: ["fukey":BipProxy.REG_PAGE, "ukey":BipProxy.REG_CHOOSE_PAGE]);
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
}
