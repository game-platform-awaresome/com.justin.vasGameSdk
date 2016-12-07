//
//  PassWebEVViewController.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/20.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit

class PassWebEVViewController: UIViewController, UIWebViewDelegate {

    var wk:UIWebView?;
    var urlStr:String? = "http://game.g.pptv.com/mobile/fetchpassword/?type=mobile&username=";
    var name:String?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        let url = NSURL(string: (urlStr! + name!));
        
        let request = NSURLRequest(URL: url!);
        
        wk = UIWebView(frame: self.view.frame);
        wk?.loadRequest(request);
        self.view.addSubview(wk!);
        
        wk?.delegate = self;
        
        LoadingView.sharedInstance.startWork(self);
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
        LoadingView.sharedInstance.stopWork();
    }

    @IBAction func onBack(sender: AnyObject)
    {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
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
