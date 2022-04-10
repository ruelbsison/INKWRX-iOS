//
//  IWSendData.swift
//  Inkworks
//
//  Created by Jamie Duggan on 02/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWSendData: NSObject {
    open var Date : String = "";
    open var Data : String = "";
    
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
        self.init(name: "DestInputMsg", nameSpace: nameSpace, propNameSpace: propNameSpace)
    }
    
    func GetFields() -> Dictionary<String, AnyObject>{
        var ret : Dictionary<String, AnyObject> = Dictionary<String, AnyObject>();
        ret.updateValue(self.Date as AnyObject, forKey: "Date");
        ret.updateValue(self.Data as AnyObject, forKey: "Data");
        return ret;
    }
    
    func GetXml() -> String {
        var fields : Dictionary<String, AnyObject> = GetFields();
        
        
        var xml : String = "";
        xml += "        <n2:\(Name) xmlns:n2=\"\(NameSpace)\" xmlns:n3=\"\(propertyNamespace)\">\n";
        
        xml += "            <n3:Date>\(Date)</n3:Date>\n";
        xml += "            <n3:Data>\(Data)</n3:Data>\n";
        
        xml += "        </n2:\(Name)>\n";
        return xml;
    }
}
