//
//  AlertManager.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/20.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class AlertManager: NSObject
{
    static var ins:AlertManager!;
    static var token:dispatch_once_t = 0;
    
    
    static var sharedInstance:AlertManager
    {
        dispatch_once(&AlertManager.token)
        {
            AlertManager.ins = AlertManager();
        }
        
        return AlertManager.ins;
    }
    
    @available(iOS 8.0, *)
    func show(title:String, message:String, btnTitle:[String], parentVc:UIViewController, handle:[((UIAlertAction) -> Void)] = [])
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
        
        for i in 0...(btnTitle.count-1)
        {
            let bT = btnTitle[i];
            
            var action:UIAlertAction?;
            
            if(i < handle.count)
            {
                action = UIAlertAction(title: bT, style: UIAlertActionStyle.Default, handler: handle[i]);
            }
            else
            {
                action = UIAlertAction(title: bT, style: UIAlertActionStyle.Default, handler: nil);
            }
            
            alertController.addAction(action!);
        }
        
        parentVc.presentViewController(alertController, animated: true, completion: nil);
    }
    
    func showEV(title:String, message:String, btnTitle:[String], aDelegate:UIAlertViewDelegate? = nil)
    {
        var alerView:UIAlertView?;
        
        if(btnTitle.count == 1)
        {
            alerView = UIAlertView(title: title, message: message, delegate: aDelegate, cancelButtonTitle: btnTitle[0]);
        }
        else
        {
            alerView = UIAlertView(title: title, message: message, delegate: aDelegate, cancelButtonTitle: btnTitle[0], otherButtonTitles: btnTitle[1]);
        }
        
        alerView?.show();
    }

}
