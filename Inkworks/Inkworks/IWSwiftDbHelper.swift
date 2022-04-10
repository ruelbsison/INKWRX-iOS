//
//  IWSwiftDbHelper.swift
//  Inkworks
//
//  Created by Paul Gowing on 25/01/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit
import SQLite

@objc
open class IWSwiftDbHelper: NSObject {
    
    // PrepopStatus
    open let Available : Int = 0;
    open let Parked : Int = 1;
    open let Sending : Int = 2;
    open let Sent : Int = 3;
    
    enum FormStatus : String {
        case Sending = "Sending"
        case Sent = "Sent"
        case Parked = "Parked"
        case Autosaved = "Autosaved"
        case Awaiting = "Awaiting"
    }
    
    
    //MARK: Tables
    
    let PrepopForm = Table("PrepopForm");
    let PrepopField = Table("PrepopField");
    let Folder = Table("Folder");
    let SavedSettings = Table("SavedSettings");
    let FormList = Table("EFormList");
    let Transaction = Table("Transaction");
    let AttachedPhoto = Table("AttachedPhoto");
    let DynamicField = Table("DynamicField");
    
    //MARK: Columns
    
    let ColumnIndex = Expression<Int64>("_id");
    
    //MARK: --Prepop Form
    
    let PrepopId = Expression<Int64>("PrepopId");
    let PrepopName = Expression<String>("PrepopName");
    let FormId = Expression<Int>("FormId");
    let VersionNumber = Expression<Int>("VersionNumber");
    let PrepopUser = Expression<String>("PrepopUser");
    let PrepopStatus = Expression<Int>("PrepopStatus");
    
    //MARK: --Prepop Field
    
    let PrepopColumnId = Expression<Int64>("PrepopColumnId");
    let FieldName = Expression<String>("FieldName");
    let FieldValue = Expression<String>("FieldValue");
    
    //MARK: --Folder
    
    let Name = Expression<String>("Name");
    let User = Expression<String>("User");
    let ParentFolder = Expression<Int64>("ParentFolder");
    
    //MARK: --SavedSettings
    
    let SettingName = Expression<String>("SettingName");
    let SettingValue = Expression<String>("SettingsValue");
    
    //MARK: --Form List
    
    let EFormUser = Expression<String>("EFormUser");
    let EFormName = Expression<String>("EFormName");
    let EFormId = Expression<Int>("EFormId");
    let EFormAmended = Expression<String>("EFormAmended")
    //"ParentFolder"
    
    //MARK: --Transaction
    
    //let FormId = Expression<Int>("FormId");
    let SentBool = Expression<Int>("Sent");
    let Username = Expression<String>("UserName");
    let SavedDate = Expression<String>("SavedDateTime");
    let FormName = Expression<String>("FormName");
    let PenData = Expression<String>("PenDataXml");
    let StrokeData = Expression<String>("StrokesXml");
    let SentDate = Expression<String>("SentDate");
    let AddedDate = Expression<String>("AddedDate");
    let Status = Expression<String>("Status");
    let HistoryItemIndex = Expression<Int>("HistoryItemIndex");
    let PasswordHash = Expression<String>("PasswordHash");
    let TransPrepopId = Expression<Int64?>("PrepopId");
    let OriginalAddedDate = Expression<String>("OriginalAddedDate");
    let ParentTransaction = Expression<Int64>("ParentTransaction");
    let AutoSavedDate = Expression<String>("AutoSavedDate");
    
    //MARK: Attached Photo
    
    let ImageType = Expression<String>("ImageType");
    let TransId = Expression<Int64>("TransactionId");
    let ImageId = Expression<Int64>("ImageId");
    let ImagePath = Expression<String>("ImagePath");
    let ImageUUID = Expression<String>("ImageUUID");
    // "Status"
    
    //MARK: Dynamic Field
    
    //#define DYNAMIC_TRANS_ID @"TransactionId"
    let FieldId = Expression<String>("FieldId");
    let ShownValue = Expression<String>("ShownValue");
    let NotShownValue = Expression<String>("NotShownValue");
    let Tickable = Expression<Int>("Tickable");
    let Ticked = Expression<Int>("Ticked");
    
    //MARK: Helper Set-up
    
    fileprivate var dbPath : String = NSSearchPathForDirectoriesInDomains(
        .libraryDirectory, .userDomainMask, true
        ).first as String! + "/Inkworks/inkworks.db";
    
    open var db : Connection? = nil;
    
    public override init() {
        super.init();
        do {
            db = try Connection(dbPath);
            db!.busyTimeout = 10000;
            #if DEBUG
                db!.trace(print);
            #endif
            doMigrations();
            self.fixAwaitingStatus();
        } catch {

        }
    }
    
