//
//  IWSvcGetUserPrepopDataResponse.swift
//  Inkworks
//
//  Created by Paul Gowing on 15/01/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWSvcGetUserPrepopDataResponse: NSObject {
    open var VersionNumber: Int = -1;
    open var Data: String = "";
    open var ResultCode: Int = -1;
    open var Message: String = "";
    
    open var NameSpace:String = "";
    open var Name:String = "";
    
    
    fileprivate var propertyNamespace:String = "";
    
    public init(name:String, nameSpace:String) {
        super.init();
        Name = name;
        NameSpace = nameSpace;
    }
    
    public convenience init(nameSpace:String, xml:TBXMLElement) {
        self.init(nameSpace:nameSpace);
        
        //var versionElem =
        
//        for elem in xmlSource {
//            var elemName = elem.element?.name as String!;
//            switch elemName {
//                case "VersionNumber":
//                    if (elem.element?.text != "") {
//                        var val = elem.element?.text;
//                        VersionNumber = val?.toInt() as Int!;
//                    }
//                    break;
//                case "Data":
//                    Data = elem.element?.text as String!;
//                    break;
//                case "ResultCode":
//                    if (elem.element?.name != "") {
//                        var val = elem.element?.text;
//                        ResultCode = val?.toInt() as Int!;
//                    }
//                    break;
//                case "Message":
//                    Message = elem.element?.text as String!;
//                    break;
//                default:
//                    break;
//            }
//        }
    }
    
    public convenience init(nameSpace:String) {
        self.init(name: "SvcGetUserPrepopDataResponse", nameSpace: nameSpace)
    }

    
    func GetFieldOrder() -> Array<String>{
        return ["VersionNumber", "Data", "ResultCode", "Message"];
    }
    
    func GetFields() -> Dictionary<String, AnyObject>{
        let ret:Dictionary<String, AnyObject> = ["VersionNumber" : VersionNumber as AnyObject, "Data" : Data as AnyObject, "ResultCode" : ResultCode as AnyObject, "Message" : Message as AnyObject];
        return ret;
    }
    
    func GetXml() -> String {
        var fields : Dictionary = GetFields();
        let fieldOrder = GetFieldOrder();
        
        var xml : String = "";
        xml += "        <n2:" + Name + " xmlns:n2=\"" + NameSpace + "\" xmlns:n3=\"" + propertyNamespace + "\">\n";
        for key in fieldOrder {
            let fieldVal:String! = fields[key]?.value;
            xml += "            <n3:" + key + ">" + fieldVal + "</n3:" + key + ">\n";
        }
        xml += "        </n2:" + Name + ">\n";
        return xml;
    }
}

    
    
    
   

