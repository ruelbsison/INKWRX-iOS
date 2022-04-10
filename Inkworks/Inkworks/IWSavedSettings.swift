//
//  IWSavedSettings.swift
//  Inkworks
//
//  Created by Jamie Duggan on 04/04/2017.
//  Copyright © 2017 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWSavedSettings: NSObject {
    open var ColumnIndex : Int64 = -1;
    open var SettingName : String = "";
    open var SettingValue : String = "";
    
    public override init() {
        
    }
    
    public init (index: Int64, name: String, value: String) {
        super.init();
        self.ColumnIndex = index;
        self.SettingName = name;
        self.SettingValue = value;
    }
}
