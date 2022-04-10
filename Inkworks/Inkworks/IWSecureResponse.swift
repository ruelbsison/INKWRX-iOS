//
//  IWSecureResponse.swift
//  Inkworks
//
//  Created by Jamie Duggan on 02/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWSecureResponse: NSObject {
    fileprivate var originalXml : String = "";
    
    open var ErrorCode : Int = -1;
    open var Message : String = "";
    open var ConfigV : String = "";
    open var AppParamVersion : String = "";
    open var PrintParamVersion : String = "";
    open var Restart : Bool = false;
    open var NextPacketId : Int = -1;
    open var PrepopData : String = "";
    open var PrepopVersion : Int = -1;
    open var ByteData : String = "";
    
    public convenience init(xml: String) {
        self.init();
        self.originalXml = xml;
        if originalXml == "" {return;}
        let swxml = SWXMLHash.parse(originalXml);
        let response = swxml["response"];
        if response.element == nil {return;}
        
        let errorcode = response["errorcode"];
        if errorcode.element?.text != nil {
            self.ErrorCode = Int(errorcode.element!.text!)!;
        }
        let msg = response["message"];
        if msg.element?.text != nil {
            self.Message = msg.element!.text!;
        }
        let configv = response["configv"];
        if configv.element?.text != nil {
            self.ConfigV = configv.element!.text!;
        }
        let appparamv = response["appparamversion"];
        if appparamv.element?.text != nil {
            self.AppParamVersion = appparamv.element!.text!;
        }
        let printparamv = response["printparamversion"];
        if printparamv.element?.text != nil {
            self.PrintParamVersion = printparamv.element!.text!;
        }
        let restart = response["restart"];
        if restart.element?.text != nil {
            self.Restart = restart.element!.text! == "true";
        }
        let nextpacketid = response["nextpacketid"];
        if nextpacketid.element?.text != nil {
            self.NextPacketId = Int(nextpacketid.element!.text!)!;
        }
        let prepopData = response["filedata"];
        if prepopData.element?.text != nil {
            self.PrepopData = prepopData.element!.text!;
        }
        let prepopVersion = response["versionnumber"];
        if (prepopVersion.element?.text != nil) {
            self.PrepopVersion = Int(prepopVersion.element!.text!)!;
        }
        let bytedata = response["bytedata"];
        if (bytedata.element?.text != nil) {
            self.ByteData = bytedata.element!.text!;
        }
    }
}
