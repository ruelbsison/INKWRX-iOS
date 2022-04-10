//
//  IWFileSystem.h
//  Inkworks
//
//  Created by Jamie Duggan on 30/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWFileSystem : NSObject {
    
}

+ (IWFileSystem *)defaultSystem;

//Static functions
+ (NSString *)getInkworksFolder;
+ (NSString *)getFormsFolder;
+ (NSString *)getPreviewsFolder;
+ (NSString *)getFormPhotoFolder;
+ (NSString *)getFormFolderWithId: (long) formId;
+ (NSString *) getApplicationPreviewWithId:(long)formId;
+ (NSString *)getZipFilePathWithId: (long) formId;
+ (NSString *)getPreviewImagePathWithId: (long) formId;
+ (NSString *)getDatabaseFileName;
+ (NSString *)getFormPhotoFolderWithId: (long) formId;
+ (NSString *)getFormPhotoPathWithId: (long) formId andUUID: (NSUUID *) uuid;

+ (void) saveFileWithFileName: (NSString *)fileName andData: (NSData *)data;
+ (NSData *) loadDataFromFile: (NSString *)fileName;

@end
