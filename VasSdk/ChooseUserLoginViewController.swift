//
//  ChooseUserLoginViewController.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/13.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class ChooseUserLoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var loginBtn: ColorButton!
    @IBOutlet weak var iV: UIView!
    @IBOutlet weak var tV: UITableView!;
    @IBOutlet weak var nameL: UILabel!;
    
    var curData:NSDictionary?;
    
    static let DROP_DOWN_MENU:String = "drop_down_menu";
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
        
        loginBtn.setBackgroundImageColor(ColorButton.oC , hColor: UIColor.grayColor().CGColor);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        
        
        LoginProxy.sharedInstance.startWork();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChooseUserLoginViewController.onRequestLoginBack(_:)), name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
        
//        name.text = UserProxy.sharedInstance.userName;
        nameL.text = UserProxy.sharedInstance.userName;
        
        tV.hidden = true;
        
        curData = UserProxy.sharedInstance.userDicArr?.last as? NSDictionary;
//        name.text = curData!["uName"] as? String;
        
        if(curData != nil)
        {
            nameL.text = curData!["uName"] as? String;
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
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var num:Int = 0;
        
        if(UserProxy.sharedInstance.userDicArr != nil)
        {
            num = UserProxy.sharedInstance.userDicArr!.count;
        }
       
        return num;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cTCell", forIndexPath: indexPath) ;
        
        if(UserProxy.sharedInstance.userDicArr != nil)
        {
            let data:NSDictionary! = UserProxy.sharedInstance.userDicArr![indexPath.row] as! NSDictionary;
            
            (cell.contentView.viewWithTag(1) as! UILabel).text = data["uName"] as? String;
            
            (cell.contentView.viewWithTag(2) as! CellButton).row = indexPath.row;
        }
        
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let data:NSDictionary! = UserProxy.sharedInstance.userDicArr![indexPath.row] as! NSDictionary;
        curData = data;
//        name.text = curData!["uName"] as? String;
        nameL.text = curData!["uName"] as? String;
        
        tV.hidden = true;
    }

    @IBAction func onDel(sender: CellButton)
    {
        let data = UserProxy.sharedInstance.userDicArr![sender.row] as? NSDictionary;
        
        NSNotificationCenter.defaultCenter().postNotificationName(UserDefaultsProxy.DEL_LOCAL_USER, object: nil, userInfo: ["name":data!["uName"]!]);
        
        tV.reloadData();
        
        curData = UserProxy.sharedInstance.userDicArr?.last as? NSDictionary;
        
        if(curData != nil)
        {
//            name.text = curData!["uName"] as? String;
            nameL.text = curData!["uName"] as? String;
        }
        else
        {
//            name.text = "";
            nameL.text = "";
        }
    }
    
    @IBAction func onChoose(sender: AnyObject)
    {
        tV.hidden = !tV.hidden;
        
        NSNotificationCenter.defaultCenter().postNotificationName(ChooseUserLoginViewController.DROP_DOWN_MENU, object: nil);
    }

    @IBAction func onLogin(sender: AnyObject)
    {
        if(curData == nil)
        {
            let title:String? = "没有帐号";
            let message:String = "请选择其它方式登陆";
            
            AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
            
            return;
        }
        
        let data:Dictionary<String, String>?;
        
        let isGuest:Int? = curData!["isGuest"] as? Int;
        
        if(isGuest == 0)
        {
            data = ["name":curData!["uName"] as! String, "pass":curData!["uPass"] as! String];
        }
        else
        {
            data = ["name":curData!["uName"] as! String, "pass":curData!["uPass"] as! String, "id":(curData!["uId"] as! Int).description];

        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_LOGIN_EVENT, object: data!);
        
        tV.hidden = true;
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.NEXT, object: nil, userInfo: ["fukey":BipProxy.CHOOSE_USER_LOGIN_PAGE, "ukey":BipProxy.CHOOSE_USER_LOGIN_PAGE]);
        
        LoadingView.sharedInstance.startWork(self);
    
    }
    
    @IBAction func onBack(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(false, completion: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.BACK, object: nil, userInfo: ["fukey":BipProxy.CHOOSE_USER_LOGIN_PAGE, "ukey":BipProxy.AUTO_LOGIN_PAGE]);
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func shouldAutorotate() -> Bool
    {
        return Common.shouldAutorotate;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return Common.supportedInterfaceOrientations;
    }
}