    private func doMigrations() {
        if (db!.userVersion == 0) {
            do {
                try db!.run(SavedSettings.create(temporary: false, ifNotExists: true) {t in
                    t.column(self.ColumnIndex, primaryKey: .autoincrement);
                    t.column(self.SettingName);
                    t.column(self.SettingValue);
                });
                try db!.run(FormList.create(temporary:false, ifNotExists: true) { t in
                    t.column(self.ColumnIndex, primaryKey: .autoincrement);
                    t.column(self.EFormUser);
                    t.column(self.EFormName);
                    t.column(self.EFormId);
                    t.column(self.EFormAmended);
                    t.column(self.ParentFolder);
                });
                
                if (!columnExists("EFormList", column: "ParentFolder")) {
                    try db!.run(FormList.addColumn(self.ParentFolder, defaultValue: -1));
                }
                
                try db!.run(Transaction.create(temporary: false, ifNotExists: true) {t in
                    t.column(self.ColumnIndex, primaryKey: .autoincrement);
                    t.column(self.FormId);
                    t.column(self.SentBool);
                    t.column(self.Username);
                    t.column(self.SavedDate);
                    t.column(self.FormName);
                    t.column(self.PenData);
                    t.column(self.StrokeData);
                    t.column(self.SentDate);
                    t.column(self.AddedDate);
                    t.column(self.Status);
                    t.column(self.HistoryItemIndex);
                    t.column(self.PasswordHash);
                    t.column(self.TransPrepopId);
                    t.column(self.OriginalAddedDate);
                    t.column(self.ParentTransaction);
                    t.column(self.AutoSavedDate);
                });
                try db!.run(AttachedPhoto.create(temporary:false, ifNotExists:true) {t in
                    t.column(self.ColumnIndex, primaryKey:.autoincrement);
                    t.column(self.ImageType);
                    t.column(self.TransId);
                    t.column(self.ImageId);
                    t.column(self.ImagePath);
                    t.column(self.ImageUUID);
                    t.column(self.Status);
                });
                try db!.run(DynamicField.create(temporary:false, ifNotExists:true) {t in
                    t.column(self.ColumnIndex, primaryKey:.autoincrement);
                    t.column(self.TransId);
                    t.column(self.FieldId);
                    t.column(self.ShownValue);
                    t.column(self.NotShownValue);
                    t.column(self.Tickable);
                    t.column(self.Ticked);
                });
                try db!.run(PrepopForm.create(temporary:false, ifNotExists: true) { t in
                    t.column(self.ColumnIndex, primaryKey:.autoincrement);
                    t.column(self.PrepopId);
                    t.column(self.PrepopName);
                    t.column(self.FormId);
                    t.column(self.VersionNumber);
                    t.column(self.PrepopUser);
                    t.column(self.PrepopStatus)
                });
                try db!.run(PrepopField.create(temporary: false, ifNotExists: true) { t in
                    t.column(self.ColumnIndex, primaryKey:.autoincrement);
                    t.column(self.PrepopColumnId);
                    t.column(self.FieldName);
                    t.column(self.FieldValue);
                });
                try db!.run(Folder.create(temporary: false, ifNotExists: true) { t in
                    t.column(self.ColumnIndex, primaryKey:.autoincrement);
                    t.column(self.Name);
                    t.column(self.User);
                    t.column(self.ParentFolder);
                });
                
                //do this here because it only needs to be done once...
                self.fixCasedUsers();
                
                
                db!.userVersion = 1;
            } catch {
                
            }
        }
    }
    
    fileprivate func fixCasedUsers() -> Bool {
        do {
            //forms
            let forms = try db!.prepare(FormList.filter(self.EFormUser != self.EFormUser.lowercaseString));
            for form in forms {
                let userName = form[self.EFormUser];
                
                // just in case the sql doesn't work...
                if userName == userName.lowercased() {
                    continue;
                }
                let settings = try db!.prepare(SavedSettings.filter(self.SettingName.like("%\(userName)%")));
                for setting in settings {
                    let name : String = setting[self.SettingName];
                    self.saveSetting(name.replacingOccurrences(of: userName, with: userName.lowercased()), value: setting[self.SettingValue]);
                }
            }
            
            //transactions
            try db!.run(Transaction.filter(self.Username != self.Username.lowercaseString).update(self.Username <- self.Username.lowercaseString));
            
            //prepop forms
            try db!.run(PrepopForm.filter(self.PrepopUser != self.PrepopUser.lowercaseString).update(self.PrepopUser <- self.PrepopUser.lowercaseString));
            
            //folders
            try db!.run(Folder.filter(self.User != self.User.lowercaseString).update(self.User <- self.User.lowercaseString))
            
            return true;
        } catch {
            return false;
        }
    }
    
