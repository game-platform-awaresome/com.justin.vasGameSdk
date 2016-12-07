//
//  LoginProxy.swift
//  VasGameSDK
//
//  Created by justin on 16/1/5.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import VasSdkTool
import GameKit

class LoginProxy: NSObject
{
    static var ins:LoginProxy!;
    static var token:dispatch_once_t = 0;
    
    static let REQUEST_LOGIN_EVENT:String = "request_login_event";
    static let REQUEST_LOGIN_BACK_EVENT:String = "request_login_back_event";
    
    static let REQUEST_GAMECENTER_LOGIN_EVENT:String = "request_gamecenter_login_event";
    static let REQUEST_GAMECENTER_LOGIN_BACK_EVENT:String = "request_gamecenter_login_back_event";
    
    static var sharedInstance:LoginProxy
    {
        dispatch_once(&LoginProxy.token)
            {
                LoginProxy.ins = LoginProxy();
        }
        
        return LoginProxy.ins;
    }
    
    
    func startWork()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginProxy.onRequestLogin(_:)), name: LoginProxy.REQUEST_LOGIN_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginProxy.onRequestGameCenterLogin(_:)), name: LoginProxy.REQUEST_GAMECENTER_LOGIN_EVENT, object: nil);
    }
    
    func stopWork()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_LOGIN_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_GAMECENTER_LOGIN_EVENT, object: nil);
    }
    
    func onRequestLogin(no:NSNotification)
    {
        let data:Dictionary<String, String>? = no.object as? Dictionary<String, String>;
        
        let rName = data!["name"]!;
        let rPass = data!["pass"]!;
        
        let keyIndex:Int = 4;
        
        let encodePass = ThreeDES.encyrpt(rPass, keyIndex: Int32(keyIndex));
//        print("encodePass: \(encodePass)");
        
        let uName = rName;
        let uPass = encodePass;
        
        let tmD = NSDate().timeIntervalSince1970*1000;
        let tmI = Int64(tmD);
        let tm = String(stringInterpolationSegment: tmI);
        
        let str = uName + tm + Common.PK;
        let sign = getSign(str);
        
        var postStr:String = "username=" + uName
            + "&password=" +  uPass
            + "&app=" + Common.APP
            + "&f=" + Common.F
            + "&plt=" + Common.PLT
            + "&tm=" + tm
            + "&sign=" + sign
            + "&appid=" + Common.APP_ID
            + "&index=" + String(stringInterpolationSegment: keyIndex+1)
            + "&ext[gc]=" + Common.EXR_GC
            + "&ext[gid]=" + Common.EXT_GID
            + "&ext[cid]=" + Common.EXT_CID
            + "&ext[ccid]=" + Common.EXR_CCID
            + "&puid=" + Common.PUID
            + "&ext[ver]=" + Common.EXT_VER;
        
        let rId = data!["id"];
        if(rId != nil)
        {
            let sRId:String = rId!
            postStr += "&userid=" + sRId;
        }
        
        print("post str: \(postStr)");
        
        UserProxy.sharedInstance.tempUName = rName;
        UserProxy.sharedInstance.tempUPass = rPass;
        
        NetProxy.sharedInstance.requestDataByGet(NetCommon.LOGIN_URL, postStr: postStr, onComplete: onRequestLoginBack);
    }
    
    func onRequestLoginBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"])
            
            NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: resultDic);
            
            return;
        }
        
        let dataDic:NSDictionary? = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary;
        
        let isguest:Int = dataDic?["isguest"] as! Int;
        
        var status:Int = 0;
        var message:String = "";
        var username:String = "";
        var userid:Int = 0;
        var sessionid:String = "";
        var showname:String = "";
        
        var phone:String?;
        
        var bindId:String?;
        var bindName:String?;
        
        status = dataDic?["status"] as! Int;
        message = dataDic?["message"] as! String;
        
        phone = dataDic?["mobile"] as? String
        
        if(status == 1)
        {
            if(isguest == 0)
            {
                bindId = dataDic?["bindid"] as? String;
                bindName = dataDic?["bindname"] as? String;
                
                username = dataDic?["username"] as! String;
                userid = dataDic?["userid"] as! Int;
                sessionid = dataDic?["sessionid"] as! String;
                showname = dataDic?["showname"] as! String;
            }
            else
            {
                username = dataDic?["guestname"] as! String;
                userid = Int(dataDic?["guestid"] as! String)!;
                sessionid = dataDic?["sessionid"] as! String;
                showname = username;
            }
            
            print("onRequestLoginBack bindid:\(bindId)");
            
            if(bindId != nil)
            {
                UserProxy.sharedInstance.userName = username;
                UserProxy.sharedInstance.loginName = username;
                UserProxy.sharedInstance.showName = showname;
                UserProxy.sharedInstance.bindName = bindName!;
                UserProxy.sharedInstance.userId = userid;
                UserProxy.sharedInstance.bindId = Int(bindId!);
                UserProxy.sharedInstance.loginId = userid;
            }
            else
            {
                UserProxy.sharedInstance.userName = username;
                UserProxy.sharedInstance.loginName = username;
                UserProxy.sharedInstance.showName = showname;
                UserProxy.sharedInstance.bindName = username;
                UserProxy.sharedInstance.userId = userid;
                UserProxy.sharedInstance.bindId = userid;
                UserProxy.sharedInstance.loginId = userid;
            }
            
            if(phone != nil && phone != "")
            {
                UserProxy.sharedInstance.userName = phone;
            }
            
            UserProxy.sharedInstance.userPass = UserProxy.sharedInstance.tempUPass;
            UserProxy.sharedInstance.isGuest = isguest;
            
            UserProxy.sharedInstance.sessionId = sessionid;
        }
        
        let resultDic:NSDictionary = NSDictionary(objects: [status, message, username, userid, sessionid, isguest, showname], forKeys: ["status", "message", "username", "userid", "sessionid", "isguest", "showname"]);
        
        print("onRequestLoginBack:\(dataDic)");
        
        NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: resultDic);
    }
    
    func getSign(str:String)->String
    {
        return ThreeDES.md5(str);
    }
    
    
    func onRequestGameCenterLogin(no:NSNotification)
    {
        loginGameCenter();
    }
    
    func loginGameCenter()
    {
        if(isGameCenterAvailable())
        {
            authenticateLocalPlayer();
        }
    }
    
    func isGameCenterAvailable()->Bool
    {
        let gcClass:AnyClass? = NSClassFromString("GKLocalPlayer");
        
        let regSysVer:String = "4.1";
        
        let currSysVer = UIDevice.currentDevice().systemVersion;
        
        print("currSysVer: \(currSysVer)");
        
        let onVersionSupported = currSysVer.compare(regSysVer, options: NSStringCompareOptions.NumericSearch, range: nil, locale: nil) != NSComparisonResult.OrderedAscending;
        
        if(gcClass != nil && onVersionSupported)
        {
            return true;
        }
        
        return false;
    }
    
    func authenticateLocalPlayer()
    {
//        GKLocalPlayer.localPlayer().authenticated = false;
        
        GKLocalPlayer.localPlayer().authenticateHandler = authenticateHandlerFunc;
    }
    
    func authenticateHandlerFunc(vc:UIViewController?, error:NSError?)
    {
        if(error != nil)
        {
            print("authenticate 失败 \(error)");
            
            NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil, userInfo:["code":0, "message":"出错代码：" + (error?.code)!.description, "vc":NSNull(), "data":NSNull()]);
        }
        else
        {
//            print("authenticate 成功");
            
            print("playerID: \(GKLocalPlayer.localPlayer().playerID)");
            
            print("alias: \(GKLocalPlayer.localPlayer().alias)");
            
            let playerID = GKLocalPlayer.localPlayer().playerID;
            let alias = GKLocalPlayer.localPlayer().alias;
            
//            let data:NSDictionary = NSDictionary(objects: [GKLocalPlayer.localPlayer().playerID, GKLocalPlayer.localPlayer().alias], forKeys: ["playerID", "alias"])
            
            let data:NSMutableDictionary = NSMutableDictionary();
            
            if(playerID != nil)
            {
                data.setValue(playerID, forKeyPath: "playerID");
            }
            else
            {
                data.setValue(nil, forKeyPath: "playerID");

            }
            
            if(alias != nil)
            {
                data.setValue(alias, forKeyPath: "alias");
            }
            else
            {
                data.setValue(nil, forKeyPath: "alias");
                
            }
            
            if(playerID != nil)
            {
                if(vc != nil)
                {
                    NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil, userInfo:["code":100, "message":"成功", "vc":vc!, "data":data]);
                }
                else
                {
                    NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil, userInfo:["code":100, "message":"成功", "vc":NSNull(), "data":data]);
                }
            }
            else
            {
                if(vc != nil)
                {
                    NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil, userInfo:["code":0, "message":"登陆失败", "vc":vc!, "data":data]);
                }
                else
                {
                    NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil, userInfo:["code":0, "message":"登陆失败", "vc":NSNull(), "data":data]);
                }
            }
            
            
//            NSNotificationCenter.defaultCenter().postNotificationName(LoginProxy.REQUEST_GAMECENTER_LOGIN_BACK_EVENT, object: nil, userInfo:["code":100, "message":"成功"]);
        }
    }
}
