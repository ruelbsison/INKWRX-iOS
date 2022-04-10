//
//  IWTransaction.swift
//  Inkworks
//
//  Created by Jamie Duggan on 06/04/2017.
//  Copyright © 2017 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWTransaction: NSObject {
    
    open var ColumnIndex : Int64 = -1;
    open var FormId : Int = -1;
    open var Sent: Bool = false;
    open var Username : String = "";
    
    open var SavedDate : Date? = Date();
    open var AddedDate : Date = Date();
    open var SentDate : Date? = nil;
    open var OriginalAddedDate : Date? = nil;
    open var AutoSavedDate : Date? = nil;
    
    open var FormName: String = "";
    open var PenDataXml : String = "";
    open var StrokesXml : String = "";
    open var Status : String = "";
    open var HistoryItemIndex : Int = -1;
    open var HashedPassword : String = "";
    open var PrepopId : Int64 = -1;
    open var ParentTransaction : Int64 = -1;

    public override init() {
        
    }
    
    public init(index: Int64, formId: Int, sent: Bool, username: String, savedDate: Date?, addedDate: Date, sentDate: Date?, originalAddedDate: Date?, autoSavedDate: Date?, formName: String, penData: String, strokes: String, status: String, historyItemIndex: Int, hashedPassword: String, prepopId: Int64, parentTransaction: Int64) {
        self.ColumnIndex = index;
        self.FormId = formId;
        self.Sent = sent;
        self.Username = username;
        self.SavedDate = savedDate;
        self.AddedDate = addedDate;
        self.SentDate = sentDate;
        self.OriginalAddedDate = originalAddedDate;
        self.AutoSavedDate = autoSavedDate;
        self.FormName = formName;
        self.PenDataXml = penData;
        self.StrokesXml = strokes;
        self.Status = status;
        self.HistoryItemIndex = historyItemIndex;
        self.HashedPassword = hashedPassword;
        self.PrepopId = prepopId;
        self.ParentTransaction = parentTransaction;
    }
}
