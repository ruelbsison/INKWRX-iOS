//
//  IWISOLabel.swift
//  Inkworks
//
//  Created by Jamie Duggan on 08/07/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWISOLabel: UILabel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    fileprivate var placeHolderLabel: UILabel? = nil;
    
    open func setPlaceholder (_ value: String) {
        placeHolderLabel = UILabel(frame:CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height));
        placeHolderLabel!.text = value;
        if (self.text == nil || self.text! == "") {
            placeHolderLabel!.isHidden = false;
        } else {
            placeHolderLabel!.isHidden = true;
        }
        placeHolderLabel!.isUserInteractionEnabled = false;
        placeHolderLabel!.textAlignment = .center;
        placeHolderLabel!.textColor = UIColor.gray;
        self.addSubview(placeHolderLabel!);
    }
    
    open func setTextValue (_ value : String) {
        self.text = value;
        if self.text == "" {
            self.placeHolderLabel?.isHidden = false;
        } else {
            self.placeHolderLabel?.isHidden = true;
        }
    }
    
}
