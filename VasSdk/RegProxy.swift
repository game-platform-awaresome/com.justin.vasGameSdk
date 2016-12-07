//
//  RegProxy.swift
//  VasGameSDK
//
//  Created by justin on 16/1/7.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import VasSdkTool

class RegProxy: NSObject
{
    static var ins:RegProxy!;
    static var token:dispatch_once_t = 0;
    
    
    static var sharedInstance:RegProxy
    {
        dispatch_once(&RegProxy.token)
            {
                RegProxy.ins = RegProxy();
        }
        
        return RegProxy.ins;
    }
    
    
    static let REQUEST_REG_EVENT:String = "request_reg_event";
    static let REQUEST_REG_BACK_EVENT:String = "request_reg_back_event";
    
    static let REQUEST_PHONE_REG_EVENT:String = "request_phone_reg_event";
    static let REQUEST_PHONE_REG_BACK_EVENT:String = "request_phone_reg_back_event";
    
    static let REQUEST_PHONE_CODE_EVENT:String = "request_phone_code_event";
    static let REQUEST_PHONE_CODE_BACK_EVENT:String = "request_phone_code_back_event";
    
    func startWork()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegProxy.onRequestReg(_:)), name: RegProxy.REQUEST_REG_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegProxy.onRequestPhoneReg(_:)), name: RegProxy.REQUEST_PHONE_REG_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegProxy.onRequestPhoneCode(_:)), name: RegProxy.REQUEST_PHONE_CODE_EVENT, object: nil);
    }
    
    func stopWork()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RegProxy.REQUEST_REG_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RegProxy.REQUEST_PHONE_REG_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RegProxy.REQUEST_PHONE_CODE_EVENT, object: nil);
    }
    
    func onRequestPhoneCode(no:NSNotification)
    {
        let data:Dictionary<String, String>? = no.object as? Dictionary<String, String>;
        
        let rName = data!["name"]!;
        
        let keyIndex = 4;
        
        let ind:String = "0" + (keyIndex+1).description;
//        print("ind:\(ind)")
        let indUtf8:String = ind.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!;
//        print("ind:\(indUtf8)")
        
        let des:String = ThreeDES.encyrpt(rName + "&" + indUtf8, keyIndex: Int32(keyIndex));
        let token:String = des;
        
        let postStr:String = "&username=" + rName
            + "&phone=" + rName
            + "&type=" +  Common.TYPE_ZC
            + "&index=" + ind
            + "&token=" + token
            + "&app=" + Common.APP;
        
        NetProxy.sharedInstance.requestDataByPost(NetCommon.PHONE_CODE_URL, postStr: postStr, onComplete: onRequestPhoneCodeBack);
    }
    
    func onRequestPhoneCodeBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        print("onRequestPhoneCodeBack:\(data)");
        
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"]);
            
            NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_PHONE_CODE_BACK_EVENT, object: resultDic);
            
            return;
        }
        
        let status:Int?;
        let message:String?;
        
        do
        {
            let dataDic:NSDictionary? = (try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary;
            
            status = dataDic?["status"] as? Int;
            message = dataDic?["message"]as? String;
            
            print("onRequestPhoneCodeBack:\(status), \(message)");
        }
        catch
        {
            print("onRequestPhoneCodeBack:error");
            
            status = 0;
            message = "获取验证码错误";
        }
        
        let resultDic:NSDictionary = NSDictionary(objects: [status!, message!], forKeys: ["status", "message"]);
        
        print("\(resultDic)");
        
        NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_PHONE_CODE_BACK_EVENT, object: resultDic);
    }
    
    func onRequestPhoneReg(no:NSNotification)
    {
        let data = no.userInfo;
        
        let rName = data!["name"] as! String;
        let phonecheckcode = data!["phonecheckcode"] as! String;
        
        let bindid = data!["bindid"] as? String;
        let bindname = data!["bindname"] as? String;
        
//         let keyIndex:Int = 4;
        
//        let encodePass = ThreeDES.encyrpt(phonecheckcode, keyIndex: Int32(keyIndex));
        
        let uName = rName;
//        let uPass = encodePass;
        
        let tmD = NSDate().timeIntervalSince1970*1000;
        let tmI = Int64(tmD);
        let tm = String(stringInterpolationSegment: tmI);
        
        var postStr:String = "username=" + uName
            + "&phonecheckcode=" +  phonecheckcode
            + "&app=" + Common.APP
            + "&plt=" + Common.PLT
            + "&tm=" + tm
            + "&ext[gc]=" + Common.EXR_GC
            + "&ext[gid]=" + Common.EXT_GID
            + "&ext[cid]=" + Common.EXT_CID
            + "&ext[ccid]=" + Common.EXR_CCID
            + "&puid=" + Common.PUID
            + "&ext[ver]=" + Common.EXT_VER;
        
        //        print("post str: \(postStr)");
        
        if(bindid != nil)
        {
            postStr += "&bindname=" +  bindname!
                + "&bindid=" +  bindid!
        }

        
        UserProxy.sharedInstance.tempUName = rName;
        UserProxy.sharedInstance.tempUPass = phonecheckcode;
        
        NetProxy.sharedInstance.requestDataByGet(NetCommon.PHONE_REG_URL, postStr: postStr, onComplete: onRequestPhoneRegBack);
    }
    
    func onRequestPhoneRegBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"]);
            NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_PHONE_REG_BACK_EVENT, object: resultDic);
            
            return;
        }
        
        let dataDic:NSDictionary? = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary;
        
        let status:Int = dataDic?["status"] as! Int;
        let message:String = dataDic?["message"] as! String;
        
        var username:String = "";
        
        var showname:String = "";
        
        var userid = 0;
        var sessionid:String = "";
        var isguest:Int = 0;
        
