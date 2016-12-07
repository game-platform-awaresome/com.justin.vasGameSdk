//
//  AppPayProxy.swift
//  VasGameSDK
//
//  Created by justin on 16/3/10.
//  Copyright © 2016年 justin. All rights reserved.
//

import UIKit
import StoreKit

class AppPayProxy: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate
{
    static let REQUEST_PRODUCT:String = "request_product";
    static let REQUEST_PRODUCT_BACK:String = "request_product_event";
    
    static let REQUEST_BUY_PRODUCT:String = "request_buy_product";
    static let REQUEST_BUY_PRODUCT_BACK:String = "request_buy_product_back";
    
    
    static var ins:AppPayProxy!;
    static var token:dispatch_once_t = 0;
    
    static var sharedInstance:AppPayProxy
    {
        dispatch_once(&AppPayProxy.token)
            {
                AppPayProxy.ins = AppPayProxy();
        }
        
        return AppPayProxy.ins;
    }
    
    
    let VERIFY_RECEIPT_URL = "https://buy.itunes.apple.com/verifyReceipt";
    let ITMS_SANDBOX_VERIFY_RECEIPT_URL = "https://sandbox.itunes.apple.com/verifyReceipt";
    
    var productDic:NSMutableDictionary!;
    
    var productIdArr:[String] = [];
    
    var isWorking:Bool = false;
    
    //    applePay
    //    com.pptv.vas.game.30y
    //    com.pptv.vas.game.6y
    //    vasgame@pptv.com
    //    2WAt6AxB
    
