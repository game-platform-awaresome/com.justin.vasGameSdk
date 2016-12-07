//
//  NetProxy.swift
//  VasGameSDK
//
//  Created by justin on 15/12/22.
//  Copyright © 2015年 justin. All rights reserved.
//

import UIKit

class NetProxy: NSObject, NSURLSessionDownloadDelegate
{
    static var ins:NetProxy!;
    static var token:dispatch_once_t = 0;
    
    func requestDataByPost(url:String, postStr:String, onComplete:(NSData?, NSURLResponse?, NSError?)->Void)
    {
        let nsUrl:NSURL! = NSURL(string: url);
        
        let postData:NSData = NSString(string: postStr).dataUsingEncoding(NSUTF8StringEncoding)!;
        
        let nsRequest:NSMutableURLRequest! = NSMutableURLRequest(URL: nsUrl);
        nsRequest.HTTPMethod = "POST";
        nsRequest.HTTPBody = postData;
        
//        print("nsRequest: \(nsRequest.description)");
        
        let nsDession:NSURLSession! = NSURLSession.sharedSession();
        
        let nsDataTask:NSURLSessionDataTask = nsDession.dataTaskWithRequest(nsRequest, completionHandler: onComplete);
        
        nsDataTask.resume();
    }
    
    func requestDataByGet(url:String, postStr:String, onComplete:(NSData?, NSURLResponse?, NSError?)->Void)
    {
        let nsUrl:NSURL! = NSURL(string: url + postStr);
        
        let nsRequest:NSMutableURLRequest! = NSMutableURLRequest(URL: nsUrl);
        
//        print("nsRequest: \(nsRequest.description)");
        
        let nsDession:NSURLSession! = NSURLSession.sharedSession();
        
        let nsDataTask:NSURLSessionDataTask = nsDession.dataTaskWithRequest(nsRequest, completionHandler: onComplete);
        
        nsDataTask.resume();
    }
    
    func requestImg(url:String, onComplete:(location:NSURL?, NSURLResponse?, NSError?)->Void)
    {
        let nsUrl:NSURL! = NSURL(string: url);
        
        let nsRequest:NSURLRequest! = NSURLRequest(URL: nsUrl);
        
        let nsDession:NSURLSession! = NSURLSession.sharedSession();
        
        let nsDownLoadTask:NSURLSessionDownloadTask = nsDession.downloadTaskWithRequest(nsRequest, completionHandler: onComplete);
        
        nsDownLoadTask.resume();
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL)
    {
        print("URLSession: didFinishDownloadingToURL");
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        let downloadProgress:Double = Double(totalBytesWritten)/(Double(totalBytesExpectedToWrite));
        
        print("URLSession.Progress: \(totalBytesWritten), \(totalBytesExpectedToWrite), \(downloadProgress)");
    }
    
    
    static var sharedInstance:NetProxy
    {
        dispatch_once(&NetProxy.token)
            {
                NetProxy.ins = NetProxy();
        }
        
        return NetProxy.ins;
    }

}