    fileprivate func columnExists(_ table : String, column : String) -> Bool {
        do {
            let stmt = try db!.prepare("pragma table_info(\(table))");
            for row in stmt {
                for (index, name) in stmt.columnNames.enumerated() {
                    if (name != "name") {
                        continue;
                    }
                    if (row[index]! as! String == column) {
                        return true;
                    }
                }
            }
            return false;
        } catch {
            return columnExists(table, column: column);
        }
    }
    
    fileprivate func decryptedString(_ original:String) -> String {
        if original.range(of: "{ENC}", options: NSString.CompareOptions.caseInsensitive) == nil {
            return original;
        }
        
        var dec : String = original.replacingOccurrences(of: "{ENC}", with: "", options: NSString.CompareOptions.caseInsensitive);
        dec = IWInkworksService.decrypt(dec, withKey: IWInkworksService.getCryptoKey(nil));
        return dec;
    }
    
    fileprivate func encryptedString(_ original:String) -> String {
        let enc : String = IWInkworksService.encrypt(original, withKey: IWInkworksService.getCryptoKey(nil));
        return String(format: "{ENC}%@", enc);
    }
    
    //MARK: Table Methods
    
    //MARK: --Prepop Forms
    
    open func addOrUpdatePrepopForm (_ form : IWPrepopForm) -> IWPrepopForm {
        if (form.ColumnIndex == -1) {
            //add
            do {
                let ind = try db!.run(PrepopForm.insert(PrepopId <- form.PrepopId, PrepopName <- encryptedString(form.PrepopName), FormId <- form.FormId, VersionNumber <- form.VersionNumber, PrepopUser <- form.PrepopUser, PrepopStatus <- form.PrepopStatus));
                
                form.ColumnIndex = ind;
                return form;
                
            } catch {
                
            }
            return addOrUpdatePrepopForm(form);
        } else {
            //update
            do {
                let record = PrepopForm.filter(ColumnIndex == form.ColumnIndex);
                
                try db!.run(record.update(PrepopId <- form.PrepopId, PrepopName <- encryptedString(form.PrepopName), FormId <- form.FormId, VersionNumber <- form.VersionNumber, PrepopUser <- form.PrepopUser, PrepopStatus <- form.PrepopStatus));
                
                return form;
                
            } catch {
                return addOrUpdatePrepopForm(form);
            }
            
        }
        
    }
    
    open func deleteForm(_ form: IWPrepopForm) {
        self.deleteFields(form.ColumnIndex);
        let delForm = PrepopForm.filter(ColumnIndex == form.ColumnIndex);
        do {
            try db!.run(delForm.delete());
        } catch {
            self.deleteForm(form);
        }
    }
    
    open func getPrepopForm(_ prepopId: Int64) -> IWPrepopForm? {
        do {
            let row = try db!.pluck(PrepopForm.filter(PrepopId == prepopId));
            if (row == nil) { return nil; }
            let row1 = row!;
            let form = IWPrepopForm(index: row1[ColumnIndex], prepopId: row1[PrepopId], prepopName: decryptedString(row1[PrepopName]), formID: row1[FormId], versionNumber: row1[VersionNumber], user: row1[PrepopUser], prepopStatus: row1[PrepopStatus]);
            
            return form;
        } catch {
            return nil;
        }
    }
    
    open func getAllPrepopForms(_ formId: Int, user: String, search: String) -> Array<IWPrepopForm> {
        let list = PrepopForm
            .filter(FormId == formId)
            .filter(PrepopUser == user)
        var ret : Array<IWPrepopForm> = Array();
        do {
            for form in try db!.prepare(list) {
                let frm = IWPrepopForm(index: form[ColumnIndex], prepopId: form[PrepopId], prepopName: decryptedString(form[PrepopName]), formID: form[FormId], versionNumber: form[VersionNumber], user: form[PrepopUser], prepopStatus: form[PrepopStatus]);
                if frm.PrepopName.lowercased().contains(search.lowercased()) {
                    ret.append(frm);
                }
            }
        } catch {
            
        }
        return ret;
    }
    
    open func getPrepopForms(_ formId: Int, user: String, search: String) -> Array<IWPrepopForm> {
        let list = PrepopForm
            .filter(FormId == formId)
            .filter(PrepopUser == user)
            .filter(PrepopStatus == Available)
        var ret : Array<IWPrepopForm> = Array();
        do {
            for form in try db!.prepare(list) {
                let frm = IWPrepopForm(index: form[ColumnIndex], prepopId: form[PrepopId], prepopName: decryptedString(form[PrepopName]), formID: form[FormId], versionNumber: form[VersionNumber], user: form[PrepopUser], prepopStatus: form[PrepopStatus]);
                if frm.PrepopName.lowercased().contains(search.lowercased()) {
                    ret.append(frm);
                }
            }
        } catch {
            
        }
        return ret;
    }
    