    func startWork()
    {
        if(isWorking)
        {
            print("AppPayProxy startWork twice...");
            
            return;
        }
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppPayProxy.onRequestProduct(_:)), name: AppPayProxy.REQUEST_PRODUCT, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppPayProxy.onRequestBuyProduct(_:)), name: AppPayProxy.REQUEST_BUY_PRODUCT, object: nil);
        
        isWorking = true;
    }
    
    func stopWork()
    {
        if(!isWorking)
        {
            return;
        }
        
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AppPayProxy.REQUEST_PRODUCT, object: nil);
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AppPayProxy.REQUEST_BUY_PRODUCT, object: nil);
        
        isWorking = false;
    }
    
    func onRequestBuyProduct(no:NSNotification)
    {
        let data = no.userInfo;
        
        let p = data!["productId"] as! String;
        
        onSelectRechargePackages(p);
    }
    
    func onRequestProduct(no:NSNotification)
    {
        let data = no.userInfo;
        
        let pIdArr = data!["pIdArr"] as! [String];
        
        requestProducts(pIdArr);//请求产品列表资料
    }
    
    //询问苹果的服务器能够销售哪些商品
    func requestProducts(pIdArr:[String])
    {
        let set = NSSet(array: pIdArr);
        let request = SKProductsRequest(productIdentifiers: (set as! Set<String>));
        request.delegate = self;
        request.start();
    }
    
    
    
    // 以上查询的回调函数
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse)
    {
        print("response:\(response), \(response.products)")
        
        if (productDic == nil)
        {
            productDic = NSMutableDictionary(capacity: response.products.count)
        }
        
        for product in response.products
        {
            // 激活了对应的销售操作按钮，相当于商店的商品上架允许销售
            print("product id: \(product.productIdentifier)");
            print("产品标题: \(product.localizedTitle)");
            print("产品描述信息: \(product.localizedDescription)");
            print("价格: \(product.price)");
            
            // 填充商品字典
            productDic.setObject(product, forKey: product.productIdentifier);
        }
        
        let resultDic = ["status":"1", "message":"成功", "data":productDic];
//        NSDictionary(objects: [100, "成功", productDic], forKeys: ["status", "message", "data"]);
        
        NSNotificationCenter.defaultCenter().postNotificationName(AppPayProxy.REQUEST_PRODUCT_BACK, object: nil, userInfo: resultDic);
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.APPLE_PRODUCT_INFO_BACK, object: nil, userInfo: resultDic);
        
        print("SDKMain.APPLE_PRODUCT_INFO_BACK");
    }
    
    // 点击购买产品后触发的
    func onSelectRechargePackages(productId: String)
    {
        //先判断是否支持内购
        if(SKPaymentQueue.canMakePayments())
        {
            buyProduct(productDic[productId] as! SKProduct);
        }
        else
        {
            print("不支持内购功能");
        }
        
    }
    
    // 购买对应的产品
    func buyProduct(product: SKProduct)
    {
        let payment = SKPayment(product: product);
        SKPaymentQueue.defaultQueue().addPayment(payment);
        
        BipProxy.sharedInstance.sendBip("165", fukey: "", ukey: "", productid: product.productIdentifier, buystat: "0");
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        // 调试
        for transaction in transactions
        {
//            transaction
            // 如果小票状态是购买完成
            if(SKPaymentTransactionState.Purchased == transaction.transactionState)
            {
                // 更新界面或者数据，把用户购买得商品交给用户
                print("支付成了");
                // 验证购买凭据
                self.verifyPruchase(transaction);
//                transaction.payment
                // 将交易从交易队列中删除
                SKPaymentQueue.defaultQueue().finishTransaction(transaction);
                
                BipProxy.sharedInstance.sendBip("165", fukey: "", ukey: "", productid: transaction.payment.productIdentifier, buystat: "1");
                
                let resultDic = ["status":"2", "message":"成功", "id":transaction.payment.productIdentifier, "transaction":transaction];
                NSNotificationCenter.defaultCenter().postNotificationName(AppPayProxy.REQUEST_BUY_PRODUCT_BACK, object: nil, userInfo: resultDic as [NSObject : AnyObject]);
                
                NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.APPLE_PRODUCT_BUY_RESULT, object: nil, userInfo: resultDic as [NSObject : AnyObject]);
            }
            else if(SKPaymentTransactionState.Failed == transaction.transactionState)
            {
                print("支付失败");
                SKPaymentQueue.defaultQueue().finishTransaction(transaction);
                
                let resultDic = ["status":"0", "message":"失败", "id":"", "transaction":transaction];
                NSNotificationCenter.defaultCenter().postNotificationName(AppPayProxy.REQUEST_BUY_PRODUCT_BACK, object: nil, userInfo: resultDic);
                
                NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.APPLE_PRODUCT_BUY_RESULT, object: nil, userInfo: resultDic);
            }
            else if(SKPaymentTransactionState.Restored == transaction.transactionState)
            {
                print("恢复购买");
                //恢复购买
                // 更新界面或者数据，把用户购买得商品交给用户
                // ...
                
                // 将交易从交易队列中删除
                SKPaymentQueue.defaultQueue().finishTransaction(transaction);
            }
        }
    }
    
    func verifyPruchase(transaction:SKPaymentTransaction)
    {
        // 验证凭据，获取到苹果返回的交易凭据
        // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
        let receiptURL = NSBundle.mainBundle().appStoreReceiptURL
        // 从沙盒中获取到购买凭据
        let receiptData = NSData(contentsOfURL: receiptURL!)
        // 发送网络POST请求，对购买凭据进行验证
        let url = NSURL(string: ITMS_SANDBOX_VERIFY_RECEIPT_URL)//VERIFY_RECEIPT_URL, ITMS_SANDBOX_VERIFY_RECEIPT_URL
        // 国内访问苹果服务器比较慢，timeoutInterval需要长一点
        let request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10.0)
        request.HTTPMethod = "POST";
        
        // 在网络中传输数据，大多情况下是传输的字符串而不是二进制数据
        // 传输的是BASE64编码的字符串
        /**
        BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
        BASE64是可以编码和解码的
        */
        let encodeStr = receiptData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
        
        let payload = NSString(string: "{\"receipt-data\" : \"" + encodeStr! + "\"}")
//        print(payload);
        let payloadData = payload.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.HTTPBody = payloadData;
        
        // 提交验证请求，并获得官方的验证JSON结果
        let result = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil);
        
        // 官方验证结果为空
        if (result == nil) {
            //验证失败
            print("验证失败")
            return;
        }
        let dict: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(result!, options: NSJSONReadingOptions.AllowFragments);
        
        if (dict != nil)
        {
            // 比对字典中以下信息基本上可以保证数据安全
            // bundle_id&application_version&product_id&transaction_id
            // 验证成功
            print(dict);
            
            let resultDic = ["status":"1", "message":"成功", "id":transaction.payment.productIdentifier, "transaction":transaction];
            NSNotificationCenter.defaultCenter().postNotificationName(SDKMain.APPLE_PRODUCT_BUY_RESULT, object: nil, userInfo: resultDic as [NSObject : AnyObject]);
        }
    }
    
    func restorePurchase()
    {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions();
    }
}
