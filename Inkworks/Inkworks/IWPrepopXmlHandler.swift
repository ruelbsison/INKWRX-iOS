//
//  IWPrepopXmlHandler.swift
//  Inkworks
//
//  Created by Paul Gowing on 21/01/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWPrepopXmlHandler: NSObject {
    open class func HandleXML(_ XmlString:String, newVersion:Int) {
        
        Async.background{
            //var xml = SWXMLHash.parse(XmlString);
            let xml = SWXMLHash.parse(XmlString);
            let additions = xml["prepopdata"]["additions"].all;
            
            
            for elem in additions {
                for prepop in elem["prepop"].all {
                    
                    let prepopId = prepop.element?.attributes["id_key"];
                    let appId = prepop.element?.attributes["app_key"];
                    let prepopIdInt = Int64(prepopId!);
                    let appIdInt = Int(appId!);
                    
                    let helper = IWInkworksService.dbHelper()!;
                    let existingList = helper.getPrepopForms(appIdInt!, user: IWInkworksService.getInstance().loggedInUser);
                    for form in existingList {
                        if (form.PrepopId == prepopIdInt!) {
                            helper.deleteForm(form);
                        }
                    }
                    
                    let newForm = IWPrepopForm();
                    newForm.ColumnIndex = -1;
                    newForm.VersionNumber = newVersion;
                    newForm.PrepopId = prepopIdInt!;
                    newForm.FormId = appIdInt!;
                    newForm.PrepopUser = IWInkworksService.getInstance().loggedInUser;
                    newForm.PrepopStatus = 0;
                    var fields = Array<IWPrepopField>();
                    let ident = prepop["identifier"];
                    let name = ident.element?.text == nil ? "" : ident.element!.text!;
                    newForm.PrepopName = name;
                    
                    let data = prepop["data"];
                    let record = data["record"];
                    let flds = record["field"].all;
                    for field in flds {
                        let fldName = field.element!.attributes["name"]!;
                        let fldValue = field.element!.text;
                        let field1 = IWPrepopField();
                        field1.ColumnIndex = -1;
                        field1.PrepopColumnId = -1;
                        field1.FieldName = fldName;
                        if fldValue == nil {
                            field1.FieldValue = "";
                        } else {
                            field1.FieldValue = fldValue!;
                        }
                        fields.append(field1);
                    }
                    
                    let addedForm = helper.addOrUpdatePrepopForm(newForm);
                    for field2 in fields {
                        field2.PrepopColumnId = addedForm.ColumnIndex;
                        helper.addOrUpdatePrepopField(field2);
                    }
                }
            }
            
            
            let removals = xml["prepopdata"]["removals"].all;
            for elem in removals {
                for prepop in elem["remove"].all {
                    let id = prepop.element?.allAttributes["id_key"];
                    let id_int = Int64(id!.text);
                    let helper = IWInkworksService.dbHelper()!;
                    let form = helper.getPrepopForm(id_int!);
                    if (form == nil) { continue; }
                    helper.deleteForm(form!);
                }
            }
            //IWInkworksService.getInstance().isRefreshing = false;
            Async.main{
                if (IWInkworksService.getInstance().homeInstance != nil) {
                    (IWInkworksService.getInstance().homeInstance! as! IWHomeController).refreshIndicators();
                }
            }
        }
        
        
    }
   
}
