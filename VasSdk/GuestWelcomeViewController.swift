//
//  GuestWelcomeViewController.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/12.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class GuestWelcomeViewController: UIViewController {

    @IBOutlet weak var raise: ColorButton!;
    @IBOutlet weak var start: ColorButton!;
    @IBOutlet weak var iV: UIView!;
    
    static let GOTO_GUEST:String = "goto_guest";
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
        
        raise.setBackgroundImageColor(ColorButton.oC , hColor: UIColor.grayColor().CGColor);
        start.setBackgroundImageColor(UIColor.blackColor().CGColor , hColor: UIColor.grayColor().CGColor);
    }
    
    @IBAction func onRasie(sender: AnyObject)
    {
        self.performSegueWithIdentifier("guestGotoReg", sender: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(RegChooseViewController.GOTO_REG_CHOOSE, object: nil, userInfo: ["fukey":BipProxy.GUEST_RASIE_PAGE, "ukey":BipProxy.REG_CHOOSE_PAGE]);
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        
        
//        print("viewWillAppear... raise.bounds:\(raise.bounds), raise.frame:\(raise.frame)")
        
        LoginProxy.sharedInstance.startWork();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GuestWelcomeViewController.onRequestLoginBack(_:)), name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(GuestWelcomeViewController.GOTO_GUEST, object: nil);
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
        
//        print("viewDidAppear... raise.bounds:\(raise.bounds), raise.frame:\(raise.frame)")
        
        
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated);
        
        LoginProxy.sharedInstance.stopWork();
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickRaise(sender: AnyObject)
    {
        
    }
    
    @IBAction func onClickStart(sender: AnyObject)
    {
        let data:Dictionary<String, String>?;
        
        data = ["name":UserProxy.sharedInstance.userName!, "pass":UserProxy.sharedInstance.userPass!, "id":(UserProxy.sharedInstance.userId?.description)!];
        
        NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_LOGIN_EVENT, object: data, userInfo: nil);
        
        LoadingView.sharedInstance.startWork(self);
    }
    
    func onRequestLoginBack(no:NSNotification)
    {
        dispatch_async(dispatch_get_main_queue(),
                       {
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
                            BipProxy.sharedInstance.stat = "2";
                            BipProxy.sharedInstance.sendBip(BipProxy.LOGIN_SUC, fukey: BipProxy.GUEST_RASIE_PAGE, ukey: BipProxy.GUEST_RASIE_PAGE);
                            
                            SDKMain.sharedInstance.clearSDKUi();
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
