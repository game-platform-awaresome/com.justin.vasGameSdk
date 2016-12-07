//
//  NetCommon.swift
//  VasGameSDK
//
//  Created by justin on 16/1/7.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class NetCommon: NSObject
{
    static let LOGIN_URL:String = "http://api.user.vas.pptv.com/c/v2/login.php?";
    static let REG_URL:String = "http://api.user.vas.pptv.com/c/v2/reg.php?";
    static let PHONE_REG_URL:String = "http://api.user.vas.pptv.com/c/v2/reg_mobile.php?";
    static let PHONE_CODE_URL:String = "http://api.user.vas.pptv.com/ajax/sendsms.php";
    static let GUEST_URL:String = "http://api.user.vas.pptv.com/c/v2/guest.php?";
    static let GCOIN_URL:String = "http://game.g.pptv.com/api/sdk/coin_common.php?";
    static let REPASS_CODE_URL:String = "http://api.user.vas.pptv.com/get/ppcode.php?app=mobgame";
    static let REPASS_URL:String = "http://api.user.vas.pptv.com/c/v2/password.php?";
    static let RAISE_GUEST_URL:String = "http://api.user.vas.pptv.com/c/v2/reg.php?";
    static let PAY_GCOIN:String = "http://pay.vas.pptv.com/app/mobile/coin_m";
    static let BIND_INFO_URL:String = "http://api.user.vas.pptv.com/get/user.php?";
    
    static let IDA_INFO_URL:String = "http://m.g.pptv.com/open_api/ios/setting.php?";
}
