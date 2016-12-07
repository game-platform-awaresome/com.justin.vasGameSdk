//
//  BipProxy.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/21.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import VasSdkTool

class BipProxy: NSObject
{
    static var ins:BipProxy!;
    static var token:dispatch_once_t = 0;
    
    static var sharedInstance:BipProxy
    {
        dispatch_once(&BipProxy.token)
        {
            BipProxy.ins = BipProxy();
        }
        
        return BipProxy.ins;
    }
    
    
    
    static let URL:String = "http://tj.g.pptv.com/data/1.php?";
    static let SEND_BIP:String = "send_bip";
    
    static let SDK_START:String = "114";
    static let SDK_FIRST_START:String = "115";
    static let LOGIN_SUC:String = "161";
    static let REG_REQUEST:String = "109";
    static let GOTO_REG:String = "124";
    static let GOTO_PHONE_REG:String = "123";
    static let GOTO_REG_CHOOSE:String = "122";
    static let GOTO_GUEST:String = "125";
    static let GOTO_LOGIN:String = "126";
    static let START_GAME:String = "127";
    static let GOTO_PASS:String = "129";
    static let CHANGE_USER:String = "133";
    static let GAME_CENTER:String = "162";
    static let GET_CODE:String = "163";
    static let DROP_DOWN_MENU:String = "164";
    
    static let NEXT:String = "137";
    static let BACK:String = "138";
    
    let app:String = "mobile";
    let f:String = "isdk";
    let plt:String = "ios";
    let ver:String = "1.0";
    
    
    var uid:String = "";
    var puid:String = "";
    var chid:String = "";
    var cid:String = "";
    var ccid:String = "";
    var gid:String = "";
    var stat:String = "0";
    var aid:String = "";
    
    static let FIRST_PAGE:String = "sqdlxz";
    static let LOGIN_CHOOSE_PAGE:String = "dlxz";
    static let AUTO_LOGIN_PAGE:String = "zddl";
    static let GUEST_RASIE_PAGE:String = "ykhy";
    static let PHONE_REG_PAGE:String = "sjzc";
    static let LOGIN_PAGE:String = "dl";
    static let CHOOSE_USER_LOGIN_PAGE:String = "zhxz";
    static let REG_CHOOSE_PAGE:String = "ykbd";
    static let REG_PAGE:String = "yhmzc";
    static let FORGET_PASS_PAGE:String = "mmzh";
    static let FORGET_PASS_WEB_PAGE:String = "h5mmzh";
    
//    fukey 来源页面标示
//    ukey 页面标示
    
