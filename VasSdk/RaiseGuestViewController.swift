//
//  RaiseGuestViewController.swift
//  VasGameSDK
//
//  Created by justin on 16/1/29.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class RaiseGuestViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var rePass: UITextField!

    @IBOutlet weak var regBtn: ColorButton!;
    @IBOutlet weak var iV: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
        
        regBtn.setBackgroundImageColor(UIColor.orangeColor().CGColor , hColor: UIColor.grayColor().CGColor);
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RaiseGuestViewController.onVerificationBack(_:)), name: VerificationProxy.VERIFICATION_REG_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RaiseGuestViewController.onRequestRaiseGuestBack(_:)), name: UserProxy.REQUEST_RAISE_GUEST_BACK_EVENT, object: nil);
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VerificationProxy.VERIFICATION_REG_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UserProxy.REQUEST_RAISE_GUEST_BACK_EVENT, object: nil);
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder();
        
        return true;
    }
    
    @IBAction func onSubmit(sender: AnyObject)
    {
        let data:NSDictionary = NSDictionary(objects: [pass.text!, rePass.text!, name.text!], forKeys: ["pass", "rePass", "name"]);
        
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_REG_EVENT, object: data);
    }
    
    func onVerificationBack(no:NSNotification)
    {
        let data:NSDictionary = no.object as! NSDictionary;
        
        let status:Int = data["status"] as! Int;
        let message:String = data["message"] as! String;
        let title:String?;
        
        if(status == 1)
        {
            let data:Dictionary<String, String> = ["name":name.text!, "pass":pass.text!];
            
            NSNotificationCenter.defaultCenter().postNotificationName(UserProxy.REQUEST_RAISE_GUEST_EVENT, object: data);
            
            LoadingView.sharedInstance.startWork(self);
        }
        else
        {
            title = "错误";
            
            AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
        }
    }
    
    func onRequestRaiseGuestBack(no:NSNotification)
    {
        dispatch_async(dispatch_get_main_queue(),
            {
                let data:NSDictionary? = no.object as? NSDictionary;
                
                let status = data!["status"] as! Int;
                let message = data!["message"] as! String;
                
                let showname = data!["showname"] as! String;
                let isguest = data!["isguest"] as! Int;
                
                let title:String?;
                
                LoadingView.sharedInstance.stopWork();
                
                if(status != 1)
                {
                    title = "错误";
                    
                    AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
                }
                else
                {
                    let vc = SDKMain.sharedInstance.board!.instantiateViewControllerWithIdentifier("welcomeVc") as! UINavigationController;
                    
                    let wel = vc.childViewControllers.first as! WelcomeViewController;
                    
                    wel.showName = showname;
                    wel.isGuest = isguest;
                    
                    self.presentViewController(vc, animated: true, completion: nil);
                }
        });
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
