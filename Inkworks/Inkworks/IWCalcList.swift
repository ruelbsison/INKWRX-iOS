//
//  IWCalcList.swift
//  Inkworks
//
//  Created by Jamie Duggan on 17/07/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWCalcList: NSObject {
    
    open var fieldName : String = "";
    open var inputs : [String] = [String]();
    open var descriptor : IWIsoFieldDescriptor? = nil;
    open var fieldView : IWIsoFieldView? = nil;
    
    //MARK: [CLASS FUNCTIONS]
    
    //MARK: Field Inputs
    open class func getFieldListFromString(_ string : String) -> [String] {
        var list = [String]();
        
        let regExp = try! NSRegularExpression(pattern: "#(\\w[\\w0-9]*)(?::(\\w+))?#", options: []);
        let nsString = string as NSString;
        let results = regExp.matches(in: string, options: [], range: NSMakeRange(0, nsString.length)) ;
        
        list = results.map {res in
            
            nsString.substring(with: res.rangeAt(1));
        }
        
        return list;
    }
    
    //MARK: List functions
    
    fileprivate class func reorderListWithLastItem(_ original: [IWCalcList], insertedIndex: Int) -> (list:[IWCalcList], change: Int) {
        
        if (original.count < 2) {return (original, 0);}
        var newList = original;
        let listItem = original[insertedIndex];
        var change = 0;
        for i in stride(from: (insertedIndex - 1), through: 0, by: -1) {
            if (i+change < 0) {break;}
            let thisItem = newList[i + change];
            if thisItem.inputs.filter({t in
                t == listItem.fieldName}).count > 0 {
                    //item exists...
                    newList.remove(at: i + change);
                    newList.insert(thisItem, at: insertedIndex + change);
                    let result = reorderListWithLastItem(newList, insertedIndex: insertedIndex + change);
                    change += result.change - 1; //-1 for the original removal...
            }
        }
        
        return (newList, change);
    }
    
    open class func getOrderedCalcList(_ original: [IWCalcList]) -> [IWCalcList] {
        var newList = [IWCalcList]();
        for calc in original {
            if (newList.count == 0) {
                newList.append(calc);
                continue;
            }
            let existing = newList.map {c in
                c.fieldName;
            }
            if (calc.inputs.filter({f in
            existing.filter({e in
                e == f
                }).count > 0
            }).count > 0) {
                //exists - one of the inputs exists in the list already, insert this record AFTER the last one in the list...
                var insert = newList.count;
                for i in stride(from: (newList.count-1), through: 0, by: -1) {
                    let thisItem = newList[i];
                    if calc.inputs.filter({input in
                        input == thisItem.fieldName
                    }).count > 0 {
                        insert = i + 1;
                        break;
                    }
                }
                newList.insert(calc, at: insert);
                let res = reorderListWithLastItem(newList, insertedIndex: insert);
                newList = res.list;
            } else {
                //doesn't exist
                newList.insert(calc, at: 0);
            }
        }
        return newList;
    }
}
