//
//  RegChooseViewController.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/14.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class RegChooseViewController: UIViewController {

    @IBOutlet weak var iV: UIView!;
    @IBOutlet weak var phoneReg: ColorButton!;
    @IBOutlet weak var userReg: ColorButton!;
    @IBOutlet weak var check: UIButton!
    
    static let GOTO_REG_CHOOSE:String = "goto_reg_choose";
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        iV.layer.borderWidth = 2;
        iV.layer.cornerRadius = 10;
        iV.layer.borderColor = self.view.backgroundColor?.CGColor;
        
        check.selected = true;
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        phoneReg.setBackgroundImageColor(ColorButton.oC , hColor: UIColor.grayColor().CGColor);
        userReg.setBackgroundImageColor(UIColor.blackColor().CGColor , hColor: UIColor.grayColor().CGColor);
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onCheck(sender: AnyObject)
    {
        check.selected = !check.selected;
        
        if(check.selected)
        {
            phoneReg.setButtonEnabled(true);
            userReg.setButtonEnabled(true);
        }
        else
        {
            phoneReg.setButtonEnabled(false);
            userReg.setButtonEnabled(false);
        }
    }
    
    override func shouldAutorotate() -> Bool
    {
        return Common.shouldAutorotate;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return Common.supportedInterfaceOrientations;
    }
}
