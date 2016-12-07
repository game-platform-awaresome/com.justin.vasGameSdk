//
//  AgreementViewController.swift
//  VasSdkDemo
//
//  Created by justin on 16/6/6.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import iAd

class AgreementViewController: UIViewController, UIAlertViewDelegate, ADBannerViewDelegate {

    @IBOutlet weak var iAd: ADBannerView!;
    
    @IBOutlet weak var iV: UIView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
        
        iAd.hidden = !Common.iADDis;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        IADProxy.sharedInstance.startWork();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AgreementViewController.onIadInfoBack(_:)), name: IADProxy.REQUEST_IAD_INFO_BACK, object: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(IADProxy.REQUEST_IAD_INFO, object: nil, userInfo: nil);
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated);
        
        IADProxy.sharedInstance.stopWork();
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IADProxy.REQUEST_IAD_INFO_BACK, object: nil);
    }
    
    func onIadInfoBack(no:NSNotification)
    {
        let data = no.userInfo;
        
//        print("onIadInfoBack: \(data)");
        
        let status = data!["status"] as! Int;
        
        if(status == 0)
        {
            let idfaDic = data!["data"] as! NSDictionary;
            
            let idfa = idfaDic["idfa"] as! String;
            
//            print("onIadInfoBack: \(idfa)");
            
            if(idfa == "0")
            {
                iAd.hidden = true;
            }
            else
            {
                iAd.hidden = false;
            }
            
//            print("onIadInfoBack: \(iAd.hidden)");
        }
    }

    
    @IBAction func onBack(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func shouldAutorotate() -> Bool
    {
        return Common.shouldAutorotate;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return Common.supportedInterfaceOrientations;
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!)
    {
        print("Ad Banner will load ad.");
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!)
    {
        print("Ad Banner did load ad.");
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!)
    {
        print("Unable to show ads. Error: \(error)");
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
