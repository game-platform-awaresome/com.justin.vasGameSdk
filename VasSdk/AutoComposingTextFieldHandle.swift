//
//  AutoComposingTextFieldHandle.swift
//  VasSdkDemo
//
//  Created by justin on 16/5/25.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class AutoComposingTextFieldHandle: NSObject
{
    var kHeight:CGFloat = 216;
    
    var view:UIView?;
    
    var pView:UIView?;
    
    var curTextField:UITextField?;
    
    var initPos:CGPoint = CGPoint();
    
    init(view:UIView?, pView:UIView?)
    {
        super.init();
        
        self.view = view;
        self.pView = pView;
        
        initPos = (view?.frame.origin)!;
    }
    
    func keyboardWillAppear(n:NSNotification)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil);
        
        let keyboardinfo = n.userInfo![UIKeyboardFrameBeginUserInfoKey]
        
//        print("\(n.userInfo)");
        
        let keyboardheight:CGFloat = (keyboardinfo?.CGRectValue.size.height)!
        
//        print("键盘弹起");
        
//        print("keyboardheight:\(keyboardheight)");
        
        kHeight = keyboardheight;
        
        startAutoComposing();
    }
    
    func keyboardWillDisappear(n:NSNotification)
    {
        clearAutoComposing();
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object: nil);
    }
    
    func textFieldDidBeginEditing(textField:UITextField)
    {
        curTextField = textField;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AutoComposingTextFieldHandle.keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil);
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AutoComposingTextFieldHandle.keyboardWillDisappear(_:)), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    func startAutoComposing()
    {
        let pH = UIScreen.mainScreen().bounds.height;
        
        let kH = pH - kHeight;
        
        //        let w = UIApplication.sharedApplication().delegate?.window;
        
        let r = curTextField!.convertRect(curTextField!.bounds, toView: pView);
        
        //        print("r:\(r)");
        //        print("\(textField.frame.origin.y + iV.frame.origin.y)");
        
        //        print("kH:\(kH)");
        //        print("tP:\(r.origin.y + textField.frame.height)");
        
        let d = kH - (r.origin.y + curTextField!.frame.height);
        //
        
        if(d < 0)
        {
//            print("d:\(d)");
            
            let animationDuration:NSTimeInterval  = 0.30;
            UIView.beginAnimations("ResizeForKeyboard", context:nil);
            UIView.setAnimationDuration(animationDuration);
            
            //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
//            view!.bounds = CGRectMake(0, -d, view!.bounds.size.width, view!.bounds.size.height);//64-216
            
//            view!.frame = CGRectMake((view?.frame.origin.x)!, ((view?.frame.origin.y)! + d), view!.bounds.size.width, view!.bounds.size.height);
            pView!.frame = CGRectMake((pView?.frame.origin.x)!, ((pView?.frame.origin.y)! + d), pView!.bounds.size.width, pView!.bounds.size.height);
            UIView.commitAnimations();
        }

    }
    
    func clearAutoComposing()
    {
//        print("clearAutoComposing");
        
        if(pView!.frame.origin.y != 0)
        {
            let animationDuration:NSTimeInterval  = 0.30;
            UIView.beginAnimations("ResizeForKeyboard", context:nil);
            UIView.setAnimationDuration(animationDuration);
            
            pView!.frame = CGRectMake(0, 0, pView!.frame.size.width, pView!.frame.size.height);//64-216
            
            UIView.commitAnimations();

        }
    }

    
    func textFieldDidEndEditing(textField:UITextField)
    {
        clearAutoComposing();
    }

}