    open func getPrepopForms(_ formId: Int, user: String) -> Array<IWPrepopForm> {
        let list = PrepopForm
            .filter(FormId == formId)
            .filter(PrepopUser == user)
            .filter(PrepopStatus == Available);
        var ret : Array<IWPrepopForm> = Array();
        
        do {
            for form in try db!.prepare(list) {
                let frm = IWPrepopForm(index: form[ColumnIndex], prepopId: form[PrepopId], prepopName: decryptedString(form[PrepopName]), formID: form[FormId], versionNumber: form[VersionNumber], user: form[PrepopUser], prepopStatus: form[PrepopStatus]);
                ret.append(frm);
            }
        } catch {
            
        }
        return ret;
    }
    
    open func getPrepopForms(_ user: String) -> Array<IWPrepopForm> {
        let list = PrepopForm
            .filter(PrepopUser == user)
            .filter(PrepopStatus == Available);
        var ret : Array<IWPrepopForm> = Array();
        do {
            for form in try db!.prepare(list) {
                let frm = IWPrepopForm(index: form[ColumnIndex], prepopId: form[PrepopId], prepopName: decryptedString(form[PrepopName]), formID: form[FormId], versionNumber: form[VersionNumber], user: form[PrepopUser], prepopStatus: form[PrepopStatus]);
                ret.append(frm);
            }
        } catch {
            
        }
        return ret;
    }
    
    open func getPrepopForms(_ user: String, search: String) -> Array<IWPrepopForm> {
        let list = PrepopForm
            .filter(PrepopUser == user)
            .filter(PrepopStatus == Available);
        var ret : Array<IWPrepopForm> = Array();
        do {
            for form in try db!.prepare(list) {
                let frm = IWPrepopForm(index: form[ColumnIndex], prepopId: form[PrepopId], prepopName: decryptedString(form[PrepopName]), formID: form[FormId], versionNumber: form[VersionNumber], user: form[PrepopUser], prepopStatus: form[PrepopStatus]);
                if (frm.PrepopName.lowercased().contains(search.lowercased())) {
                    ret.append(frm);
                }
            }
        } catch {
            
        }
        return ret;
    }

    //MARK: --Prepop Fields
    
    open func addOrUpdatePrepopField(_ field : IWPrepopField) -> IWPrepopField {
        
        if (field.ColumnIndex == -1) {
            //add
            do {
                let ind = try db!.run(PrepopField.insert(PrepopColumnId <- field.PrepopColumnId, FieldName <- encryptedString(field.FieldName), FieldValue <- encryptedString(field.FieldValue)));
                field.ColumnIndex = ind;
                return field;
                
            } catch {
                return addOrUpdatePrepopField(field);
            }
        } else {
            //update
            do {
                let record = PrepopField.filter(ColumnIndex == field.ColumnIndex);
                
                try db!.run(record.update(PrepopColumnId <- field.PrepopColumnId, FieldName <- encryptedString(field.FieldName), FieldValue <- encryptedString(field.FieldValue)));
                return field;
                
            } catch {
                return addOrUpdatePrepopField(field);
            }
        }
    }
    
    open func deleteFields(_ columnIndex: Int64) {
        let fields = PrepopField.filter(PrepopColumnId == columnIndex);
        do {
            try db!.run(fields.delete());
        } catch {
            deleteFields(columnIndex);
        }
        
    }
    
    open func getPrepopFields(_ prepopId: Int64) -> Array<IWPrepopField> {
        let list = PrepopField.filter(PrepopColumnId == prepopId);
        var ret : Array<IWPrepopField> = Array();
        do {
            for field in try db!.prepare(list) {
                let fld = IWPrepopField(index: field[ColumnIndex], prepopColumnId: field[PrepopColumnId], fieldName: decryptedString(field[FieldName]), fieldValue: decryptedString(field[FieldValue]));
                ret.append(fld);
            }
        } catch {
            
        }
        return ret;
    }

    //MARK: --Folders
    
