//
//  PayViewController.swift
//  VasGameSDK
//
//  Created by justin on 16/2/2.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class PayViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var name: UILabel!;
    @IBOutlet weak var pass: UITextField!;
    
    var showName:String?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        name.text = showName;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PayViewController.onRequestPayGCoinBack(_:)), name: GCoinProxy.REQUEST_PAY_GCOIN_BACK_EVENT, object: nil);
    }
    
    func onRequestPayGCoinBack(no:NSNotification)
    {
        dispatch_async(dispatch_get_main_queue(),
            {
                let data:NSDictionary? = no.object as? NSDictionary;
                
                let status = data!["status"] as! Int;
                let message = data!["message"] as! String;
                
                let title:String?;
                
                LoadingView.sharedInstance.stopWork();
                
                if(status != 1)
                {
                    title = "错误";
                    
                    AlertManager.sharedInstance.show(title!, message: message, btnTitle: ["好的"], parentVc: self);
                }
                else
                {
                    let vc = SDKMain.sharedInstance.board!.instantiateViewControllerWithIdentifier("welcomeVc") as! UINavigationController;
                    
                    let wel = vc.childViewControllers.first as! WelcomeViewController;
                    
                    wel.showName = UserProxy.sharedInstance.showName!;
                    wel.isGuest = UserProxy.sharedInstance.isGuest!;
                    
                    self.presentViewController(vc, animated: true, completion: nil);
                }
        });
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder();
        
        return true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPay(sender: AnyObject)
    {
        LoadingView.sharedInstance.startWork(self);
        
        let data:NSDictionary = NSDictionary(objects: [name.text!, pass.text!, 1], forKeys: ["name", "pass", "amount"]);
        
        NSNotificationCenter.defaultCenter().postNotificationName(GCoinProxy.REQUEST_PAY_GCOIN_EVENT, object: data);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
