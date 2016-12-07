//
//  WelcomeProxy.swift
//  VasGameSDK
//
//  Created by justin on 16/1/13.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import VasSdkTool

class UserDefaultsProxy: NSObject
{
    static var ins:UserDefaultsProxy!;
    static var token:dispatch_once_t = 0;
    
    static var sharedInstance:UserDefaultsProxy
    {
        dispatch_once(&UserDefaultsProxy.token)
        {
            UserDefaultsProxy.ins = UserDefaultsProxy();
        }
        
        return UserDefaultsProxy.ins;
    }
    
    
    static let DEL_LOCAL_USER:String = "del_loacal_user";
    static let UPDATE_LOCAL_USER_BACK:String = "update_local_user_back";
    
    static let UPDATE_GC_INFO:String = "update_gc_info";
    
    
    func startWork()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserDefaultsProxy.onRequestRegBack(_:)), name: RegProxy.REQUEST_REG_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserDefaultsProxy.onRequestPhoneRegBack(_:)), name: RegProxy.REQUEST_PHONE_REG_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserDefaultsProxy.onRequestLoginBack(_:)), name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserDefaultsProxy.onRequestGuestBack(_:)), name: UserProxy.REQUEST_GUEST_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserDefaultsProxy.onDelLocalUser(_:)), name: UserDefaultsProxy.DEL_LOCAL_USER, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserDefaultsProxy.onGcBack(_:)), name: UserDefaultsProxy.UPDATE_GC_INFO, object: nil);
    }
    
    func stopWork()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RegProxy.REQUEST_REG_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RegProxy.REQUEST_PHONE_REG_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UserProxy.REQUEST_GUEST_BACK_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UserDefaultsProxy.DEL_LOCAL_USER, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil);
    }
    
    func onGcBack(no:NSNotification)
    {
//        let code = no.userInfo!["code"] as! Int;
//        
        let data = no.userInfo!["data"] as? NSDictionary;
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        userDefaults.setObject(data, forKey: "gc");
    }
    
    func onDelLocalUser(no:NSNotification)
    {
        let bName:String = no.userInfo!["name"] as! String;
        print(bName);
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        var userDicArr = userDefaults.arrayForKey("userDicArr");
        
        if(userDicArr == nil)
        {
            return;
        }
        
        let c = (userDicArr?.count)!-1;
        
        if(c >= 0)
        {
            for i in 0...c
            {
                let u = userDicArr![i];
                
                let lUName = (u as! NSDictionary)["uName"] as! String;
                
                if(lUName == bName)
                {
                    userDicArr?.removeAtIndex(i);
                    
                    break;
                }
            }
        }
        
        userDefaults.setObject(userDicArr, forKey: "userDicArr");
        
        UserProxy.sharedInstance.userDicArr = userDicArr;
    }
    
    func onRequestGuestBack(no:NSNotification)
    {
        let data:NSDictionary? = no.object as? NSDictionary;
        
        let status = data!["status"] as! Int;
        
        if(status == 1)
        {
            UserDefaultsProxy.sharedInstance.setUserDefaults(UserProxy.sharedInstance.userName!,  uPass: UserProxy.sharedInstance.userPass!, uId: UserProxy.sharedInstance.userId!, isGuest: UserProxy.sharedInstance.isGuest!);
        }
    }
    
    func onRequestLoginBack(no:NSNotification)
    {
        let data:NSDictionary? = no.object as? NSDictionary;
        
        let status = data!["status"] as! Int;
        
        if(status == 1)
        {
            UserDefaultsProxy.sharedInstance.setUserDefaults(UserProxy.sharedInstance.userName!, uPass: UserProxy.sharedInstance.tempUPass!, uId: UserProxy.sharedInstance.userId!, isGuest: UserProxy.sharedInstance.isGuest!);
        }
    }
    
    func onRequestRegBack(no:NSNotification)
    {
        let data:NSDictionary? = no.object as? NSDictionary;
        
        let status = data!["status"] as! Int;
        
        if(status == 1)
        {
            if(UserProxy.sharedInstance.bindName != nil)
            {
                updateGuest(UserProxy.sharedInstance.bindName!);
            }
            
            UserDefaultsProxy.sharedInstance.setUserDefaults(UserProxy.sharedInstance.userName!, uPass: UserProxy.sharedInstance.tempUPass!, uId: UserProxy.sharedInstance.userId!, isGuest: UserProxy.sharedInstance.isGuest!);
        }
    }
    
    func onRequestPhoneRegBack(no:NSNotification)
    {
        let data:NSDictionary? = no.object as? NSDictionary;
        
        let status = data!["status"] as! Int;
        
        if(status == 1)
        {
            if(UserProxy.sharedInstance.bindName != nil)
            {
                updateGuest(UserProxy.sharedInstance.bindName!);
            }
            
            UserDefaultsProxy.sharedInstance.setUserDefaults(UserProxy.sharedInstance.tempUName!, uPass: UserProxy.sharedInstance.tempUPass!, uId: UserProxy.sharedInstance.userId!, isGuest: UserProxy.sharedInstance.isGuest!);
        }
    }
    
    func getUserDefaults()
    {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        let userDicArr = userDefaults.arrayForKey("userDicArr");
        
        if(userDicArr != nil)
        {
            UserProxy.sharedInstance.userDicArr = userDicArr;
            
            if(userDicArr?.count != 0)
            {
                let userDic = userDicArr?.last as! NSDictionary;
                
                let userName:String? = userDic["uName"] as? String;
                let userPass:String? = userDic["uPass"] as? String;
                let userId:Int? = userDic["uId"] as? Int;
                let isGuest:Int? = userDic["isGuest"] as? Int;
                
                if(userName != nil)
                {
                    UserProxy.sharedInstance.userName = userName;
                }
                
                if(userPass != nil)
                {
                    UserProxy.sharedInstance.userPass = userPass;
                }
                
                if(userId != nil)
                {
                    UserProxy.sharedInstance.userId = userId;
                }
                
                if(isGuest != nil)
                {
                    UserProxy.sharedInstance.isGuest = isGuest;
                }
            }
        }
        
        let gcDic = userDefaults.objectForKey("gc") as? NSDictionary;
        
        if(gcDic != nil)
        {
            UserProxy.sharedInstance.gcDic = gcDic;
        }
        
    }
    
    func updateGuest(bName:String)
    {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        var userDicArr = userDefaults.arrayForKey("userDicArr");
        
        if(userDicArr == nil)
        {
            return;
        }
        
        let c = (userDicArr?.count)!-1;
        
        if(c >= 0)
        {
            for i in 0...c
            {
                let u = userDicArr![i];
                
                let lUName = (u as! NSDictionary)["uName"] as! String;
                let lIsGuest = (u as! NSDictionary)["isGuest"] as! Int;
                
                if(lIsGuest != 0 && lUName == bName)
                {
                    userDicArr?.removeAtIndex(i);
                    
                    break;
                }
            }
        }
        
        userDefaults.setObject(userDicArr, forKey: "userDicArr");
    }
    
    func setUserDefaults(uName:String, uPass:String, uId:Int, isGuest:Int)
    {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        let userDic = NSDictionary(objects: [uName, uPass, uId, isGuest], forKeys: ["uName", "uPass", "uId", "isGuest"]);
        
        var userDicArr = userDefaults.arrayForKey("userDicArr");
        
        if(userDicArr == nil)
        {
            userDicArr = [];
        }
        
//        var hasLocal:Bool = false;
        
        let c = (userDicArr?.count)!-1;
        
        if(c >= 0)
        {
            for i in 0...c
            {
                let u = userDicArr![i];
                
                let lUName = (u as! NSDictionary)["uName"] as! String;
                
                if(lUName == uName)
                {
                    userDicArr?.removeAtIndex(i);
                    
                    break;
                }
            }
        }
        
        userDicArr?.append(userDic);

        
//        userDefaults.setValue(userDicArr, forKey: "userDicArr");
        userDefaults.setObject(userDicArr, forKey: "userDicArr");
        
        userDefaults.removeObjectForKey("gc");
    }
    
    func getStartNum()->Int
    {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        let num:Int? = userDefaults.integerForKey("vasGameSDKStartNum");
        
        if(num != nil)
        {
            return num!;
        }
        
        return 0;
    }
    
    func setStartNum(num:Int)
    {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        userDefaults.setInteger(num, forKey: "vasGameSDKStartNum");
    }
    
    func getUUID()->String
    {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        var uuid = userDefaults.stringForKey("uuid");
        
        if(uuid == nil)
        {
            uuid = NSUUID().UUIDString;
            userDefaults.setValue(uuid, forKey: "uuid");
        }
        
        return uuid!;
    }
}
