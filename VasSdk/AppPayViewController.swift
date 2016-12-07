//
//  AppPayViewController.swift
//  VasGameSDK
//
//  Created by justin on 16/3/10.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import StoreKit

class AppPayViewController: UIViewController
{
    static var ins:AppPayViewController!;
    static var token:dispatch_once_t = 0;
    
    static var sharedInstance:AppPayViewController
    {
        dispatch_once(&AppPayViewController.token)
            {
                AppPayViewController.ins = AppPayViewController();
        }
        
        return AppPayViewController.ins;
    }
    
    var parentVc:UIViewController?;
    
    var alert:UIAlertController?;
    
    var isWorking:Bool = false;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startWork(pVc:UIViewController)
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppPayViewController.onRequestProductBack(_:)), name: AppPayProxy.REQUEST_PRODUCT_BACK, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppPayViewController.onRequestProductBuyBack(_:)), name: AppPayProxy.REQUEST_BUY_PRODUCT_BACK, object: nil);
        
        isWorking = true;
        
        parentVc = pVc;

    }
    
    func stopWork()
    {
        AppPayProxy.sharedInstance.stopWork();
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AppPayProxy.REQUEST_PRODUCT_BACK, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AppPayProxy.REQUEST_BUY_PRODUCT_BACK, object: nil);
        
        isWorking = false;
        
        parentVc = nil;
    }

    
    func onRequestProductBuyBack(n:NSNotification)
    {
        stopWork();
        
        alert?.dismissViewControllerAnimated(false, completion: nil);
    }
    
    func onRequestProductBack(n:NSNotification)
    {
        let alertController = UIAlertController(title: "商品列表", message: "请选择要购买的内容", preferredStyle: UIAlertControllerStyle.Alert);
        
        let resultDic = n.userInfo;
        let productDic = resultDic!["data"] as! NSDictionary;
        
        for p in productDic.allValues
        {
            let eP = p as! SKProduct;
            
            let action = ProductAlertAction(title: eP.localizedDescription, style: UIAlertActionStyle.Default, handler: onProductClick);
            
            action.data = eP;
            alertController.addAction(action);

        }
        
        parentVc!.presentViewController(alertController, animated: true, completion: nil);
        
        alert = alertController;
    }
    
    @available(iOS 8.0, *)
    func onProductClick(u:UIAlertAction)
    {
        let eP = u as! ProductAlertAction;
        
        let data = eP.data?.productIdentifier;
        
        NSNotificationCenter.defaultCenter().postNotificationName(AppPayProxy.REQUEST_BUY_PRODUCT, object: nil, userInfo: ["productId":data!]);
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
