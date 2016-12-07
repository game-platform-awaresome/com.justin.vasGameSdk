//
//  VerificationProxy.swift
//  VasGameSDK
//
//  Created by justin on 16/1/19.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class VerificationProxy: NSObject
{
    static var ins:VerificationProxy!;
    static var token:dispatch_once_t = 0;
    
    static var sharedInstance:VerificationProxy
    {
        dispatch_once(&VerificationProxy.token)
        {
            VerificationProxy.ins = VerificationProxy();
        }
        
        return VerificationProxy.ins;
    }
    
    static let VERIFICATION_REG_EVENT:String = "verification_reg_event";
    static let VERIFICATION_REG_BACK_EVENT:String = "verification_reg_back_event";
    
    static let VERIFICATION_LOGIN_EVENT:String = "verification_login_event";
    static let VERIFICATION_LOGIN_BACK_EVENT:String = "verification_login_back_event";
    
    static let VERIFICATION_PHONE_REG_EVENT:String = "verification_phone_reg_event";
    static let VERIFICATION_PHONE_REG_BACK_EVENT:String = "verification_phone_reg_back_event";
    
    static let VERIFICATION_PHONE_CODE_EVENT:String = "verification_phone_code_event";
    static let VERIFICATION_PHONE_CODE_BACK_EVENT:String = "verification_phone_code_back_event";
    
    static let VERIFICATION_PHONE_NUM:String = "verification_phone_num";
    static let VERIFICATION_PHONE_NUM_BACK:String = "verification_phone_num_back";
    
    static let VERIFICATION_NAME:String = "verification_name";
    static let VERIFICATION_NAME_BACK:String = "verification_name_back";
    
    let phoneRegex = try! NSRegularExpression(pattern: "^[0-9]+$", options: .CaseInsensitive);
    let nameRegex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9_]+$", options: .CaseInsensitive);
    let passRegex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9_*#@%^]+$", options: .CaseInsensitive);
    
    func startWork()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VerificationProxy.onVerificationReg(_:)), name: VerificationProxy.VERIFICATION_REG_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VerificationProxy.onVerificationPhoneReg(_:)), name: VerificationProxy.VERIFICATION_PHONE_REG_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VerificationProxy.onVerificationPhoneCode(_:)), name: VerificationProxy.VERIFICATION_PHONE_CODE_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VerificationProxy.onVerificationLogin(_:)), name: VerificationProxy.VERIFICATION_LOGIN_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VerificationProxy.onVerificationName(_:)), name: VerificationProxy.VERIFICATION_NAME, object: nil);
    }
    
    func stopWork()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VerificationProxy.VERIFICATION_REG_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VerificationProxy.VERIFICATION_PHONE_REG_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VerificationProxy.VERIFICATION_PHONE_CODE_EVENT, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VerificationProxy.VERIFICATION_LOGIN_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: VerificationProxy.VERIFICATION_NAME, object: nil);
    }
    
    func onVerificationName(no:NSNotification)
    {
        let data:[NSObject:AnyObject]? = no.userInfo;
        
        let phone = data!["name"] as? String;
        
        var result = 1;
        var message = "";
        
        print("onVerificationName: \(data)");
        
        repeat
        {
            if(phone == nil || phone == "")
            {
                result = 0;
                message = "用户名不能为空";
                
                break;
            }
            
            let nPhone:NSString = phone!;
            let pResult = nameRegex.firstMatchInString(nPhone as String, options: NSMatchingOptions(), range: NSMakeRange(0, nPhone.length));
            if(pResult == nil)
            {
                result = 0;
                message = "用户名存在非法字符";
            }
        }
            while(false);
        
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_NAME_BACK, object: nil, userInfo: ["status":result, "message":message]);
    }
    
    func verificationPhoneNum(phone:String?)
    {
        let nPhone:NSString = phone!;
        
        let regex = try! NSRegularExpression(pattern: "^1[3|4|5|8][0-9]{9}$", options: .CaseInsensitive);
        
        let result = regex.firstMatchInString(nPhone as String, options: NSMatchingOptions(), range: NSMakeRange(0, nPhone.length));
        
        if(result != nil)
        {
            print(result?.range);
        }
    }
    
    func onVerificationLogin(no:NSNotification)
    {
        let data:[NSObject:AnyObject]? = no.userInfo;
        
        let phone = data!["name"] as? String;
        let code = data!["pass"] as? String;
        
        var result = 1;
        var message = "";
        
//        print("onVerificationLogin: \(data)");
        
        repeat
        {
            if(phone == nil || phone == "")
            {
                result = 0;
                message = "用户名不能为空";
                
                break;
            }
            
            if(code == nil || code == "")
            {
                result = 0;
                message = "密码不能为空";
                
                break;
            }
            
            let nPhone:NSString = phone!;
            let pResult = nameRegex.firstMatchInString(nPhone as String, options: NSMatchingOptions(), range: NSMakeRange(0, nPhone.length));
            if(pResult == nil)
            {
                result = 0;
                message = "用户名存在非法字符";
            }
            
            let nCode:NSString = code!;
            let cResult = passRegex.firstMatchInString(nCode as String, options: NSMatchingOptions(), range: NSMakeRange(0, nCode.length));
            if(cResult == nil)
            {
                result = 0;
                message = "密码存在非法字符";
            }
            
        }
            while(false);
        
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_LOGIN_BACK_EVENT, object: nil, userInfo: ["status":result, "message":message]);
    }

    
    func onVerificationPhoneCode(no:NSNotification)
    {
        let data:[NSObject:AnyObject]? = no.userInfo;
        
        let phone = data!["phone"] as? String;
        
        var result = 1;
        var message = "";
        
        repeat
        {
            if(phone == nil || phone == "")
            {
                result = 0;
                message = "手机号不能为空";
                
                break;
            }
            
            let nPhone:NSString = phone!;
            let pResult = phoneRegex.firstMatchInString(nPhone as String, options: NSMatchingOptions(), range: NSMakeRange(0, nPhone.length));
            if(pResult == nil)
            {
                result = 0;
                message = "手机号存在非法字符";
            }
        }
            while(false);
        
//        verificationPhoneNum(phone);
        
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_PHONE_CODE_BACK_EVENT, object: nil, userInfo: ["status":result, "message":message]);
    }
    
    func onVerificationPhoneReg(no:NSNotification)
    {
        let data:[NSObject:AnyObject]? = no.userInfo;
        
        let phone = data!["phone"] as? String;
        let code = data!["code"] as? String;
        
        var result = 1;
        var message = "";
        
        repeat
        {
            if(phone == nil || phone == "")
            {
                result = 0;
                message = "手机号不能为空";
                
                break;
            }
            
            if(code == nil || code == "")
            {
                result = 0;
                message = "验证码不能为空";
                
                break;
            }
            
            let nPhone:NSString = phone!;
            let pResult = phoneRegex.firstMatchInString(nPhone as String, options: NSMatchingOptions(), range: NSMakeRange(0, nPhone.length));
            if(pResult == nil)
            {
                result = 0;
                message = "用户名存在非法字符";
            }
            
            let nCode:NSString = code!;
            let cResult = passRegex.firstMatchInString(nCode as String, options: NSMatchingOptions(), range: NSMakeRange(0, nCode.length));
            if(cResult == nil)
            {
                result = 0;
                message = "验证码存在非法字符";
            }

        }
            while(false);
        
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_PHONE_REG_BACK_EVENT, object: nil, userInfo: ["status":result, "message":message]);
    }
    
    func onVerificationReg(no:NSNotification)
    {
        let data:NSDictionary? = no.object as? NSDictionary;
        
        let pass = data!["pass"] as? String;
        let rePass = data!["rePass"] as? String;
        let name = data!["name"] as? String;
        
        var result = 1;
        var message = "";
        
        repeat
        {
            print("verificationReg");
            
            if(name == nil || name == "")
            {
                result = 0;
                message = "用户名不能为空";
                
                break;
            }
            
            if(pass == nil || pass == "")
            {
                result = 0;
                message = "密码不能为空";
                
                break;
            }
            
            if(rePass == nil || rePass == "")
            {
                result = 0;
                message = "确认密码不能为空";
                
                break;
            }
            
            if(pass != rePass)
            {
                result = 0;
                message = "两次输入的密码不一致";
            }
            
            let nPhone:NSString = name!;
            let pResult = nameRegex.firstMatchInString(nPhone as String, options: NSMatchingOptions(), range: NSMakeRange(0, nPhone.length));
            if(pResult == nil)
            {
                result = 0;
                message = "用户名存在非法字符";
            }
            
            let nCode:NSString = pass!;
            let cResult = passRegex.firstMatchInString(nCode as String, options: NSMatchingOptions(), range: NSMakeRange(0, nCode.length));
            if(cResult == nil)
            {
                result = 0;
                message = "密码存在非法字符";
            }
        }
            while(false);
        
        let resultData:NSDictionary = NSDictionary(objects: [result, message], forKeys: ["status", "message"]);
//        print("verificationReg: \(resultData)");
//        print("onVerificationPass:\(result)");
        
        NSNotificationCenter.defaultCenter().postNotificationName(VerificationProxy.VERIFICATION_REG_BACK_EVENT, object: resultData);
    }
}
