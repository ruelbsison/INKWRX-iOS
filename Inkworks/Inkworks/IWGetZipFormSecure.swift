//
//  IWGetZipFormSecure.swift
//  Inkworks
//
//  Created by Jamie Duggan on 03/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWGetZipFormSecure: IWSecureObject {
    open var ApplicationId : Int = -1;
    
    public override init() {
        super.init();
        self.FunctionName = "getzipformsecure";
    }
    
    public convenience init(userName: String, password: String, appId: Int) {
        self.init();
        self.Username = userName;
        self.PasswordHash = password;
        self.ApplicationId = appId;
    }
    
    internal override func GetXmlFields() -> String {
        var ret : String = "";
        ret += "     <applicationkey>\(ApplicationId)</applicationkey>\n";
        ret += "     <fulllexicon>true</fulllexicon>\n";
        return ret;
    }

}