//        let loginName:String = dataDic?["loginName"] as! String;
        
        var bindname:String? = "";
        var bindid:String? = "";
        
        if(status == 1)
        {
            username = dataDic?["username"] as! String;
            
            showname = dataDic?["showname"] as! String;
            
            userid = dataDic?["userid"] as! Int;
            sessionid = dataDic?["sessionid"] as! String;
            isguest = dataDic?["isguest"] as! Int;
            
            //        let loginName:String = dataDic?["loginName"] as! String;
            
            bindname = dataDic?["bindname"] as? String;
            bindid = dataDic?["bindid"] as? String;

            
            UserProxy.sharedInstance.userName = showname;
//            UserProxy.sharedInstance.loginName = loginName;
            UserProxy.sharedInstance.showName = username;
//            UserProxy.sharedInstance.bindName = username;
            UserProxy.sharedInstance.userId = userid;
//            UserProxy.sharedInstance.bindId = userid;
            UserProxy.sharedInstance.loginId = userid;
            UserProxy.sharedInstance.userPass = UserProxy.sharedInstance.tempUPass;
            UserProxy.sharedInstance.isGuest = isguest;
        }
        
        if(bindid != nil)
        {
            UserProxy.sharedInstance.bindId = Int(bindid!);
        }
        else
        {
            UserProxy.sharedInstance.bindId = userid;
        }
        
        if(bindname != nil)
        {
            UserProxy.sharedInstance.bindName = bindname;
        }
        else
        {
            UserProxy.sharedInstance.bindName = username;
        }

        UserProxy.sharedInstance.sessionId = sessionid;
        
        let resultDic:NSDictionary = NSDictionary(objects: [status, message, username, userid, sessionid, isguest, username], forKeys: ["status", "message", "username", "userid", "sessionid", "isguest", "showname"])
        
        print("onRequestPhoneRegBack:\(status), \(message), \(sessionid), \(username), \(userid), \(isguest)");
        
        NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_PHONE_REG_BACK_EVENT, object: resultDic);
    }
    
    func onRequestReg(no:NSNotification)
    {
        let data = no.userInfo;
        
        let rName = data!["name"] as! String;
        let rPass = data!["pass"] as! String;
        
        let bindid = data!["bindid"] as? String;
        let bindname = data!["bindname"] as? String;
        
        let keyIndex:Int = 4;
        
        let encodePass = ThreeDES.encyrpt(rPass, keyIndex: Int32(keyIndex));
        
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
        
//        print("post str: \(postStr)");
        
        if(bindid != nil)
        {
            postStr += "&bindname=" +  bindname!
                + "&bindid=" +  bindid!
        }
        
        UserProxy.sharedInstance.tempUName = rName;
        UserProxy.sharedInstance.tempUPass = rPass;
        
        NetProxy.sharedInstance.requestDataByGet(NetCommon.REG_URL, postStr: postStr, onComplete: onRequestRegBack);
    }
    
    func onRequestRegBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"]);
            NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_REG_BACK_EVENT, object: resultDic);
            
            return;
        }
        
        let dataDic:NSDictionary? = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary;
        
        let status:Int = dataDic?["status"] as! Int;
        let message:String = dataDic?["message"] as! String;
        
        let username:String = dataDic?["username"] as! String;
        let userid:Int = dataDic?["userid"] as! Int;
        let sessionid:String = dataDic?["sessionid"] as! String;
        let isguest:Int = dataDic?["isguest"] as! Int;
        
        let bindname = dataDic?["bindname"] as? String;
        let bindid = dataDic?["bindid"] as? String;
        
        if(status == 1)
        {
            UserProxy.sharedInstance.userName = username;
            UserProxy.sharedInstance.loginName = username;
            UserProxy.sharedInstance.showName = username;
           
            UserProxy.sharedInstance.userId = userid;
            
            UserProxy.sharedInstance.loginId = userid;
            UserProxy.sharedInstance.userPass = UserProxy.sharedInstance.tempUPass;
            UserProxy.sharedInstance.isGuest = isguest;
            
            if(bindid != nil)
            {
                UserProxy.sharedInstance.bindId = Int(bindid!);
            }
            else
            {
                UserProxy.sharedInstance.bindId = userid;
            }
            
            if(bindname != nil)
            {
                UserProxy.sharedInstance.bindName = bindname;
            }
            else
            {
                UserProxy.sharedInstance.bindName = username;
            }
            
            UserProxy.sharedInstance.sessionId = sessionid;
        }
        
        let resultDic:NSDictionary = NSDictionary(objects: [status, message, username, userid, sessionid, isguest, username], forKeys: ["status", "message", "username", "userid", "sessionid", "isguest", "showname"]);
        
        print("onRequestRegBack:\(resultDic)");
        
        NSNotificationCenter.defaultCenter().postNotificationName(RegProxy.REQUEST_REG_BACK_EVENT, object: resultDic);
    }
    
    func getSign(str:String)->String
    {
        return ThreeDES.md5(str);
    }
}
