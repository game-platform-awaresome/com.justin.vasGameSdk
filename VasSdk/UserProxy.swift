//
//  UserProxy.swift
//  VasGameSDK
//
//  Created by justin on 16/1/20.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import VasSdkTool

class UserProxy: NSObject
{
    static var ins:UserProxy!;
    static var token:dispatch_once_t = 0;
    
    static let REQUEST_GUEST_EVENT:String = "request_guest_event";
    static let REQUEST_GUEST_BACK_EVENT:String = "request_guest_back_event";
    
    static let REQUEST_RAISE_GUEST_EVENT:String = "request_raise_guest_event";
    static let REQUEST_RAISE_GUEST_BACK_EVENT:String = "request_raise_guest_back_event";
    
    var userName:String? = "vst007";
    var loginName:String?;
    var bindName:String?;
    var showName:String?;
    var userPass:String?;
    var userId:Int?;
    var bindId:Int?;
    var loginId:Int?;
    
    var tempUName:String?;
    var tempUPass:String?;
    
    var isGuest:Int?;
    
    var userDicArr:[AnyObject]?;
    
    var gcDic:NSDictionary?;
    
    var sessionId:String?;
    
    func clean()
    {
        userName = nil;
        loginName = nil;
        bindName = nil
        showName = nil;
        userPass = nil;
        userId = nil;
        bindId = nil;
        loginId = nil;
        
        tempUName = nil;
        tempUPass = nil;
        
        isGuest = nil;
        
        userDicArr = nil;
        
        gcDic = nil;
        
        sessionId = nil;
    }
    