    open func addOrUpdateFolder (_ folder: IWFolder) -> IWFolder {
        if (folder.ColumnIndex == -1) {
            //add
            do {
                let ind = try db!.run(Folder.insert(Name <- folder.Name, User <- folder.User, ParentFolder <- folder.ParentFolder));
                folder.ColumnIndex = ind;
                return folder;
            } catch {
                
            }
            return addOrUpdateFolder(folder);
        } else {
            //update
            do {
                let record = Folder.filter(ColumnIndex == folder.ColumnIndex);
                try db!.run(record.update(Name <- folder.Name, User <- folder.User, ParentFolder <- folder.ParentFolder));
                return folder;
            } catch {
                return addOrUpdateFolder(folder);
            }
        }
    }
    
    open func getFoldersForUser (_ user: String, parentFolder: Int64 = -1) -> [IWFolder] {
        var ret = [IWFolder]();
        let list = Folder.filter(User == user && ParentFolder == parentFolder)
        do {
            for folder in try db!.prepare(list) {
                ret.append(IWFolder(index: folder[ColumnIndex], name: folder[Name], user: folder[User], parentFolder: folder[ParentFolder]));
            }
        } catch {
            
        }
        return ret;
    }
    
    open func getFolderById (_ id: Int64) -> IWFolder {
        let record = Folder.filter(ColumnIndex == id);
        do {
            let folder = try db!.pluck(record);
            let ret = IWFolder(index: folder![ColumnIndex], name: folder![Name], user: folder![User], parentFolder: folder![ParentFolder]);
            return ret;
        } catch {
            return getFolderById(id);
        }
    }
    
    open func deleteFolder(_ folder: IWFolder) {
        for subfolder in getFoldersForUser(folder.User, parentFolder: folder.ColumnIndex) {
            deleteFolder(subfolder);
        }
        
        let helper = IWInkworksService.dbHelper()!;
        let forms = helper.getForms(folder.User, inFolder: folder.ColumnIndex);
        for form in forms {
            form.ParentFolder = folder.ParentFolder;
            helper.addOrUpdateForm(form);
        }
        let delFolder = Folder.filter(ColumnIndex == folder.ColumnIndex);
        do {
            try db!.run(delFolder.delete());
        } catch {
            deleteFolder(folder);
        }
    }

    //MARK: --Settings
    
    open func getSetting(_ name : String) -> IWSavedSettings? {
        do {
            let record = try db!.pluck(SavedSettings.filter(SettingName == name));
            if record != nil {
                return IWSavedSettings(index: record![ColumnIndex], name: record![SettingName], value: self.decryptedString(record![SettingValue]));
            }
            return nil;
        } catch {
            return getSetting(name);
        }
        
    }
    
    open func saveSetting(_ name: String, value: String) -> IWSavedSettings {
        let original = getSetting(name);
        if original != nil {
            //update
            do {
                let origdb = SavedSettings.filter(ColumnIndex == original!.ColumnIndex);
                try db!.run(origdb.update(SettingValue <- self.encryptedString(value)));
                original?.SettingValue = value;
                return original!;
            } catch {
                return saveSetting(name, value: value);
            }
        } else {
            //insert
            do {
                let ind = try db!.run(SavedSettings.insert(SettingName <- name, SettingValue <- self.encryptedString(value)));
                return IWSavedSettings(index: ind, name: name, value: value);
            } catch {
                return saveSetting(name, value: value);
            }
        }
    }
    
    //MARK: Forms
    
    fileprivate func formFromRow(_ row: Row) -> IWInkworksListItem {
        let df = DateFormatter();
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS";
        return IWInkworksListItem(index: row[ColumnIndex], name: self.decryptedString(row[EFormName]), user: self.decryptedString(row[EFormUser]), id: row[EFormId], amended: df.date(from: self.decryptedString(row[EFormAmended]))!, parent: row[ParentFolder])
    }
    
    open func getFormsList(_ user: String) -> [IWInkworksListItem] {
        let records = FormList.filter(self.EFormUser == user);
        
        var ret = [IWInkworksListItem]();
        do {
            for form in try db!.prepare(records) {
                ret.append(formFromRow(form));
            }
            return ret;
        } catch {
            return getFormsList(user);
        }
    }
    
    open func getForms(_ user: String, inFolder folder:Int64 = -1) -> [IWInkworksListItem] {
        let records = FormList.filter(self.EFormUser == user && self.ParentFolder == folder);
        var ret = [IWInkworksListItem]();
        do {
            for form in try db!.prepare(records) {
                ret.append(formFromRow(form));
            }
            return ret;
        } catch {
            return getForms(user, inFolder: folder);
        }
    }
    
    open func getForm(_ formId: Int, user: String) -> IWInkworksListItem? {
        do {
            let record = try db!.pluck(self.FormList.filter(self.EFormId == formId && self.EFormUser == user));
            if record != nil {
                return formFromRow(record!);
            }
            return nil;
        } catch {
            return getForm(formId, user: user);
        }
    }
    
