//
//  IWFolder.swift
//  Inkworks
//
//  Created by Jamie Duggan on 31/03/2017.
//  Copyright © 2017 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWFolder: NSObject {
    open var ColumnIndex : Int64 = -1;
    open var Name : String = "";
    open var User : String = "";
    open var ParentFolder : Int64 = -1;
    
    public override init() {
        
    }
    
    public init(index: Int64, name: String, user: String, parentFolder: Int64) {
        super.init();
        self.ColumnIndex = index;
        self.Name = name;
        self.User = user;
        self.ParentFolder = parentFolder;
    }
}
