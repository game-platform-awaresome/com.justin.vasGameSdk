//
//  ColorButton.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/11.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class ColorButton: UIButton
{

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    static let oC:CGColor = UIColor(red: CGFloat(0xfe)/255, green: CGFloat(0x8c)/255, blue: CGFloat(0x00)/255, alpha: 1.0).CGColor;
    
    func imageWithColor(color:CGColor)->UIImage
    {
        let w:CGFloat = self.frame.width;
        let h:CGFloat = self.frame.height;
        
        let rect:CGRect = CGRectMake(0.0, 0.0, self.frame.width, self.frame.height);
//        UIGraphicsBeginImageContext(rect.size);
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale);
        let context:CGContextRef = UIGraphicsGetCurrentContext()!;
        
        CGContextSetFillColorWithColor(context, color);
//        CGContextFillRect(context, rect);
        
        CGContextMoveToPoint(context, w, h - 20);
        CGContextAddArcToPoint(context, w, h, w - 20, h, 4);// 右下角角度
        
//        CGContextMoveToPoint(context, 20, h);
        CGContextAddArcToPoint(context, 0, h, 0, h - 20, 4); // 左下角角度
        
//        CGContextMoveToPoint(context, 0, 0 + 20);
        CGContextAddArcToPoint(context, 0, 0, 0 + 20, 0, 4); // 左上角
        
//        CGContextMoveToPoint(context, w - 20, 0);
        CGContextAddArcToPoint(context, w, 0, w, 0 + 20, 4); // 右上角
        CGContextClosePath(context);
        
        CGContextDrawPath(context, CGPathDrawingMode.Fill);
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    var nColor:CGColor?;
    var eColor:CGColor = UIColor.grayColor().CGColor;
    
    func setBackgroundImageColor(nColor:CGColor, hColor:CGColor)
    {
        self.nColor = nColor;
        
        self.layer.borderColor =  nColor;
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = 4;
        self.layer.backgroundColor = nColor;
        
//        let nImg = imageWithColor(nColor);
//        let hImg = imageWithColor(hColor);
//        
//        self.setBackgroundImage(nImg, forState: UIControlState.Normal);
//        self.setBackgroundImage(hImg, forState: UIControlState.Highlighted);
        
//        self.addTarget(self, action: "onInside:", forControlEvents: UIControlEvents.TouchDown);
    }
    
    func setButtonEnabled(e:Bool)
    {
        self.enabled = e;
        
        if(self.enabled)
        {
            self.layer.borderColor =  nColor;
            self.layer.backgroundColor = nColor;
        }
        else
        {
            self.layer.borderColor =  eColor;
            self.layer.backgroundColor = eColor;
        }
    }
}
