//
//  WelcomeViewController.swift
//  VasGameSDK
//
//  Created by justin on 16/1/21.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!;
    @IBOutlet weak var gCoin: UILabel!;
    @IBOutlet weak var rPass: UIButton!;
    @IBOutlet weak var rGuest: UIButton!;
    
    var showName:String = "";
    var isGuest:Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        userName.text = showName;
        
        if(isGuest != 1)
        {
            rGuest.enabled = false;
        }
        else
        {
            rPass.enabled = false;
        }
        
        let data:Dictionary<String, String> = ["name":UserProxy.sharedInstance.userName!];
        
        NSNotificationCenter.defaultCenter().postNotificationName(GCoinProxy.REQUEST_GCOIN_EVENT, object: data, userInfo: nil);
//        print("REQUEST_GCOIN_EVENT");
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WelcomeViewController.onRequestGCoinBack(_:)), name: GCoinProxy.REQUEST_GCOIN_BACK_EVENT, object: nil);
        
        LoadingView.sharedInstance.startWork(self);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onRequestGCoinBack(no:NSNotification)
    {
        dispatch_async(dispatch_get_main_queue(),
            {
                let data:NSDictionary? = no.object as? NSDictionary;
                
                let status = data!["status"] as! Int;
                let message = data!["message"] as! String;
                
                let title:String?;
                
                if(status != 1)
                {
                    title = "错误";
                    
                    AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
                }
                else
                {
                    let result:NSDictionary = data!["gCoinData"] as! NSDictionary;
                    
//                    print("\(result["coin_balance"]!["ext"]!)");
                    let coin_balance = result["coin_balance"] as! NSDictionary;
                    
                    let ext2 = coin_balance["ext2"] as! Int;
                    
                    let ext2Str:String = ext2.description;
                    
                    self.gCoin.text = "剩余G币:" + ext2Str;
//                        + ((result["coin_balance"]!["ext2"] as? Int)?.description)!;
                }
                
                LoadingView.sharedInstance.stopWork();
        });
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "gotoPayVc")
        {
            let vc = segue.destinationViewController as! PayViewController;
            
            vc.showName = showName;
        }
    }
    
    @IBAction func onApplePay(sender: AnyObject)
    {
//        SDKMain.sharedInstance.startApplePay(["com.pptv.vas.game.30y","com.pptv.vas.game.6y"], ifDisWin: true, parentVc: self);

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