    open func removeForm(withId formId:Int, user: String) -> Bool {
        let record = self.FormList.filter(self.EFormId == formId && self.EFormUser == user);
        do {
            try db!.run(record.delete());
            return true;
        } catch {
            return false;
        }
    }
    
    open func addOrUpdateForm (_ form : IWInkworksListItem) -> IWInkworksListItem {
        let df = DateFormatter();
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS";
        if form.ColumnIndex == -1 {
            //add
            do {
                let ind = try db!.run(FormList.insert(self.EFormName <- form.FormName, self.EFormUser <- form.FormUser, self.EFormId <- form.FormId, self.EFormAmended <- df.string(from: form.Amended), self.ParentFolder <- form.ParentFolder));
                form.ColumnIndex = ind;
                return form;
            } catch {
                return addOrUpdateForm(form);
            }
        } else {
            //update
            do {
                let record = FormList.filter(self.ColumnIndex == form.ColumnIndex);
                try db!.run(record.update(self.EFormName <- form.FormName, self.EFormUser <- form.FormUser, self.EFormId <- form.FormId, self.EFormAmended <- df.string(from: form.Amended), self.ParentFolder <- form.ParentFolder));
                return form;
            } catch {
                return addOrUpdateForm(form);
            }
        }
    }
    
    //MARK: --Attached Photos

    open func getPhotos(_ transactionId : Int64) -> [IWAttachedPhoto] {
        let records = AttachedPhoto.filter(TransId == transactionId);
        var ret = [IWAttachedPhoto]();
        do {
            for form in try db!.prepare(records) {
                ret.append(IWAttachedPhoto(index: form[ColumnIndex], type: self.decryptedString(form[ImageType]), transactionId: form[TransId], imageId: form[ImageId], imagePath: self.decryptedString(form[ImagePath]), imageUUID: self.decryptedString(form[ImageUUID]), imageStatus: self.decryptedString(form[Status])));
            }
            return ret;
        } catch {
            return getPhotos(transactionId);
        }
    }
    
    open func resetAttachedPhotos(_ transactionId : Int64) -> Bool {
        let list = self.getPhotos(transactionId);
        var allDone = true;
        for photo in list {
            allDone = allDone && removePhoto(photo);
        }
        return allDone;
    }
    
    open func addOrUpdatePhoto(_ photo: IWAttachedPhoto)-> IWAttachedPhoto {
        if photo.ColumnIndex == -1 {
            //add
            do {
                let ind = try db!.run(AttachedPhoto.insert(ImageType <- self.encryptedString(photo.ImageType), TransId <- photo.TransactionId, ImageId <- photo.ImageId, ImagePath <- self.encryptedString(photo.ImagePath), ImageUUID <- self.encryptedString(photo.ImageUUID), Status <- self.encryptedString(photo.ImageStatus)));
                photo.ColumnIndex = ind;
                return photo;
            } catch {
                return addOrUpdatePhoto(photo);
            }
        } else {
            //update
            do {
                let record = AttachedPhoto.filter(ColumnIndex == photo.ColumnIndex);
                try db!.run(record.update(ImageType <- self.encryptedString(photo.ImageType), TransId <- photo.TransactionId, ImageId <- photo.ImageId, ImagePath <- self.encryptedString(photo.ImagePath), ImageUUID <- self.encryptedString(photo.ImageUUID), Status <- self.encryptedString(photo.ImageStatus)));
                return photo;
            } catch {
                return addOrUpdatePhoto(photo);
            }
        }
    }
    
    open func removePhoto (_ photo: IWAttachedPhoto) -> Bool {
        let record = AttachedPhoto.filter(ColumnIndex == photo.ColumnIndex);
        do {
            try db!.run(record.delete());
            return true;
        } catch {
            return false;
        }
    }
    
    //MARK: --Dynamic Fields
    
    open func getDynamicFields(_ transactionId: Int64) -> [IWDynamicField]{
        var ret = [IWDynamicField]();
        let records = DynamicField.filter(self.TransId == transactionId);
        do {
            for field in try db!.prepare(records) {
                ret.append(IWDynamicField(index: field[self.ColumnIndex], transactionId: field[self.TransId], fieldId: self.decryptedString(field[self.FieldId]), shownValue: self.decryptedString(field[self.ShownValue]), notShownValue: self.decryptedString(field[self.NotShownValue]), tickable: field[self.Tickable] == 1, ticked: field[self.Ticked] == 1));
            }
            return ret;
        } catch {
            return getDynamicFields(transactionId);
        }
    }
    
