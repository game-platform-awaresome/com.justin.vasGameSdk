//
//  GameCenterProxy.swift
//  VasGameSDK
//
//  Created by justin on 16/3/17.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class GameCenterProxy: NSObject
{
    static var ins:GameCenterProxy!;
    static var token:dispatch_once_t = 0;
    
    static var sharedInstance:GameCenterProxy
    {
        dispatch_once(&GameCenterProxy.token)
            {
                GameCenterProxy.ins = GameCenterProxy();
        }
        
        return GameCenterProxy.ins;
    }
}
