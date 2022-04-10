//
//  IWGetEforms.swift
//  Inkworks
//
//  Created by Jamie Duggan on 03/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWGetEforms: IWSecureObject {
    public override init() {
        super.init();
        self.FunctionName = "geteforms";
    }
    
    public convenience init(userName: String, password: String) {
        self.init();
        self.Username = userName;
        self.PasswordHash = password;
    }
}
