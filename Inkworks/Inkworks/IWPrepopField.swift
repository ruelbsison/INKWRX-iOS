//
//  IWPrepopField.swift
//  Inkworks
//
//  Created by Paul Gowing on 15/01/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWPrepopField: NSObject {

    open var ColumnIndex: Int64 = -1;
    open var PrepopColumnId: Int64 = -1;
    open var FieldName: String = "";
    open var FieldValue: String = "";
    
    public override init() {
        
    }
    
    public init(index: Int64, prepopColumnId: Int64, fieldName: String, fieldValue: String) {
        super.init();
        ColumnIndex = index;
        PrepopColumnId = prepopColumnId;
        FieldName = fieldName;
        FieldValue = fieldValue;
    }
    
    
    
    
   
}
