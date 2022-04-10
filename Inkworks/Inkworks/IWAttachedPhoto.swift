//
//  IWAttachedPhoto.swift
//  Inkworks
//
//  Created by Jamie Duggan on 05/04/2017.
//  Copyright © 2017 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWAttachedPhoto: NSObject {
    /*
     long long columnIndex;
     NSString *imageType;
     long long photoTransactionId;
     long long photoImageId;
     NSString *imagePath;
     NSString *imageUUID;
     NSString *imageStatus;
     */
    open var ColumnIndex : Int64 = -1;
    open var ImageType : String = "Gallery";
    open var TransactionId : Int64 = -1;
    open var ImageId : Int64 = -1;
    open var ImagePath : String = "";
    open var ImageUUID : String = "";
    open var ImageStatus : String = "";
    
    public override init() {
        
    }
    
    public init(index: Int64, type: String, transactionId: Int64, imageId: Int64, imagePath: String, imageUUID: String, imageStatus: String) {
        super.init();
        self.ColumnIndex = index;
        self.TransactionId = transactionId;
        self.ImageId = imageId;
        self.ImagePath = imagePath;
        self.ImageUUID = imageUUID;
        self.ImageStatus = imageStatus;
    }
}
