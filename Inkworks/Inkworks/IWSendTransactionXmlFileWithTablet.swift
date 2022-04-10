//
//  IWSendTransactionXmlFileWithTablet.swift
//  Inkworks
//
//  Created by Jamie Duggan on 02/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWSendTransactionXmlFileWithTablet: IWSecureObject {
   
    open var FileName : String = "";
    open var TransactionXmlData : String = "";
    
    public convenience init(userName: String, password: String, fileName:String, transXml:String) {
        self.init();
        self.Username = userName;
        self.PasswordHash = password;
        self.FileName = fileName;
        self.TransactionXmlData = transXml;
    }
    
    public override init() {
        super.init();
        self.FunctionName = "sendtransactionxmlfilewithtablet";
    }
    
    internal override func GetXmlFields() -> String {
        var ret : String = "";
        ret += "    <filename>\(FileName)</filename>\n";
        ret += "    <transactionxmldata><![CDATA[\(TransactionXmlData)]]></transactionxmldata>\n"
        return ret;
    }
}
