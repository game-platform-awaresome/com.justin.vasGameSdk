//
//  GCoinProxy.swift
//  VasGameSDK
//
//  Created by justin on 16/1/21.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import VasSdkTool

class GCoinProxy: NSObject
{
    static var ins:GCoinProxy!;
    static var token:dispatch_once_t = 0;
    
    static let REQUEST_GCOIN_EVENT:String = "request_gcoin_event";
    static let REQUEST_GCOIN_BACK_EVENT:String = "request_gcoin_back_event";
    
    static let REQUEST_PAY_GCOIN_EVENT:String = "request_pay_gcoin_event";
    static let REQUEST_PAY_GCOIN_BACK_EVENT:String = "request_pay_gcoin_back_event";
    
    var gCoinData:NSDictionary?;
    
    func startWork()
    {
//        print("GCoinProxy:startWork");
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GCoinProxy.onRequestGCoin(_:)), name: GCoinProxy.REQUEST_GCOIN_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GCoinProxy.onRequestPayGCoin(_:)), name: GCoinProxy.REQUEST_PAY_GCOIN_EVENT, object: nil);
    }
    
    func onRequestPayGCoin(no:NSNotification)
    {
        let data:NSDictionary? = no.object as? NSDictionary;
        
        let rName = data!["name"] as! String;
        let rPass = data!["pass"] as! String;
        
        let encodePass = ThreeDES.encyrptNoIv(rPass, key: Common.TDES_KEY);
        
        let tmD = NSDate().timeIntervalSince1970*1000;
        let tmI = Int(tmD);
        let tm = String(stringInterpolationSegment: tmI);
        
        let amount:Int = data!["amount"] as! Int;
        
        var postStr:String = "amount=" + amount.description
            + "&ccid=" + Common.EXR_CCID
            + "&cid=" + Common.EXT_CID
            + "&ext1=" + "extra_data"
            + "&gid=" + Common.EXT_GID
            + "&pid=" + "1"
            + "&roid=" + Common.ROID
            + "&sid=" + Common.SID
            + "&tm=" + tm
            + "&username=" + rName
            + "&vid=" + "V4.5.01.160105";

        
        let str:String = "amount=" + amount.description
        + "&ccid=" + Common.EXR_CCID
        + "&cid=" + Common.EXT_CID
        + "&ext1=" + "extra_data"
        + "&gid=" + Common.EXT_GID
        + "&pid=" + "1"
        + "&pwd=" + encodePass
        + "&roid=" + Common.ROID
        + "&sid=" + Common.SID
        + "&tm=" + tm
        + "&username=" + rName
        + "&vid=" + "V4.5.01.160105";
        
        let md5Str = str + Common.MD5_KEY;
        let sign = ThreeDES.md5(md5Str);
        
        postStr += "&pwd=" + encodePass;
        postStr += "&sign=" + sign;
        
         NetProxy.sharedInstance.requestDataByPost(NetCommon.PAY_GCOIN, postStr: postStr, onComplete: onRequestPayGCoinBack);
    }
    
    func onRequestPayGCoinBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"]);
            
            NSNotificationCenter.defaultCenter().postNotificationName(GCoinProxy.REQUEST_GCOIN_BACK_EVENT, object: resultDic);
            
            return;
        }
        
        let dataDic:NSDictionary? = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary;
        
        let status:Int = dataDic!["status"] as! Int;
        let message:String = dataDic!["message"]! as! String;
        
        print("\(status), \(message)");
        
        let resultDic:NSDictionary = NSDictionary(objects: [status, message,], forKeys: ["status", "message"]);
        
        NSNotificationCenter.defaultCenter().postNotificationName(GCoinProxy.REQUEST_PAY_GCOIN_BACK_EVENT, object: resultDic);
    }
    
    func onRequestGCoin(no:NSNotification)
    {
        if(gCoinData != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [1, "", gCoinData!], forKeys: ["status", "message", "gCoinData"]);
            
//            print("gCoinData != ni");
            
            NSNotificationCenter.defaultCenter().postNotificationName(GCoinProxy.REQUEST_GCOIN_BACK_EVENT, object: resultDic);
        }
        else
        {
            let data:Dictionary<String, String>? = no.object as? Dictionary<String, String>;
//            print("gCoinData == ni");
            let rName = data!["name"]!;
            
            let tmD = NSDate().timeIntervalSince1970*1000;
            let tmI = Int(tmD);
            let tm = String(stringInterpolationSegment: tmI);
            
            let str = tm + rName + Common.INFO_MD5_KEY;
            let sign = getSign(str);
            
            let postStr:String = "username=" + rName
                + "&tm=" + tm
                + "&sign=" + sign;
            
            NetProxy.sharedInstance.requestDataByPost(NetCommon.GCOIN_URL, postStr: postStr, onComplete: onRequestGCoinBack);
        }
    }
    
    func onRequestGCoinBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        if(error != nil)
        {
            let resultDic:NSDictionary = NSDictionary(objects: [0, "网络错误"], forKeys: ["status", "message"]);
            
            NSNotificationCenter.defaultCenter().postNotificationName(GCoinProxy.REQUEST_GCOIN_BACK_EVENT, object: resultDic);
            
            return;
        }
        
        let dataDic:NSDictionary? = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary;
        
        let code:Int = Int(dataDic!["code"] as! String)!;
        let message:String = dataDic!["msg"]! as! String;
        
        if(code == 1)
        {
            gCoinData = dataDic!["result"] as? NSDictionary;
        }
        
        print("onRequestGCoinBack:\(dataDic!["code"]), \(dataDic!["msg"]), \(dataDic!["result"]!)");
        
        let resultDic:NSDictionary = NSDictionary(objects: [code, message, gCoinData!], forKeys: ["status", "message", "gCoinData"]);
        NSNotificationCenter.defaultCenter().postNotificationName(GCoinProxy.REQUEST_GCOIN_BACK_EVENT, object: resultDic);
    }
    
    func getSign(str:String)->String
    {
        return ThreeDES.md5(str);
    }
    
    static var sharedInstance:GCoinProxy
    {
        dispatch_once(&GCoinProxy.token)
            {
                GCoinProxy.ins = GCoinProxy();
        }
        
        return GCoinProxy.ins;
    }

}
