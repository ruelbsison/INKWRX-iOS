//
//  IWSendFileWithTablet.swift
//  Inkworks
//
//  Created by Jamie Duggan on 02/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWSendFileWithTablet: IWSecureObject {
    
    open var FileName : String = "";
    open var FileData : String = "";
    
    public override init() {
        super.init();
        self.FunctionName = "sendfilewithtablet";
    }
    
    public convenience init(userName: String, password: String, fileName:String, fileData:String) {
        self.init();
        self.Username = userName;
        self.PasswordHash = password;
        self.FileName = fileName;
        self.FileData = fileData;
    }
    
    internal override func GetXmlFields() -> String {
        var ret : String = "";
        ret += "    <filename>\(FileName)</filename>\n";
        ret += "    <filedata>\(FileData)</filedata>\n";
        return ret;
    }
}