    func startWork()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserProxy.onRequestGuest(_:)), name: UserProxy.REQUEST_GUEST_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserProxy.onRequestRaiseGuest(_:)), name: UserProxy.REQUEST_RAISE_GUEST_EVENT, object: nil);
    }
    
    func stopWork()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UserProxy.REQUEST_GUEST_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UserProxy.REQUEST_RAISE_GUEST_EVENT, object: nil);
    }
    
    func onRequestRaiseGuest(no:NSNotification)
    {
        let data:Dictionary<String, String>? = no.object as? Dictionary<String, String>;
        
        let rName = data!["name"]!;
        let rPass = data!["pass"]!;
        
        let keyIndex:Int = 4;
        
        let encodePass = ThreeDES.encyrpt(rPass, keyIndex: Int32(keyIndex));
        
        let uName = rName;
        let uPass = encodePass;
        
        let tmD = NSDate().timeIntervalSince1970*1000;
        let tmI = Int(tmD);
        let tm = String(stringInterpolationSegment: tmI);
        
        let str = uName + tm + Common.KEY;
        let sign = getSign(str);
        
        let postStr:String = "username=" + uName
            + "&password=" +  uPass
            + "&bindname=" +  bindName!
            + "&bindid=" +  (bindId?.description)!
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
        
        UserProxy.sharedInstance.tempUName = rName;
        UserProxy.sharedInstance.tempUPass = rPass;
        
        NetProxy.sharedInstance.requestDataByGet(NetCommon.RAISE_GUEST_URL, postStr: postStr, onComplete: onRequestRaiseGuestBack);
    }
    
    func onRequestRaiseGuestBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"]);
            
            NSNotificationCenter.defaultCenter().postNotificationName(UserProxy.REQUEST_GUEST_BACK_EVENT, object: resultDic);
            
            return;
        }
        
        let dataDic:NSDictionary? = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary;
        
        let status:Int = dataDic?["status"] as! Int;
        let message:String = dataDic?["message"] as! String;
        
        var username:String = "";
        var userid:Int = 0;
        var sessionid:String = "";
        var showname:String = "";
        
        var bindid:Int = 0;
        var bindname:String = "";
        
        var isguest:Int = 0;
        
        if(status == 1)
        {
            username = dataDic?["username"] as! String;
            bindname = dataDic?["bindname"] as! String;
            
            userid = dataDic?["userid"] as! Int;
            bindid = Int(dataDic?["bindid"] as! String)!;
            
            showname = dataDic?["showname"] as! String;
            sessionid = dataDic?["sessionid"] as! String;
            
            isguest = dataDic?["isguest"] as! Int;
            
            userName = username;
            loginName = username;
            showName = showname;
            bindName = bindname;
            userId = userid;
            bindId = bindid;
            loginId = userid;
            
            isGuest = isguest;
            
            userPass = tempUPass;
        }
        
        let resultDic:NSDictionary = NSDictionary(objects: [status, message, username, userid, sessionid, showname, isguest], forKeys: ["status", "message", "username", "userid", "sessionid", "showname", "isguest"])
        
        print("onRequestRaiseGuestBack:\(status), \(message), \(sessionid), \(username), \(userid)");
        
        NSNotificationCenter.defaultCenter().postNotificationName(UserProxy.REQUEST_RAISE_GUEST_BACK_EVENT, object: resultDic);

    }
    
    func onRequestGuest(no:NSNotification)
    {
        let tmD = NSDate().timeIntervalSince1970*1000;
        
        let tmI = Int64(tmD);
        
        print("!------------------onRequestGuest: tmI \(tmI)")

        
        let tm = String(stringInterpolationSegment: tmI);
        
        print("!------------------onRequestGuest: tm \(tm)")
        
        let str = tm + Common.KEY;
        let sign = getSign(str);
        
        let postStr:String = "app=" + Common.APP
            + "&f=" + Common.F
            + "&plt=" + Common.PLT
            + "&tm=" + tm
            + "&sign=" + sign
            + "&ext[gc]=" + Common.EXR_GC
            + "&ext[gid]=" + Common.EXT_GID
            + "&ext[cid]=" + Common.EXT_CID
            + "&ext[ccid]=" + Common.EXR_CCID
            + "&puid=" + Common.PUID
            + "&ext[ver]=" + Common.EXT_VER;
        
        NetProxy.sharedInstance.requestDataByGet(NetCommon.GUEST_URL, postStr: postStr, onComplete: onRequestGuestBack);
    }
    
    func onRequestGuestBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"]);
            
            NSNotificationCenter.defaultCenter().postNotificationName(UserProxy.REQUEST_GUEST_BACK_EVENT, object: resultDic);
            
            return;
        }
        
        let dataDic:NSDictionary? = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary;
        
        let status:Int = dataDic?["status"] as! Int;
        let message:String = dataDic?["message"] as! String;
        
        var guestname:String = "";
        var guestpass:String = "";
        var guestid:Int = 0;
        var sessionid:String = "";
        var isguest:Int = 0;
        
        if(status == 1)
        {
            guestname = dataDic?["guestname"] as! String;
            guestpass = dataDic?["guestpass"] as! String;
            guestid = dataDic?["guestid"] as! Int;
            sessionid = dataDic?["sessionid"] as! String;
            isguest = dataDic?["isguest"] as! Int;
            
            userName = guestname;
            loginName = guestname;
            showName = guestname;
            bindName = guestname;
            userId = guestid;
            bindId = guestid;
            loginId = guestid;
            userPass = guestpass;
            isGuest = isguest;
            
            sessionId = sessionid;
        }
        
        let resultDic:NSDictionary = NSDictionary(objects: [status, message, guestname, guestid, sessionid, isguest, guestname], forKeys: ["status", "message", "guestname", "guestid", "sessionid", "isguest", "showname"])
        
        print("resultDic:\(resultDic)");
        
        NSNotificationCenter.defaultCenter().postNotificationName(UserProxy.REQUEST_GUEST_BACK_EVENT, object: resultDic);
    }

    
    func getSign(str:String)->String
    {
        return ThreeDES.md5(str);
    }
    
    static var sharedInstance:UserProxy
    {
        dispatch_once(&UserProxy.token)
            {
                UserProxy.ins = UserProxy();
        }
        
        return UserProxy.ins;
    }
}
