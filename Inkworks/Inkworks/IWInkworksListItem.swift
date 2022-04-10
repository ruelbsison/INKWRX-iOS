//
//  IWInkworksListItem.swift
//  Inkworks
//
//  Created by Jamie Duggan on 05/04/2017.
//  Copyright © 2017 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWInkworksListItem: NSObject {
    /*
     long long columnIndex;
     NSString *formName;
     NSString *formUser;
     long formId;
     NSDate *amended;
     long long parentFolder;
    */
    open var ColumnIndex : Int64 = -1;
    open var FormName : String = "";
    open var FormUser : String = "";
    open var FormId : Int = -1;
    open var Amended : Date = Date();
    open var ParentFolder : Int64 = -1;
    
    public override init() {
        
    }
    
    public init (index: Int64, name: String, user: String, id: Int, amended: Date, parent: Int64) {
        super.init();
        self.ColumnIndex = index;
        self.FormName = name;
        self.FormUser = user;
        self.FormId = id;
        self.Amended = amended;
        self.ParentFolder = parent;
    }
}
