//
//  IWDynamicField.swift
//  Inkworks
//
//  Created by Jamie Duggan on 06/04/2017.
//  Copyright © 2017 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWDynamicField: NSObject {
    
    open var ColumnIndex : Int64 = -1;
    open var TransactionId : Int64 = -1;
    open var FieldId : String = "";
    open var ShownValue : String = "";
    open var NotShownValue : String = "";
    open var Tickable : Bool = false;
    open var Ticked : Bool = false;
    
    public override init() {
        
    }
    
    public init(index: Int64, transactionId: Int64, fieldId: String, shownValue: String, notShownValue: String, tickable: Bool, ticked: Bool) {
        super.init();
        self.ColumnIndex = index;
        self.TransactionId = transactionId;
        self.FieldId = fieldId;
        self.ShownValue = shownValue;
        self.NotShownValue = notShownValue;
        self.Tickable = tickable;
        self.Ticked = ticked;
    }
}
