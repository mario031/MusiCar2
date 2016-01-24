//
//  CloudVisionRequest.swift
//  MusiCar2
//
//  Created by 石川伶 on 2016/01/23.
//  Copyright © 2016年 石川伶. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

public class CloudVisionRequest{
    
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    var userDefault:NSUserDefaults = NSUserDefaults()
    
    func smileRequest(image: UIImage) -> Bool{
        let pngImage = UIImagePNGRepresentation(image)
        let base64String:String = pngImage!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        let obj:[String:AnyObject] = [
            "requests":[
                "image":[
                    "content":"\(base64String)"
                ],
                "features":[
                    "type":"FACE_DETECTION",
                    "maxResults":1
                ]
            ]
        ]
        let data = try! NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions.PrettyPrinted)
        //URLの指定
        let url: NSURL! = NSURL(string: "https://vision.googleapis.com/v1alpha1/images:annotate?key=AIzaSyCtSGD5NJPCRv-1f5p9qpmDvpIaA4Ylskw")
        let request = NSMutableURLRequest(URL: url)

        request.setValue("application/json", forHTTPHeaderField: "Content-type")

        //POSTを指定
        request.HTTPMethod = "POST"
        //Dataをセット
        request.HTTPBody = data
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: self.getSmileHttp)
        
        return true
    }
    //レスポンスが帰ってきたら行う関数
    func getSmileHttp(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
            let json = JSON(data:data!)
            let happyFace = json["responses"][0]["faceAnnotations"][0]["joyLikelihood"]
//            print(dataString)
            if(happyFace.string != nil){
                appDelegate.data_mood.append(happyFace.stringValue)
                print(happyFace.stringValue)
            }else if(happyFace.string == nil){
                appDelegate.data_mood.append("no_face")
                print("no face")
            }
            let data:NSString = "smile=\(appDelegate.data_mood)&uid=\(userDefault.objectForKey("uid") as! String)"
            let myData:NSData = data.dataUsingEncoding(NSUTF8StringEncoding)!
            //URLの指定
            let url: NSURL! = NSURL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~mario/MusiCar/insert.php")
            let request = NSMutableURLRequest(URL: url)
            
            //POSTを指定
            request.HTTPMethod = "POST"
            //Dataをセット
            request.HTTPBody = myData
            if(appDelegate.data_mood.count == 10){
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: self.postMood)
                appDelegate.data_mood.removeAll()
            }
            
        }
        
    }
    func postMood(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            //            print(dataString)
        }
    }
    
    func textRequest(image: UIImage) -> Bool{
        let pngImage = UIImagePNGRepresentation(image)
        let base64String:String = pngImage!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        let obj:[String:AnyObject] = [
            "requests":[
                "image":[
                    "content":"\(base64String)"
                ],
                "features":[
                    "type":"TEXT_DETECTION",
                    "maxResults":1
                ]
            ]
        ]
        let data = try! NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions.PrettyPrinted)
        //URLの指定
        let url: NSURL! = NSURL(string: "https://vision.googleapis.com/v1alpha1/images:annotate?key=AIzaSyCtSGD5NJPCRv-1f5p9qpmDvpIaA4Ylskw")
        let request = NSMutableURLRequest(URL: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        //POSTを指定
        request.HTTPMethod = "POST"
        //Dataをセット
        request.HTTPBody = data
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: self.getTextHttp)
       
       return true
    }
    func getTextHttp(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            let json = JSON(data:data!)
            let carNumber = json["responses"][0]["textAnnotations"][0]["description"]
            print(carNumber.stringValue)
            if(carNumber.string != nil){
                userDefault.setObject(carNumber.stringValue, forKey: "number")
            }
        }
    }
}