//
//  PassWebViewController.swift
//  VasSdkDemo
//
//  Created by justin on 16/4/18.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import WebKit

@available(iOS 8.0, *)
class PassWebViewController: UIViewController, WKNavigationDelegate
{
    var wk:WKWebView?;
    var urlStr:String? = "http://game.g.pptv.com/mobile/fetchpassword/?type=mobile&username=";
    var name:String?;
    
    static let GOTO_PASS:String = "goto_pass";
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(sender: AnyObject)
    {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.BACK, object: nil, userInfo: ["fukey":BipProxy.FORGET_PASS_WEB_PAGE, "ukey":BipProxy.FORGET_PASS_PAGE]);
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        let url = NSURL(string: (urlStr! + name!));
        
        let request = NSURLRequest(URL: url!);
        
        wk = WKWebView(frame: self.view.frame);
        wk?.loadRequest(request);
        self.view.addSubview(wk!);
        
        wk?.navigationDelegate = self;
        
        LoadingView.sharedInstance.startWork(self);
        
        NSNotificationCenter.defaultCenter().postNotificationName(PassWebViewController.GOTO_PASS, object: nil);
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError)
    {
        print(error.debugDescription);
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError)
    {
        print(error.debugDescription);
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!)
    {
        LoadingView.sharedInstance.stopWork();
    }
    
    override func shouldAutorotate() -> Bool
    {
        return Common.shouldAutorotate;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return Common.supportedInterfaceOrientations;
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
