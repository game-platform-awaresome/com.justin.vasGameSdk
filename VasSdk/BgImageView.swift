//
//  BgImageView.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/15.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class BgImageView: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect)
    {
        super.init(frame: frame);
        
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);
        
        self.image = UIImage(named: "game_bg");
    }
}
