//
//  SDKMain.swift
//  VasGameSDK
//
//  Created by justin on 15/12/22.
//  Copyright © 2015年 justin. All rights reserved.
//

import UIKit
import VasSdkTool
import AdSupport

public class SDKMain: NSObject
{
    static let INIT_SDK:String = "init_sdk";
    static let START_GAME:String = "start_game";
    static let NEXT:String = "next";
    static let BACK:String = "back";
    
    static public let SDK_CLOSE:String = "sdk_close";
    static public let APPLE_PRODUCT_INFO_BACK:String = "apple_product_info_back";
    static public let APPLE_PRODUCT_BUY_RESULT:String = "apple_product_buy_result";
    
    public static var adid:NSString = "";
    
    var board:UIStoryboard?;
    
    var startVc:UIViewController?;
    
    public static func initSDK(gid:String = "demo", shouldAutorotate:Bool = true, supportedInterfaceOrientations:UIInterfaceOrientationMask = UIInterfaceOrientationMask.All, puid:String = "", cid:String = "demo", chid:String = "demo", ccid:String = "demo")
    {
//        LoginProxy.sharedInstance.startWork();
//        RegProxy.sharedInstance.startWork();
        UserDefaultsProxy.sharedInstance.startWork();
        BipProxy.sharedInstance.startWork();
//        VerificationProxy.sharedInstance.startWork();
//        UserProxy.sharedInstance.startWork();
//        GCoinProxy.sharedInstance.startWork();
//        PassProxy.sharedInstance.startWork();
//        print("GCoinProxy.sharedInstance.startWork()")
//        
        UserDefaultsProxy.sharedInstance.getUserDefaults();
        Common.startNum = UserDefaultsProxy.sharedInstance.getStartNum();
        
        if(puid == "")
        {
            let uuid = UserDefaultsProxy.sharedInstance.getUUID();
            Common.PUID = uuid;
            BipProxy.sharedInstance.puid = uuid;
        }
        else
        {
            Common.PUID = puid;
            BipProxy.sharedInstance.puid = puid;
        }
        
        BipProxy.sharedInstance.cid = cid;
        BipProxy.sharedInstance.chid = chid;
        BipProxy.sharedInstance.ccid = ccid;
        
        BipProxy.sharedInstance.gid = gid;
        
        Common.APP_ID = gid;
        Common.EXT_GID = gid;
        
//        let allPath:NSString = NSBundle.mainBundle().bundlePath;
//        let bundlePath:NSString = NSString(format: "%@/Frameworks/VasSDK.framework", allPath);
//        let frameworkBundle:NSBundle = NSBundle(path: bundlePath as String)!;
        
        
        let resPath:NSString = NSBundle.mainBundle().resourcePath!;
        
        let path:NSString = resPath.stringByAppendingPathComponent("Frameworks/VasSdk.framework");
        
        let frameworkBundle:NSBundle = NSBundle(path: path as String)!;

        SDKMain.sharedInstance.board = UIStoryboard(name: "Sy", bundle: frameworkBundle);
        
//        print("!----------------SDK initSDK: board is \(board)");
        
//        let vc = SDKMain.sharedInstance.board!.instantiateViewControllerWithIdentifier("firstVC") as UIViewController;
//        
//        print("!----------------SDK initSDK: firstVC is \(vc)");
        
         print("!----------------SDK initSDK: uuid is \(Common.PUID)");

//        UIApplication.sharedApplication().idleTimerDisabled = idleTimerDisabled;
        
        Common.shouldAutorotate = shouldAutorotate;
        Common.supportedInterfaceOrientations = supportedInterfaceOrientations;
        
        let adid:NSString = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString;
        SDKMain.adid = adid;
    }
    
    public static func clearSDK()
    {
        UserDefaultsProxy.sharedInstance.stopWork();
        BipProxy.sharedInstance.stopWork();
        
        UserProxy.sharedInstance.clean();
    }
    