    open func removeDynamicFields(_ transactionId: Int64) -> Bool {
        let records = DynamicField.filter(self.TransId == transactionId);
        do {
            try db!.transaction {
                try self.db!.run(records.delete());
            }
            return true;
        } catch {
            return false;
        }
    }
    
    open func addOrUpdateDynamicField(_ field : IWDynamicField) -> IWDynamicField{
        if field.ColumnIndex == -1 {
            //add
            do {
                let ind = try self.db!.run(DynamicField.insert(self.TransId <- field.TransactionId, self.FieldId <- self.encryptedString(field.FieldId), self.ShownValue <- self.encryptedString(field.ShownValue), self.NotShownValue <- self.encryptedString(field.NotShownValue), self.Tickable <- field.Tickable ? 1 : 0, self.Ticked <- field.Ticked ? 1 : 0));
                field.ColumnIndex = ind;
                return field;
            } catch {
                return addOrUpdateDynamicField(field);
            }
        } else {
            //update
            do {
                let record = DynamicField.filter(self.ColumnIndex == field.ColumnIndex);
                try db!.run(record.update(self.TransId <- field.TransactionId, self.FieldId <- self.encryptedString(field.FieldId), self.ShownValue <- self.encryptedString(field.ShownValue), self.NotShownValue <- self.encryptedString(field.NotShownValue), self.Tickable <- field.Tickable ? 1 : 0, self.Ticked <- field.Ticked ? 1 : 0));
            } catch {
                return addOrUpdateDynamicField(field);
            }
        }
        return field;
    }
    
    open func removeDynamicField(_ field : IWDynamicField) -> Bool {
        
        return false;
    }
    
    
    //MARK: --Transactions
    
    open func getNextSendingItem() -> IWTransaction? {
        let records = Transaction.filter(self.Status == "Sending");
        do {
            let next = try db!.pluck(records);
            if next == nil {
                return nil;
            }
            let tran = self.transactionWithRow(next!);
            if tran.PenDataXml == "(null)" {
                self.removeTransaction(tran);
                return self.getNextSendingItem();
            }
            
            return tran;
        } catch {
            return getNextSendingItem();
        }
    }
    
    fileprivate func transactionWithRow(_ row: Row) -> IWTransaction {
        let df = DateFormatter();
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS";
        return IWTransaction(index: row[self.ColumnIndex], formId: row[self.FormId], sent: row[self.SentBool] == 1, username: row[self.Username], savedDate: self.decryptedString(row[self.SavedDate]) == "" ? nil : df.date(from: self.decryptedString(row[self.SavedDate]))!, addedDate: df.date(from: row[self.AddedDate])!, sentDate: self.decryptedString(row[self.SentDate]) == "" ? nil : df.date(from: self.decryptedString(row[self.SentDate]))!, originalAddedDate: self.decryptedString(row[self.OriginalAddedDate]) == "" ? nil : df.date(from: self.decryptedString(row[self.OriginalAddedDate]))!, autoSavedDate: self.decryptedString(row[self.AutoSavedDate]) == "" ? nil : df.date(from: self.decryptedString(row[self.AutoSavedDate]))!, formName: self.decryptedString(row[self.FormName]), penData: self.decryptedString(row[self.PenData]), strokes: self.decryptedString(row[self.StrokeData]), status: row[self.Status], historyItemIndex: row[self.HistoryItemIndex], hashedPassword: self.decryptedString(row[self.PasswordHash]), prepopId: row[self.TransPrepopId] == nil ? -1 : row[self.TransPrepopId]!, parentTransaction: row[self.ParentTransaction]);
    }
    
    fileprivate func getHistory(_ user : String, search: String? = nil, status: FormStatus? = nil) -> [IWTransaction] {
        var records = Transaction.order(self.AddedDate.desc).filter(self.Username == user);
        if status != nil {
            records = records.filter(self.Status == status!.rawValue);
        }
        var ret = [IWTransaction]();
        do {
            for tran in try db!.prepare(records) {
                let trans = self.transactionWithRow(tran);
                if search == nil || search == "" {
                    ret.append(trans);
                } else if (trans.PrepopId != -1) {
                    let prepop = self.getPrepopForm(trans.PrepopId);
                    if prepop != nil && prepop!.PrepopName.lowercased().contains(search!.lowercased()) {
                        ret.append(trans);
                    }
                }
            }
            return ret;
        } catch {
            return getHistory(user, search: search, status: status);
        }
    }
    
    open func getAllHistory(_ user : String, search: String? = nil) -> [IWTransaction] {
        return self.getHistory(user, search: search);
    }
    
    open func getParkedHistory(_ user: String, search: String? = nil) -> [IWTransaction] {
        return self.getHistory(user, search: search, status: .Parked);
    }
    