    func startWork()
    {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onRequestLoginBack(_:)), name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onSendBip(_:)), name: BipProxy.SEND_BIP, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onInitSdk(_:)), name: SDKMain.INIT_SDK, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onRequestReg(_:)), name: RegViewController.REQUEST_REG, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onGotoReg(_:)), name: RegViewController.GOTO_REG, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onGotoPhoneReg(_:)), name: PhoneRegViewController.GOTO_PHONE_REG, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onGotoRegChoose(_:)), name: RegChooseViewController.GOTO_REG_CHOOSE, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onGotoGuest(_:)), name: GuestWelcomeViewController.GOTO_GUEST, object: nil);

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onGotoLoginChoose(_:)), name: LoginViewController.GOTO_LOGIN, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onGotoPass(_:)), name: PassWebViewController.GOTO_PASS, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onChangeUser(_:)), name: AutoLoginViewController.CHANGE_USER, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onGameCenter(_:)), name: LoginChooseViewController.GAME_CENTER, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onPhoneCode(_:)), name: PhoneRegViewController.GET_CODE, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onDropDown(_:)), name: ChooseUserLoginViewController.DROP_DOWN_MENU, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onNext(_:)), name: SDKMain.NEXT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BipProxy.onBack(_:)), name: SDKMain.BACK, object: nil);
    }
    
    func stopWork()
    {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginProxy.REQUEST_LOGIN_BACK_EVENT, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BipProxy.SEND_BIP, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SDKMain.INIT_SDK, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RegViewController.REQUEST_REG, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RegViewController.GOTO_REG, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PhoneRegViewController.GOTO_PHONE_REG, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RegChooseViewController.GOTO_REG_CHOOSE, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: GuestWelcomeViewController.GOTO_GUEST, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginViewController.GOTO_LOGIN, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PassWebViewController.GOTO_PASS, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AutoLoginViewController.CHANGE_USER, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginChooseViewController.GAME_CENTER, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PhoneRegViewController.GET_CODE, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ChooseUserLoginViewController.DROP_DOWN_MENU, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SDKMain.NEXT, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SDKMain.BACK, object: nil);
    }
    
    func onBack(n:NSNotification)
    {
        let fukey:String = n.userInfo!["fukey"] as! String;
        let ukey:String = n.userInfo!["ukey"] as! String;
        
        sendBip(BipProxy.BACK, fukey: fukey, ukey: ukey);
    }
    
    func onNext(n:NSNotification)
    {
        let fukey:String = n.userInfo!["fukey"] as! String;
        let ukey:String = n.userInfo!["ukey"] as! String;
        
        sendBip(BipProxy.NEXT, fukey: fukey, ukey: ukey);
    }
    
    func onDropDown(n:NSNotification)
    {
        sendBip(BipProxy.DROP_DOWN_MENU, fukey: BipProxy.CHOOSE_USER_LOGIN_PAGE, ukey: BipProxy.CHOOSE_USER_LOGIN_PAGE);
    }
    
    func onPhoneCode(n:NSNotification)
    {
        sendBip(BipProxy.GET_CODE, fukey: BipProxy.PHONE_REG_PAGE, ukey: BipProxy.PHONE_REG_PAGE);
    }
    
    func onGameCenter(n:NSNotification)
    {
        let fukey:String = n.userInfo!["fukey"] as! String;
        let ukey:String = n.userInfo!["ukey"] as! String;
        
        sendBip(BipProxy.GAME_CENTER, fukey: fukey, ukey: ukey);
    }
    
    func onChangeUser(n:NSNotification)
    {
        sendBip(BipProxy.CHANGE_USER, fukey: BipProxy.AUTO_LOGIN_PAGE, ukey: BipProxy.CHOOSE_USER_LOGIN_PAGE);
    }
    
    func onGotoPass(n:NSNotification)
    {
        sendBip(BipProxy.GOTO_PASS, fukey: BipProxy.FORGET_PASS_PAGE, ukey: BipProxy.FORGET_PASS_WEB_PAGE);
    }
    
    func onGotoLoginChoose(n:NSNotification)
    {
        sendBip(BipProxy.GOTO_LOGIN, fukey: BipProxy.LOGIN_CHOOSE_PAGE, ukey: BipProxy.CHOOSE_USER_LOGIN_PAGE);
    }
    
    func onGotoGuest(n:NSNotification)
    {
        sendBip(BipProxy.GOTO_GUEST, fukey: BipProxy.GUEST_RASIE_PAGE, ukey: BipProxy.GUEST_RASIE_PAGE);
    }
    
    func onGotoRegChoose(n:NSNotification)
    {
        let fukey:String = n.userInfo!["fukey"] as! String;
        let ukey:String = n.userInfo!["ukey"] as! String;
        
        sendBip(BipProxy.GOTO_REG_CHOOSE, fukey: fukey, ukey: ukey);
    }
    
    func onGotoPhoneReg(n:NSNotification)
    {
        sendBip(BipProxy.GOTO_PHONE_REG, fukey: BipProxy.REG_CHOOSE_PAGE, ukey: BipProxy.PHONE_REG_PAGE);
    }
    
    func onGotoReg(n:NSNotification)
    {
        sendBip(BipProxy.GOTO_REG, fukey: BipProxy.REG_CHOOSE_PAGE, ukey: BipProxy.REG_PAGE);
    }
    
    func onRequestReg(n:NSNotification)
    {
        sendBip(BipProxy.REG_REQUEST, fukey: BipProxy.REG_PAGE, ukey: BipProxy.REG_PAGE);
    }
    
    func onInitSdk(n:NSNotification)
    {
        if(Common.startNum == 0)
        {
            sendBip(BipProxy.SDK_FIRST_START, fukey: BipProxy.FIRST_PAGE, ukey: BipProxy.FIRST_PAGE);
        }
        else
        {
            let fukey:String = n.userInfo!["fukey"] as! String;
            let ukey:String = n.userInfo!["ukey"] as! String;
            
            sendBip(BipProxy.SDK_START, fukey: fukey, ukey: ukey);
        }
    }
    
    func onSendBip(n:NSNotification)
    {
        let data = n.userInfo;
        
        let evt:String = data!["evt"] as! String;
        let fukey:String = data!["fukey"] as! String;
        let ukey:String = data!["ukey"] as! String;
        
        sendBip(evt, fukey: fukey, ukey: ukey);
    }
    
    func onRequestLoginBack(no:NSNotification)
    {
        let data:NSDictionary? = no.object as? NSDictionary;
        
        let status = data!["status"] as! Int;
        
        if(status == 1)
        {
            stat = "1";
            
            self.sendBip(BipProxy.LOGIN_SUC, fukey: "", ukey: "");
        }
    }
    
    func sendBip(evt:String, fukey:String, ukey:String, productid:String = "", buystat:String = "")
    {
        dispatch_async(dispatch_get_main_queue(),
                       {
                        var postStr:String = "app=" + self.app +
                            "&f=" + self.f +
                            "&plt=" + self.plt +
                            "&uid=" + self.uid +
                            "&puid=" + self.puid +
                            "&chid=" + self.chid +
                            "&cid=" + self.cid +
                            "&ccid=" + self.ccid +
                            "&gid=" + self.gid +
                            "&evt=" + evt +
                            "&fukey=" + fukey +
                            "&ukey=" + ukey +
                            "&stat=" + self.stat +
                            "&aid=" + self.aid;
                        
                        if(productid != "")
                        {
                            postStr += "&productid=" + productid + "&buystat=" + buystat;
                        }
                        
                        let enPostStr:String = ThreeDES.encodeInBip(postStr);
                        
                        NetProxy.sharedInstance.requestDataByGet(BipProxy.URL, postStr: enPostStr, onComplete: self.onBipBack);
        });
        
    }
    
    func onBipBack(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void
    {
    }
}
