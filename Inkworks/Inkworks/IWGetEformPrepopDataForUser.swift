//
//  IWGetEformPrepopDataForUser.swift
//  Inkworks
//
//  Created by Jamie Duggan on 02/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWGetEformPrepopDataForUser: IWSecureObject {
    open var CurrentVersion : Int = -1;
    
    public override init() {
        super.init();
        self.FunctionName = "geteformprepopdataforuser";
    }
    
    public convenience init(userName: String, password: String, currVer: Int) {
        self.init();
        self.Username = userName;
        self.PasswordHash = password;
        self.CurrentVersion = currVer;
    }
    
    internal override func GetXmlFields() -> String {
        var ret : String = "";
        ret += "     <currentversion>\(CurrentVersion)</currentversion>\n";
        return ret;
    }
}
