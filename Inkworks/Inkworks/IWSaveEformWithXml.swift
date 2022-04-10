//
//  IWSaveEformWithXml.swift
//  Inkworks
//
//  Created by Jamie Duggan on 02/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWSaveEformWithXml: IWSecureObject {
    open var XmlData : String = "";
    open var PenData : String = "";
    open var ApplicationKey : Int = -1;
    open var TransactionXml : String = "";
    
    public override init() {
        super.init();
        self.FunctionName = "saveeformwithxml";
    }
    
    public convenience init(userName : String, password : String, xmlData: String, penData: String, appKey: Int, transXml: String) {
        self.init();
        self.Username = userName;
        self.PasswordHash = password;
        self.XmlData = xmlData;
        self.PenData = penData;
        self.ApplicationKey = appKey;
        self.TransactionXml = transXml;
    }
    
    internal override func GetXmlFields() -> String {
        var ret : String = "";
        ret += "    <xmldata><![CDATA[\(XmlData)]]></xmldata>\n";
        ret += "    <pendata><![CDATA[\(PenData)]]></pendata>\n";
        ret += "    <applicationkey>\(ApplicationKey)</applicationkey>\n";
        ret += "    <transactionxmldata><![CDATA[\(TransactionXml)]]></transactionxmldata>\n";
        
        
        return ret;
    }
}
