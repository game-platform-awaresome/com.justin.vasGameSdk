//
//  LoadingView.swift
//  HeartBook
//
//  Created by justin on 16/1/12.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    static var ins:LoadingView!;
    static var token:dispatch_once_t = 0;
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var rc: UIActivityIndicatorView?;
    
    var desc:UILabel?;
    
    override init(frame: CGRect)
    {
        super.init(frame: frame);
        
        rc = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray);
        self.addSubview(rc!);
        
//        self.backgroundColor = UIColor.grayColor();
//        self.alpha = 0.5;
        
        let rec = UIScreen.mainScreen().bounds;
        
        let rWidth = rc?.bounds.width;
        let w = rec.width/2 - rWidth!/2;
        
        rc?.frame = CGRect(x: w, y: rec.height/2, width: 20, height: 20);
        
        desc = UILabel(frame: CGRect(x: rec.width/2, y: rec.height/2 + 20, width: 30, height: 20));
        desc?.textAlignment = NSTextAlignment.Center;
        self.addSubview(desc!);
        desc?.textAlignment = NSTextAlignment.Center;
        desc?.adjustsFontSizeToFitWidth = true;
    }
    
    func startWork(pVC:UIViewController, descTxt:String = "")
    {
        pVC.view.addSubview(self);
        
        rc?.startAnimating();
        
        desc?.text = descTxt;
        
        let rec = UIScreen.mainScreen().bounds;
        
        let w = rec.width/2 - (desc?.bounds.width)!/2;
//        print("-----loading: desc?.bounds.width:\(desc?.bounds.width), UIScreen.mainScreen().bounds:\(UIScreen.mainScreen().bounds)")
        desc?.frame = CGRect(x: w, y: rec.height/2 + 20, width: 30, height: 20);
    }
    
    func stopWork()
    {
        self.removeFromSuperview();
        
        rc?.stopAnimating();
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var sharedInstance:LoadingView
    {
        dispatch_once(&LoadingView.token)
            {
                let rec = UIScreen.mainScreen().bounds;
                
                LoadingView.ins = LoadingView(frame: rec);
        }
        
        return LoadingView.ins;
    }
}
