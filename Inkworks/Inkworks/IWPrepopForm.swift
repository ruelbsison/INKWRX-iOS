//
//  IWPrepopForm.swift
//  Inkworks
//
//  Created by Paul Gowing on 14/01/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWPrepopForm: NSObject {
    open var ColumnIndex: Int64 = -1;
    open var PrepopId: Int64 = -1;
    open var PrepopName: String = "";
    open var FormId: Int = -1;
    open var VersionNumber: Int = -1;
    open var PrepopUser : String = "";
    open var PrepopStatus : Int = 0;
    
    public override init() {
        
    }
    
    public init(index: Int64, prepopId: Int64, prepopName: String, formID: Int, versionNumber: Int, user: String, prepopStatus: Int) {
        super.init();
        ColumnIndex = index;
        PrepopId = prepopId;
        PrepopName = prepopName;
        FormId = formID;
        VersionNumber = versionNumber;
        PrepopUser = user;
        PrepopStatus = prepopStatus;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
}
