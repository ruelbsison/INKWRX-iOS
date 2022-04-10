//
//  IWSvcGetUserPrepopDataRequest.swift
//  Inkworks
//
//  Created by Paul Gowing on 15/01/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWSvcGetUserPrepopDataRequest: NSObject {
    //fields
    open var UserName:String = "";
    open var Password:String = "";
    open var CurrentVersion:Int = -1;
    
    open var NameSpace:String = "";
    open var Name:String = "";
    
    fileprivate var propertyNamespace:String = "";
    
    public init(name:String, nameSpace:String, propNameSpace:String) {
        super.init();
        Name = name;
        NameSpace = nameSpace;
        propertyNamespace = propNameSpace;
    }
    
    public convenience init(nameSpace:String, propNameSpace:String) {
        self.init(name: "SvcGetUserPrepopDataRequest", nameSpace: nameSpace, propNameSpace: propNameSpace)
    }

    
    func GetFieldOrder() -> Array<String>{
        return ["UserName", "Password", "CurrentVersion"];
    }
    
    func GetFields() -> Dictionary<String, AnyObject>{
        var ret : Dictionary<String, AnyObject> = Dictionary<String, AnyObject>();
        ret.updateValue(self.UserName as AnyObject, forKey: "UserName");
        ret.updateValue(self.Password as AnyObject, forKey: "Password");
        ret.updateValue(self.CurrentVersion as AnyObject, forKey: "CurrentVersion");
        return ret;
    }
    
    func GetXml() -> String {
        var fields : Dictionary<String, AnyObject> = GetFields();
        
        var fieldOrder = GetFieldOrder();
        
        var xml : String = "";
        xml += "        <n2:" + Name + " xmlns:n2=\"" + NameSpace + "\" xmlns:n3=\"" + propertyNamespace + "\">\n";
        
        xml += "            <n3:UserName>" + UserName + "</n3:UserName>\n";
        xml += "            <n3:Password>" + Password + "</n3:Password>\n";
        xml += "            <n3:CurrentVersion>" + String(CurrentVersion) + "</n3:CurrentVersion>\n";
        
        xml += "        </n2:" + Name + ">\n";
        return xml;
    }
}
