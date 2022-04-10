//
//  IWCircleView.swift
//  Inkworks
//
//  Created by Jamie Duggan on 15/04/2016.
//  Copyright © 2016 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWCircleView: UIView {

    open var r: Float = 0.0;
    open var fill : UIColor = UIColor.white;
    open var stroke: UIColor = UIColor.black;
    open var strokeWidth: Float = 1.0;
    
    public convenience init(frame: CGRect, r: Float, fill: UIColor, stroke: UIColor, strokeWidth:Float) {
        self.init(frame:frame);
        self.r = r;
        self.fill = fill;
        self.stroke = stroke;
        self.strokeWidth = strokeWidth;
        self.layer.borderWidth = CGFloat(strokeWidth);
        self.layer.borderColor = self.stroke.cgColor;
        self.backgroundColor = self.fill;
        self.layer.cornerRadius = CGFloat(self.r);
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
