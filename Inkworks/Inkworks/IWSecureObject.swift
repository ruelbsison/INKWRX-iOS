//
//  IWSecureObject.swift
//  Inkworks
//
//  Created by Jamie Duggan on 02/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWSecureObject: NSObject {
   
    open var FunctionName : String = "";
    open var Username : String = "";
    open var PasswordHash : String = "";
    
    fileprivate func GetXmlDeviceTag() -> String {
        var ret : String = "    <device>\n";
        ret += "        <os>iOS</os>\n";
        let procInfo = ProcessInfo();
        let os = procInfo.operatingSystemVersion;
        ret += "        <osversion>\(os.majorVersion).\( os.minorVersion).\(os.patchVersion)</osversion>\n";
        ret += "        <make>Apple</make>\n";
        ret += "        <model>\(UIDevice.current.model)</model>\n";
        ret += "        <tabletid>\(UIDevice.current.identifierForVendor!.uuidString)</tabletid>\n";
        ret += "    </device>\n";
        return ret;
    }
    
    fileprivate func GetXmlHeader() -> String {
        return "<data>\n\(GetXmlDeviceTag())    <function>\(FunctionName)</function>\n    <username>\(Username)</username>\n    <password>\(PasswordHash)</password>\n";
    }
    
    internal func GetXmlFields() -> String {
        return "";
    }
    
    fileprivate func GetXmlCloser() -> String {
        return "</data>";
    }
    
    open func GetXml () -> String {
        var ret : String = GetXmlHeader();
        ret += GetXmlFields();
        ret += GetXmlCloser();
        return ret;
    }
    
}
