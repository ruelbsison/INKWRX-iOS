//
//  IWValidateTablet.swift
//  Inkworks
//
//  Created by Jamie Duggan on 02/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWValidateTablet: IWSecureObject {
    
    public override init() {
        super.init();
        self.FunctionName = "validatetablet";
    }
    
    public convenience init(userName: String, password: String) {
        self.init();
        self.Username = userName;
        self.PasswordHash = password;
    }
}
