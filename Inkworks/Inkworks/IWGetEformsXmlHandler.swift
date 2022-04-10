//
//  IWGetEformsXmlHandler.swift
//  Inkworks
//
//  Created by Jamie Duggan on 03/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWGetEformsXmlHandler: NSObject {
    open class func HandleXML(_ XmlString:String) {
        IWInkworksService.getInstance().webserviceError = false;
        Async.main{
            IWInkworksService.getInstance().resetButtons();
        }
        Async.background{
            //var xml = SWXMLHash.parse(XmlString);
            let xml = SWXMLHash.parse(XmlString);
            
            let eforms = xml["eforms"]["eform"].all;
            
            var newList : Array<IWInkworksListItem> = Array<IWInkworksListItem>();
            let df = DateFormatter();
            df.dateFormat = "ddMMyyyy HHmmss";
            for eform in eforms {
                if (eform.element != nil) {
                    var appKey = "-1";
                    let appKeyAtt = eform.element!.attributes["appkey"];
                    if appKeyAtt != nil {
                        appKey = appKeyAtt!;
                    }
                    var name = "";
                    var amended = "";
                    let nameElem = eform["name"];
                    if (nameElem.element?.text != nil) {
                        name = nameElem.element!.text!;
                    }
                    let amendedElem = eform["amended"];
                    if (amendedElem.element?.text != nil) {
                        amended = amendedElem.element!.text!;
                    }
                    
                    
                    
                    let item = IWInkworksListItem(index: -1, name: name, user: IWInkworksService.getInstance().loggedInUser, id: Int(appKey)!, amended:df.date(from: amended)!, parent:-1);
                    newList.append(item);
                }
            }
            
            
            IWInkworksService.getInstance().handleNewEforms(newList);
            
            Async.main{
                if (IWInkworksService.getInstance().homeInstance != nil) {
                    (IWInkworksService.getInstance().homeInstance! as! IWHomeController).refreshIndicators();
                }
                if (IWInkworksService.getInstance().formListInstance != nil) {
                    let flc = (IWInkworksService.getInstance().formListInstance! as! IWFormsListController);
                    flc.refreshItems();
                    
                }
            }
            
            }
        
    }

}
