//
//  IADProxy.swift
//  VasSdkDemo
//
//  Created by justin on 16/6/16.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import VasSdkTool

class IADProxy: NSObject
{
    static var ins:IADProxy!;
    static var token:dispatch_once_t = 0;
    
    static var sharedInstance:IADProxy
    {
        dispatch_once(&IADProxy.token)
        {
            IADProxy.ins = IADProxy();
        }
        
        return IADProxy.ins;
    }
    
    static let OS:Int = 1;
    
    static let KEY:String = "233692e0aad5a445107564ca1bb68d51";
    
    static let REQUEST_IAD_INFO:String = "request_iad_info";
    
    static let REQUEST_IAD_INFO_BACK:String = "request_iad_info_back";
    
    
    
    
    
    func startWork()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IADProxy.onRequestIadInfo(_:)), name: IADProxy.REQUEST_IAD_INFO, object: nil);
    }
    
    func stopWork()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IADProxy.REQUEST_IAD_INFO, object: nil);
    }
    
    func onRequestIadInfo(n:NSNotification)
    {
        let sign = getSign();
        
        let postStr:String =
            "ver=" + Common.EXT_VER
                + "&gid=" + Common.APP_ID
                + "&os=" + IADProxy.OS.description
                + "&sign=" + sign;
        
        NetProxy.sharedInstance.requestDataByGet(NetCommon.IDA_INFO_URL, postStr: postStr, onComplete: onIdaInfoBack);
    }
    
    func onIdaInfoBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
        if(error != nil)
        {
            let resultDic = ["status":0, "message":"网络错误"];
            
            NSNotificationCenter.defaultCenter().postNotificationName(IADProxy.REQUEST_IAD_INFO_BACK, object: nil, userInfo: resultDic);
            
            return;
        }
        
        let dataDic = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [NSObject:AnyObject];
        
        NSNotificationCenter.defaultCenter().postNotificationName(IADProxy.REQUEST_IAD_INFO_BACK, object: nil, userInfo: dataDic);
        
    }
    
    func getSign()->String
    {
        return CommonFunc.md5(IADProxy.KEY + Common.APP_ID +  Common.EXT_VER + IADProxy.OS.description);
    }
}
