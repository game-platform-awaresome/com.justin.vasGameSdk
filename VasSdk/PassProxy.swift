//
//  PassProxy.swift
//  VasGameSDK
//
//  Created by justin on 16/1/27.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import VasSdkTool

class PassProxy: NSObject
{
    static var ins:PassProxy!;
    static var token:dispatch_once_t = 0;
    
    static var sharedInstance:PassProxy
    {
        dispatch_once(&PassProxy.token)
        {
            PassProxy.ins = PassProxy();
        }
        
        return PassProxy.ins;
    }
    
    static let REQUEST_REPASS_EVENT:String = "request_repass_event";
    static let REQUEST_PEPASS_BACK_EVENT:String = "request_repass_back_event";
    
    static let REQUEST_REPASS_CODE_EVENT:String = "request_repass_code_event";
    static let REQUEST_PEPASS_CODE_BACK_EVENT:String = "request_repass_code_back_event";
    
    static let REQUEST_BIND_INFO:String = "request_bind_info";
    static let REQUEST_BIND_INFO_BACK:String = "request_bind_info_back";
    
    var tempGuid:String?;
    
    func startWork()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PassProxy.onRequestRePass(_:)), name: PassProxy.REQUEST_REPASS_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PassProxy.onRequestRePassCode(_:)), name: PassProxy.REQUEST_REPASS_CODE_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PassProxy.onRequestBindInfo(_:)), name: PassProxy.REQUEST_BIND_INFO, object: nil);

    }
    
    func stopWork()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PassProxy.REQUEST_REPASS_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PassProxy.REQUEST_REPASS_CODE_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PassProxy.REQUEST_BIND_INFO, object: nil);
    }
    
    func onRequestBindInfo(n:NSNotification)
    {
        let data = n.userInfo;
        
        let name = data!["name"] as! String;
        
        let tmD = NSDate().timeIntervalSince1970;
        let tmI = Int(tmD);
        let tm = String(stringInterpolationSegment: tmI);
        
        let str = name + "&" + tm + "&" + Common.PK_FIND_PASS_WORD;
        let sign = getSign(str);
        
        let postStr:String =
            "sign=" + sign
            + "&act=" + "userinfo"
            + "&username=" + name
            + "&tm=" + tm
                + "&app=" + Common.APP;
        
        NetProxy.sharedInstance.requestDataByGet(NetCommon.BIND_INFO_URL, postStr: postStr, onComplete: onBindInfoBack);
    }
    
    func onBindInfoBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"]);
            
            NSNotificationCenter.defaultCenter().postNotificationName(PassProxy.REQUEST_BIND_INFO_BACK, object: resultDic);
            
            return;
        }
        
        var dataDic:NSDictionary?;
        var resultDic:[NSObject:AnyObject]?;
        
        do
        {
            dataDic = (try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary;
        }
        catch
        {
            resultDic = ["status":0, "message":"参数错误"];
            
        }
        
        if(dataDic == nil)
        {
            resultDic = ["status":0, "message":"参数错误"];
        }
        else
        {
            resultDic = ["status":100, "message":"", "data":dataDic!["result"]!];
            
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(PassProxy.REQUEST_BIND_INFO_BACK, object: nil, userInfo: resultDic);
        
    }

    
    func onRequestRePass(no:NSNotification)
    {
        let data:Dictionary<String, String>? = no.object as? Dictionary<String, String>;
        
        let oPass = data!["oPass"]!;
        let nPass = data!["nPass"]!;
        let code = data!["code"]!;
        
        let keyIndex:Int = 4;
        
        let encodeOPass = ThreeDES.encyrpt(oPass, keyIndex: Int32(keyIndex));
        let encodeNPass = ThreeDES.encyrpt(nPass, keyIndex: Int32(keyIndex));
        
        let uName = UserProxy.sharedInstance.userName;
        let uOPass = encodeOPass;
        let uNPass = encodeNPass;
        
        let tmD = NSDate().timeIntervalSince1970*1000;
        let tmI = Int(tmD);
        let tm = String(stringInterpolationSegment: tmI);
        
        let str = uName! + tm + Common.INFO_MD5_KEY;
        let sign = getSign(str);
        
        let postStr:String = "username=" + uName!
            + "&oldpassword=" +  uOPass
            + "&newpassword=" +  uNPass
            + "&checkcode=" +  code
            + "&sign=" + sign
            + "&index=" +  String(stringInterpolationSegment: keyIndex+1)
            + "&guid=" +  tempGuid!
            + "&app=" + Common.APP
            + "&plt=" + Common.PLT
            + "&tm=" + tm
            + "&ext[gc]=" + Common.EXR_GC
            + "&ext[gid]=" + Common.EXT_GID
            + "&ext[cid]=" + Common.EXT_CID
            + "&ext[ccid]=" + Common.EXR_CCID
            + "&puid=" + Common.PUID
            + "&ext[ver]=" + Common.EXT_VER;
        
        NetProxy.sharedInstance.requestDataByGet(NetCommon.REPASS_URL, postStr: postStr, onComplete: onRequestRePassBack);
    }
    
    func onRequestRePassBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"]);
            
            NSNotificationCenter.defaultCenter().postNotificationName(PassProxy.REQUEST_PEPASS_BACK_EVENT, object: resultDic);
            
            return;
        }
        
        let dataDic:NSDictionary? = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary;
        
        let status:Int = dataDic!["status"] as! Int;
        let message:String = dataDic!["message"]! as! String;
        
        let resultDic:NSDictionary = NSDictionary(objects: [status, message], forKeys: ["status", "message"]);
        
        NSNotificationCenter.defaultCenter().postNotificationName(PassProxy.REQUEST_PEPASS_BACK_EVENT, object: resultDic);

    }
    
    func onRequestRePassCode(no:NSNotification)
    {
        NetProxy.sharedInstance.requestDataByGet(NetCommon.REPASS_CODE_URL, postStr: "", onComplete: onRequestRePassCodeBack);
    }
    
    func onRequestRePassCodeBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"]);
            
            NSNotificationCenter.defaultCenter().postNotificationName(PassProxy.REQUEST_PEPASS_CODE_BACK_EVENT, object: resultDic);
            
            return;
        }
        
        let dataDic:NSDictionary? = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary;
        
        let codeurl = dataDic!["codeurl"];
        let guid = dataDic!["guid"];
        
        tempGuid = guid as? String;
        
        NetProxy.sharedInstance.requestImg(codeurl as! String, onComplete: onImgComplete);
    }

    func onImgComplete(location:NSURL?, response:NSURLResponse?, error:NSError?)
    {
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"]);
            
            NSNotificationCenter.defaultCenter().postNotificationName(PassProxy.REQUEST_PEPASS_CODE_BACK_EVENT, object: resultDic);
            
            return;
        }
        
        guard location != nil else
        {
            print("onImgComplete : \(error?.debugDescription)");
            
            return;
        }
        
        guard let imgData:NSData? = try? NSData(contentsOfURL: location!, options: NSDataReadingOptions()) else
        {
            print("onImgComplete:imgData == nil");
            
            return;
        }
        
        let image = UIImage(data: imgData!);
        
        let resultDic:NSDictionary = NSDictionary(objects: [1, "", image!], forKeys: ["status", "message", "img"]);
        
        NSNotificationCenter.defaultCenter().postNotificationName(PassProxy.REQUEST_PEPASS_CODE_BACK_EVENT, object: resultDic);
    }
    
    func getSign(str:String)->String
    {
        return ThreeDES.md5(str);
    }
    
    
}