    open func getSendingHistory(_ user: String, search: String? = nil) -> [IWTransaction] {
        return self.getHistory(user, search: search, status: .Sending);
    }
    
    open func getSentHistory(_ user: String, search: String? = nil) -> [IWTransaction] {
        return self.getHistory(user, search: search, status: .Sent);
    }
    
    open func getAutosavedHistory(_ user: String, search: String? = nil) -> [IWTransaction] {
        return self.getHistory(user, search: search, status: .Autosaved);
    }
    
    fileprivate func transDate(_ date: Date?, encrypted: Bool = true) -> String {
        let df = DateFormatter();
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS";
        return date == nil
            ? encrypted ? self.encryptedString(""): ""
            : encrypted ? self.encryptedString(df.string(from: date!)) : df.string(from:date!);
    }
    
    open func addOrUpdateTransaction(_ trans: IWTransaction) -> IWTransaction {

        if trans.ColumnIndex == -1 {
            //add
            do {
                let ind = try db!.run(Transaction.insert(self.FormId <- trans.FormId, self.SentBool <- trans.Sent ? 1 : 0, self.Username <- trans.Username, self.SavedDate <- transDate(trans.SentDate), self.AddedDate <- transDate(trans.AddedDate, encrypted: false), self.SentDate <- transDate(trans.SentDate), self.OriginalAddedDate <- transDate(trans.OriginalAddedDate), self.AutoSavedDate <- transDate(trans.AutoSavedDate), self.FormName <- self.encryptedString(trans.FormName), self.PenData <- self.encryptedString(trans.PenDataXml), self.StrokeData <- self.encryptedString(trans.StrokesXml), self.Status <- trans.Status, self.HistoryItemIndex <- trans.HistoryItemIndex, self.PasswordHash <- self.encryptedString(trans.HashedPassword), self.TransPrepopId <- trans.PrepopId, self.ParentTransaction <- trans.ParentTransaction));
                trans.ColumnIndex = ind;
                return trans;
            } catch {
                return addOrUpdateTransaction(trans);
            }
        } else {
            //update
            do {
                let record = Transaction.filter(self.ColumnIndex == trans.ColumnIndex);
                try db!.run(record.update(self.FormId <- trans.FormId, self.SentBool <- trans.Sent ? 1 : 0, self.Username <- trans.Username, self.SavedDate <- transDate(trans.SentDate), self.AddedDate <- transDate(trans.AddedDate, encrypted: false), self.SentDate <- transDate(trans.SentDate), self.OriginalAddedDate <- transDate(trans.OriginalAddedDate), self.AutoSavedDate <- transDate(trans.AutoSavedDate), self.FormName <- self.encryptedString(trans.FormName), self.PenData <- self.encryptedString(trans.PenDataXml), self.StrokeData <- self.encryptedString(trans.StrokesXml), self.Status <- trans.Status, self.HistoryItemIndex <- trans.HistoryItemIndex, self.PasswordHash <- self.encryptedString(trans.HashedPassword), self.TransPrepopId <- trans.PrepopId, self.ParentTransaction <- trans.ParentTransaction));
                return trans;
            } catch {
                return self.addOrUpdateTransaction(trans);
            }
        }
    }
    
    open func removeTransaction(_ transaction : IWTransaction, clearPrepop: Bool = true) -> Bool {
        let record = Transaction.filter(self.ColumnIndex == transaction.ColumnIndex);
        do {
            if transaction.PrepopId != -1 && clearPrepop {
                let prepop = self.getPrepopForm(transaction.PrepopId);
                if prepop != nil {
                   self.deleteForm(prepop!);
                }
            }
            try db!.run(record.delete());
            return true;
        } catch {
            return false;
        }
    }
    
    
    open func removeOldTransactions() -> Bool {
        let thirtyDaysAgo = NSCalendar.autoupdatingCurrent.date(byAdding: .day, value: -30, to: Date())!;
        let records = Transaction.filter(self.SentBool == 1).order(self.SentDate.desc);
        var ok = true;
        do {
            for record in try db!.prepare(records) {
                let tran = self.transactionWithRow(record);
                if thirtyDaysAgo.timeIntervalSince(tran.SentDate!) > 0{
                    ok = ok && self.removeTransaction(tran);
                }
            }
            return ok;
        } catch {
            return false;
        }
    }
    
    fileprivate func fixAwaitingStatus() -> Bool {
        var ret = true;
        
        var forms = Transaction.filter(self.Status == FormStatus.Awaiting.rawValue);
        do {
            try db!.run(forms.update(self.Status <- FormStatus.Parked.rawValue));
        } catch {
            return false;
        }
        
        return ret;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
