//
//  IWFileSystem.m
//  Inkworks
//
//  Created by Jamie Duggan on 30/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWFileSystem.h"

@implementation IWFileSystem

static IWFileSystem *sys;

+ (IWFileSystem *) defaultSystem{
    if (sys == nil){
        sys = [[IWFileSystem alloc] init];
    }
    return sys;
}

+ (NSString *) getInkworksFolder{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    documentsPath = [documentsPath stringByAppendingPathComponent:@"Inkworks"];
    NSError *error;
    [[NSFileManager defaultManager]createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:&error];
    return documentsPath;
}

+ (NSString *) getFormsFolder{
    NSString *documentsPath = [IWFileSystem getInkworksFolder];
    NSString *formsPath = [documentsPath stringByAppendingPathComponent:@"forms"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:formsPath withIntermediateDirectories:YES attributes:nil error:&error];
    return formsPath;
}

+ (NSString *) getPreviewsFolder{
    NSString *documentsPath = [IWFileSystem getInkworksFolder];
    NSString *previewsPath = [documentsPath stringByAppendingPathComponent:@"previews"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:previewsPath withIntermediateDirectories:YES attributes:nil error:&error];
    return previewsPath;
}

+ (NSString *) getFormFolderWithId:(long)formId{
    NSString *formsFolder = [IWFileSystem getFormsFolder];
    
    NSString *formFolder = [formsFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu", formId]];
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:formFolder withIntermediateDirectories:YES attributes:nil error:&error];
    
    return formFolder;
}

+ (NSString *) getApplicationPreviewWithId:(long)formId {
    NSString *formFolder = [IWFileSystem getFormFolderWithId:formId];
    NSString *applicationPreview = [formFolder stringByAppendingPathComponent:@"ApplicationPreview001.jpg"];
    return applicationPreview;
}

+ (NSString *) getZipFilePathWithId:(long)formId{
    NSString *formsFolder = [IWFileSystem getFormsFolder];
    NSString *zipFileName = [formsFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.%@",formId, @"zip"]];
    return zipFileName;
}

+ (NSString *) getPreviewImagePathWithId:(long)formId{
    NSString *previewsFolder = [IWFileSystem getPreviewsFolder];
    //Changed to JPG from PNG 04/08/2016
    NSString *previewFileName = [previewsFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.%@",formId, @"jpg"]];
    return previewFileName;
}

+ (NSString *) getDatabaseFileName{
    NSString *inkworksFolder = [IWFileSystem getInkworksFolder];
    NSString *dbPath = [inkworksFolder stringByAppendingPathComponent:@"inkworks.db"];
    return dbPath;
}

+ (void) saveFileWithFileName: (NSString *)fileName andData: (NSData *)data{
    NSError *error;
    
    
    
    [data writeToFile:fileName atomically:NO];
    
    
}

+ (NSString *)getFormPhotoFolder {
    NSString *libFolder = [IWFileSystem getInkworksFolder];
    NSString *formPhotoFolder = [libFolder stringByAppendingPathComponent:@"formPhotos"];
    NSError *error;
    [[NSFileManager defaultManager]createDirectoryAtPath:formPhotoFolder withIntermediateDirectories:YES attributes:nil error:&error];
    return formPhotoFolder;
}

+ (NSString *)getFormPhotoFolderWithId: (long) formId {
    NSString *formPhotoFolder = [IWFileSystem getFormPhotoFolder];
    formPhotoFolder = [formPhotoFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu", formId]];
    NSError *error;
    [[NSFileManager defaultManager]createDirectoryAtPath:formPhotoFolder withIntermediateDirectories:YES attributes:nil error:&error];
    return formPhotoFolder;
}

+ (NSString *)getFormPhotoPathWithId: (long) formId andUUID: (NSUUID *) uuid {
    NSString *formPhotoFolder = [IWFileSystem getFormPhotoFolderWithId:formId];
    NSString *path = [formPhotoFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",[uuid UUIDString], @"jpg"]];
    return path;
}

+ (NSData *) loadDataFromFile: (NSString *)fileName{
    NSData *ret = [NSData dataWithContentsOfFile:fileName];
    return ret;
}

@end