    func printPath(dirString:String)
    {
        let fileManager:NSFileManager = NSFileManager.defaultManager();
        
        let enumerator:NSDirectoryEnumerator! = fileManager.enumeratorAtPath(dirString);
        
        while let element = enumerator?.nextObject() as? String
        {
            print(element);
        }
    }
    
    public static func strartFirstUi(parentVc:UIViewController)
    {
//        print(ThreeDES.encodeInBip("helloworld"));
        
        if(UserProxy.sharedInstance.gcDic != nil)
        {
            let vc = SDKMain.sharedInstance.board!.instantiateViewControllerWithIdentifier("autoLogin") as UIViewController;
            parentVc.presentViewController(vc, animated: false, completion: nil);
            
            SDKMain.sharedInstance.startVc = vc;
            
            var info:[NSObject:AnyObject]?;
            info = ["fukey":BipProxy.AUTO_LOGIN_PAGE, "ukey":BipProxy.AUTO_LOGIN_PAGE];
            NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.INIT_SDK, object: nil, userInfo: info);
        }
        else if(UserProxy.sharedInstance.userName != nil)
        {
            var info:[NSObject:AnyObject]?;
            
            if(UserProxy.sharedInstance.isGuest != 0)
            {
                let vc = SDKMain.sharedInstance.board!.instantiateViewControllerWithIdentifier("welcomeGuest") as UIViewController;
                parentVc.presentViewController(vc, animated: false, completion: nil);
                
                SDKMain.sharedInstance.startVc = vc;
                
                info = ["fukey":BipProxy.GUEST_RASIE_PAGE, "ukey":BipProxy.GUEST_RASIE_PAGE];
            }
            else
            {
                let vc = SDKMain.sharedInstance.board!.instantiateViewControllerWithIdentifier("autoLogin") as UIViewController;
                
//                print("vc: \(vc)");
//                print("parentVc: \(parentVc)");

                
                parentVc.presentViewController(vc, animated: false, completion: nil);
                
                SDKMain.sharedInstance.startVc = vc;
                
                info = ["fukey":BipProxy.AUTO_LOGIN_PAGE, "ukey":BipProxy.AUTO_LOGIN_PAGE];
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.INIT_SDK, object: nil, userInfo: info);
        }
        else if(Common.startNum == 0)
        {
//            print("!----------------SDK in strartFirstUi:");
//            print("!----------------SDK strartFirstUi: SDKMain.sharedInstance is \(SDKMain.sharedInstance)");
//            print("!----------------SDK strartFirstUi: board is \(SDKMain.sharedInstance.board)");
            
            let vc = SDKMain.sharedInstance.board!.instantiateViewControllerWithIdentifier("firstVC") as UIViewController;
            
//            print("vc: \(vc)");
//            print("parentVc: \(parentVc)");
            
            parentVc.presentViewController(vc, animated: false, completion: nil);
            
            SDKMain.sharedInstance.startVc = vc;
            
            NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.INIT_SDK, object: nil, userInfo: ["fukey":"", "ukey":""]);
        }
        else
        {
            let vc = SDKMain.sharedInstance.board!.instantiateViewControllerWithIdentifier("loginChoose") as UIViewController;
            
            parentVc.presentViewController(vc, animated: false, completion: nil);
            
            SDKMain.sharedInstance.startVc = vc;
            
            var info:[NSObject:AnyObject]?;
            info = ["fukey":BipProxy.LOGIN_CHOOSE_PAGE, "ukey":BipProxy.LOGIN_CHOOSE_PAGE];
            NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.INIT_SDK, object: nil, userInfo: info);
        }
        
        UserDefaultsProxy.sharedInstance.setStartNum(Common.startNum+1);
    }
    
    public func startLoginUi(parentVc:UIViewController)
    {
        if(UserProxy.sharedInstance.userName != nil)
        {
            let vc = board!.instantiateViewControllerWithIdentifier("loginVc") as UIViewController;
            
            parentVc.presentViewController(vc, animated: false, completion: nil);
            
            LoadingView.sharedInstance.startWork(vc);
            
            let data:Dictionary<String, String>?;
            
            if(UserProxy.sharedInstance.isGuest == 0)
            {
                data = ["name":UserProxy.sharedInstance.userName!, "pass":UserProxy.sharedInstance.userPass!];
            }
            else
            {
                data = ["name":UserProxy.sharedInstance.userName!, "pass":UserProxy.sharedInstance.userPass!, "id":(UserProxy.sharedInstance.userId?.description)!];
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_LOGIN_EVENT, object: data!);
        }
        else
        {
            let vc = board!.instantiateViewControllerWithIdentifier("regVc") as UIViewController;
            
            parentVc.presentViewController(vc, animated: true, completion: nil);
        }
    }
    
    public func clearSDKUi()
    {
        var backInfo:[NSObject:AnyObject] = ["stat":BipProxy.sharedInstance.stat];
        
        if(UserProxy.sharedInstance.userName != nil)
        {
            backInfo.updateValue(UserProxy.sharedInstance.userName!, forKey: "username");
        }
        
        if(UserProxy.sharedInstance.userId != nil)
        {
            backInfo.updateValue(UserProxy.sharedInstance.userId!, forKey: "userid");
        }
        
        if(UserProxy.sharedInstance.sessionId != nil)
        {
            backInfo.updateValue(UserProxy.sharedInstance.sessionId!, forKey: "sessionid");
        }
        
        if(UserProxy.sharedInstance.bindName != nil)
        {
            backInfo.updateValue(UserProxy.sharedInstance.bindName!, forKey: "bindname");
        }
        
        if(UserProxy.sharedInstance.bindId != nil)
        {
            backInfo.updateValue(UserProxy.sharedInstance.bindId!, forKey: "bindid");
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.SDK_CLOSE, object: nil, userInfo: backInfo);
        
        var cV = startVc;
        var lV:UIViewController?;
        
        while(cV?.presentedViewController != nil)
        {
            lV = cV;
            cV = cV?.presentedViewController;
            lV?.dismissViewControllerAnimated(false, completion: nil);
        }
        
        while(cV?.presentingViewController != nil)
        {
            lV = cV;
//            print("lV:\(lV)")
            cV = cV?.presentingViewController;
//            print("cV:\(cV)")
            lV?.dismissViewControllerAnimated(false, completion: nil);
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.START_GAME, object: nil);
        
        UserDefaultsProxy.sharedInstance.stopWork();
        BipProxy.sharedInstance.stopWork();
        
        UserProxy.sharedInstance.clean();
    }
    
    public static func stopApplePay()
    {
        AppPayProxy.sharedInstance.stopWork();
        
        AppPayViewController.sharedInstance.stopWork();
    }
    
    public static func startApplePay(pIdArr:[String], ifDisWin:Bool = false, parentVc:UIViewController? = nil)
    {
        if(!AppPayProxy.sharedInstance.isWorking)
        {
            AppPayProxy.sharedInstance.startWork();

        }
        
        let info:[NSObject:AnyObject]?;
        
        info = ["pIdArr":pIdArr];
        
        if(!AppPayViewController.sharedInstance.isWorking && ifDisWin && parentVc != nil)
        {
            AppPayViewController.sharedInstance.startWork(parentVc!);
        }
        else if(!ifDisWin && AppPayViewController.sharedInstance.isWorking)
        {
            AppPayViewController.sharedInstance.stopWork();
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(AppPayProxy.REQUEST_PRODUCT, object: nil, userInfo: info);
    }
    
    public static func buyAppleProduct(id:String)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(AppPayProxy.REQUEST_BUY_PRODUCT, object: nil, userInfo: ["productId":id]);
    }
    
    public static let sharedInstance = SDKMain();
}
