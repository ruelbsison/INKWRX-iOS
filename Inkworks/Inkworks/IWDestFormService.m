//
//  IWDestFormService.m
//  Inkworks
//
//  Created by Jamie Duggan on 08/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWInkworksService.h"
#import "IWDestFormService.h"
#import "IWDestinyConstants.h"
#import "IWFileSystem.h"
#import "IWGPSUnit.h"
#import "TBXML.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Inkworks-Swift.h"
#import "IWHomeController.h"
#import "IWMainController.h"

#import "IWDestFormObject.h"
#import "IWFileDescriptionWithTabletInfo.h"
#import "IWFileDescriptionPacketWithTabletInfo.h"
#import "IWDestinyChunkResponseMessage.h"
#import "IWDestinyResponse.h"
#import "IWFilePacketWithTabletInfo.h"
#import "IWEformXmlSaveInfo.h"
#import "Bugsee/Bugsee.h"

#define CHUNK_SIZE @50000

#define NAMESPACE @"http://tempuri.org/"
#define DEST_NAMESPACE @"http://destinywireless.com/"
#define SERVICE_NAMESPACE @"urn:destiny-servicectr-net:services:servicecenter:1"

@implementation IWDestFormService

@synthesize connURL, currentSendingImage, photoList, delegate, fileDesc, fileData, filesSent, sendingTransaction, queue, nextSendingChunk, startSendDesc, originalProc;

static IWDestFormService *instance;

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id) initWithUrl: (NSString *) url {
    self = [super init];
    if (self) {
        currentSendingImage = 0;
        delegate = nil;
        fileDesc = nil;
        fileData = nil;
        filesSent = nil;
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        connURL = url;
    }
    return self;
}

- (void)sendTransaction:(IWTransaction *)tfBean {
    sendingTransaction = tfBean;
    //fix transaction if it's pre-password hashing
    if ([tfBean.HashedPassword isEqualToString:@""]) {
        if ([tfBean.Username isEqualToString:[IWInkworksService getInstance].loggedInUser]) {
            tfBean.HashedPassword = [IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword];
            [[IWInkworksService dbHelper] addOrUpdateTransaction:tfBean];
        }
    }
    
    //first check to see if any images exist
    photoList = [[IWInkworksService dbHelper] getPhotos:tfBean.ColumnIndex];
    filesSent = [NSMutableDictionary dictionary];
    if (photoList.count > 0) {
        //photos exist
        
        //start on the first one
        currentSendingImage = 0;
        
        [self sendNextPhoto];
        return;
    }
    
    //no photos, just send transaction
    
    //[self sendTransactionInfo];
    [self sendTransactionInfo];
}

- (void)sendSecureTransaction:(IWTransaction *)tfBean {
    sendingTransaction = tfBean;
    originalProc = tfBean.PenDataXml;
    //fix transaction if it's pre-password hashing
    if ([tfBean.HashedPassword isEqualToString:@""]) {
        if ([tfBean.Username isEqualToString:[IWInkworksService getInstance].loggedInUser]) {
            tfBean.HashedPassword = [IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword];
            [[IWInkworksService dbHelper] addOrUpdateTransaction:tfBean];
        }
    }
    
    //first check to see if any images exist
    photoList = [[IWInkworksService dbHelper] getPhotos:tfBean.ColumnIndex];
    filesSent = [NSMutableDictionary dictionary];
    if (photoList.count > 0) {
        //photos exist
        
        //start on the first one
        currentSendingImage = 0;
        
        [self sendNextPhotoSecure];
        return;
    }
    
    //no photos, just send transaction
    
    //[self sendTransactionInfo];
    [self sendSecureTransactionInfo];
}

- (void) sendTransactionInfo {
    IWGPSUnit *gps = [[IWGPSUnit alloc] init];
    gps.latitude = @0.0;
    gps.longitude = @0.0;
    gps.altitude = @0.0;
    gps.dateStamp = [NSDate date];
    gps.accuracy = @"gps";
    
    if ([IWInkworksService getInstance].location != nil) {
        gps = [IWInkworksService getInstance].location ;
    }
    
    NSString *transactionXml = [IWDestFormService getTransactionXmlWithFiles:filesSent andStartedDate:sendingTransaction.AddedDate andSentDate:[NSDate date] andGPS:gps andPrepopId:sendingTransaction.PrepopId];
    
    IWEformXmlSaveInfo *saveInfo = [[IWEformXmlSaveInfo alloc] initWithNamespace:NAMESPACE];
    saveInfo.Username = sendingTransaction.Username;
    saveInfo.Password = sendingTransaction.HashedPassword;
    saveInfo.TabletId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    saveInfo.TransactionXml = transactionXml;
    saveInfo.PenData = sendingTransaction.StrokesXml;
    saveInfo.XmlData = sendingTransaction.PenDataXml;
    saveInfo.ApplicationKey = [NSNumber numberWithLong:sendingTransaction.FormId];
    
    NSString *functionName = @"SaveEFormWithXML";
    NSMutableURLRequest *request = [self getRequestWithFunctionName:functionName andObject:saveInfo];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:error.localizedDescription];
            }
            return;
        }
        
        if (((NSHTTPURLResponse *)response).statusCode == 404) {
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:@"404"];
            }
            return;
        }
        
        NSError *err;
        TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
        
        
        TBXMLElement *elem = [xmlFile rootXMLElement];
        
        IWDestinyResponse *resp;
        if ([[TBXML elementName:elem] rangeOfString:@"Envelope"].location != NSNotFound) {
            NSLog (@"%@", @"Envelope found");
            TBXMLElement *child = elem->firstChild;
            while (child) {
                if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                    TBXMLElement *destRespX = child->firstChild;
                    while (destRespX) {
                        if ([[TBXML elementName:destRespX] isEqualToString:@"DestinyResponseMessage"]){
                            //found destchunk
                            resp = [[IWDestinyResponse alloc] initWithNamespace:NAMESPACE andXml:destRespX];
                            if ([resp.Errorcode intValue] == 0) {
                                IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
                                IWPrepopForm *form = nil;
                                if (sendingTransaction.PrepopId != -1) {
                                    form = [swift getPrepopForm:sendingTransaction.PrepopId];
                                    if (form) {
                                        form.PrepopStatus = 3;
                                        [swift addOrUpdatePrepopForm:form];
                                    }
                                    
                                }
                                
                                if (delegate != nil) {
                                    [delegate formSendingComplete:sendingTransaction completion:resp];
                                }
                            } else {
                                NSLog(@"Error code %@: %@", resp.Errorcode, resp.GeneralResponse);
                                if (delegate != nil) {
                                    [delegate formSendingError:sendingTransaction error:resp.GeneralResponse];
                                }
                            }
                        }
                        
                        destRespX = destRespX->nextSibling;
                    }
                }
                child = child->nextSibling;
            }
        }
    }];
    
}

- (void) sendSecureTransactionInfo {
    IWGPSUnit *gps = [[IWGPSUnit alloc] init];
    gps.latitude = @0.0;
    gps.longitude = @0.0;
    gps.altitude = @0.0;
    gps.dateStamp = [NSDate date];
    gps.accuracy = @"gps";
    
    if ([IWInkworksService getInstance].location != nil) {
        gps = [IWInkworksService getInstance].location ;
    }
    
    NSString *transactionXml = [IWDestFormService getTransactionXmlWithFiles:filesSent andStartedDate:sendingTransaction.AddedDate andSentDate:[NSDate date] andGPS:gps andPrepopId:sendingTransaction.PrepopId];
    
//    IWEformXmlSaveInfo *saveInfo = [[IWEformXmlSaveInfo alloc] initWithNamespace:NAMESPACE];
//    saveInfo.Username = sendingTransaction.username;
//    saveInfo.Password = sendingTransaction.hashedPassword;
//    saveInfo.TabletId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    saveInfo.TransactionXml = transactionXml;
//    saveInfo.PenData = sendingTransaction.strokesXml;
//    saveInfo.XmlData = sendingTransaction.penDataXml;
//    saveInfo.ApplicationKey = [NSNumber numberWithLong:sendingTransaction.formId];
    
    IWSendData *saveInfo = [[IWSendData alloc] initWithNameSpace:DEST_NAMESPACE propNameSpace:DEST_NAMESPACE];
    
    IWSaveEformWithXml *save = [[IWSaveEformWithXml alloc] initWithUserName:sendingTransaction.Username password:sendingTransaction.HashedPassword xmlData:sendingTransaction.PenDataXml penData:sendingTransaction.StrokesXml appKey:sendingTransaction.FormId transXml:transactionXml];
    
    NSString *xData = save.XmlData;
    
    NSDictionary *replacements = @{
                                   @0:@[@"&g[^;]*<",@"&gt;<"],
                                   @1:@[@"&l[^;]*<",@"&lt;<"],
                                   @2:@[@"&[^;]*<",@"<"]
                                   };
    
    for (int i = 0; i < replacements.count; i++) {
        NSNumber *atI = @(i);
        NSString *srch = replacements[atI][0];
        NSString *rep = replacements[atI][1];
        NSError *error;
        NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:srch options:options error:&error];
        NSArray *matches = [regex matchesInString:xData options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, xData.length)];
        if (matches.count > 0) {
            for (int k = matches.count - 1; k >= 0; k--) {
                NSTextCheckingResult *res = matches[k];
                NSRange matchRange = [res rangeAtIndex:0];
                xData = [xData stringByReplacingCharactersInRange:matchRange withString:rep];
            }
            save.XmlData = xData;
        }
    }
    
    save.XmlData = [xData stringByReplacingOccurrencesOfString:@"        <field fieldid=\"fdtElem997Group\">\n                    </value>\n                    </field>" withString:@"        <field fieldid=\"fdtElem997Group\">\n                    <value actionid=\"1\" actiontype=\"entry\"></value>\n                    </field>"];
    NSString * testData = [save GetXml];
    //NSString *unencrypted = [save GetXml];
    saveInfo.Date = [[IWInkworksService getInstance].encryptedDateFormatter stringFromDate:[NSDate new]];
    saveInfo.Data = [IWInkworksService encrypt:[save GetXml] withKey:[IWInkworksService getCryptoKey:saveInfo.Date]];
    
    NSString *functionName = @"SendData";
    NSMutableURLRequest *request = [self getSecureRequestWithFunctionName:functionName andObject:saveInfo];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:error.localizedDescription];
            }
            return;
        }
        
        if (((NSHTTPURLResponse *)response).statusCode == 404) {
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:@"404"];
            }
            return;
        }
        
        NSError *err;
        TBXML *xmlFile = nil;
        xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
        if (err != nil) {
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:@"9111"];
            }
            return;
        }
        
        TBXMLElement *elem = [xmlFile rootXMLElement];
        
        IWDestinyResponse *resp;
        if ([[TBXML elementName:elem] rangeOfString:@"Envelope"].location != NSNotFound) {
            NSLog (@"%@", @"Envelope found");
            TBXMLElement *child = elem->firstChild;
            while (child) {
                if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                    TBXMLElement *destRespX = child->firstChild;
                    while (destRespX) {
                        if ([[TBXML elementName:destRespX] isEqualToString:@"DestRespMessage"]){
                            //found destchunk
                            resp = [[IWDestinyResponse alloc] initWithNamespace:NAMESPACE andXml:destRespX];
                            
                            if (![resp.Data isEqualToString:@""]){
                                NSString *decrypted = [IWInkworksService decrypt:resp.Data withKey:[IWInkworksService getCryptoKey:resp.Date]];
                                IWSecureResponse *secResp = [[IWSecureResponse alloc] initWithXml:decrypted];
                                
                                if (secResp.ErrorCode == 0) {
                                    IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
                                    IWPrepopForm *form = nil;
                                    if (sendingTransaction.PrepopId != -1) {
                                        form = [swift getPrepopForm:sendingTransaction.PrepopId];
                                        if (form) {
                                            form.PrepopStatus = 3;
                                            [swift addOrUpdatePrepopForm:form];
                                        }
                                        
                                    }
                                    
                                    if (delegate != nil) {
                                        sendingTransaction.PenDataXml = originalProc;
                                        [delegate formSendingComplete:sendingTransaction completion:resp];
                                    }
                                } else {
                                    NSLog(@"Error code %ld: %@", (long)secResp.ErrorCode, secResp.Message);
                                    if (delegate != nil) {
                                        [delegate formSendingError:sendingTransaction error:secResp.Message];
                                    }
                                }
                            } else {
                                if (delegate) {
                                    [delegate formSendingError:sendingTransaction error:@"Data decrytion error"];
                                }
                            }
                            
                            
                        }
                        
                        destRespX = destRespX->nextSibling;
                    }
                }
                child = child->nextSibling;
            }
        }
    }];
    
}

- (void) sendNextPhoto {
    IWAttachedPhoto *photo = photoList[currentSendingImage];
    NSString *fileName = [NSString stringWithFormat:@"%@_%d.jpg", [photo.ImageType isEqualToString:@"FORM_PHOTO"] ? @"camera" : @"gallery", currentSendingImage];
    
    if ([photo.ImageStatus isEqualToString:STATUS_SENT]) {
        NSDate *date = [NSDate date];
        [filesSent setObject:date forKey:fileName];
        currentSendingImage++;
        if (currentSendingImage > photoList.count - 1) {
            // all files done...
            [self sendTransactionInfo];
        } else {
            [self sendNextPhoto];
        }
        return;
    }
    
    fileData = nil;
    
    if ([photo.ImageType isEqualToString:@"FORM_PHOTO"]) {
        
        NSString *uuidStr = [photo.ImagePath.lastPathComponent stringByReplacingOccurrencesOfString:@".png" withString:@""];
        sendingTransaction.PenDataXml = [sendingTransaction.PenDataXml stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{UUID}%@{/UUID}", uuidStr] withString:fileName];
        
        
        fileData = [IWFileSystem loadDataFromFile:photo.ImagePath];
        
        fileDesc = [[IWFileDescriptionPacketWithTabletInfo alloc] initWithNamespace:NAMESPACE];
        fileDesc.Username = sendingTransaction.Username;
        fileDesc.Password = sendingTransaction.HashedPassword;
        fileDesc.TabletId = [[UIDevice currentDevice].identifierForVendor UUIDString];
        fileDesc.Filename = fileName;
        fileDesc.Filesize = [NSNumber numberWithInt: fileData.length];
        fileDesc.PacketSize = CHUNK_SIZE;
        fileDesc.MaxPacketCount = [NSNumber numberWithInt:(int)ceilf([fileDesc.Filesize floatValue] / [fileDesc.PacketSize floatValue])];
        
        NSString *functionName = @"StartSendFilePacketWithTablet";
        NSMutableURLRequest *request = [self getRequestWithFunctionName:functionName andObject:fileDesc];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if (error != nil) {
                 NSLog(@"%@", error.localizedDescription);
                 if (delegate != nil) {
                     [delegate formSendingError:sendingTransaction error:error.localizedDescription];
                 }
                 return;
             }
             if (((NSHTTPURLResponse *)response).statusCode == 404) {
                 if (delegate != nil) {
                     [delegate formSendingError:sendingTransaction error:@"404"];
                 }
                 return;
             }
             NSError *err;
             TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
             
             
             TBXMLElement *elem = [xmlFile rootXMLElement];
             
             if ([[TBXML elementName:elem] rangeOfString:@"Envelope"].location != NSNotFound) {
                 NSLog (@"%@", @"Envelope found");
                 IWDestinyChunkResponseMessage *resp;
                 TBXMLElement *child = elem->firstChild;
                 while (child) {
                     if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                         TBXMLElement *destRespX = child->firstChild;
                         while (destRespX) {
                             if ([[TBXML elementName:destRespX] isEqualToString:@"DestinyChunkResponseMessage"]){
                                 //found destchunk
                                 resp = [[IWDestinyChunkResponseMessage alloc] initWithNamespace:NAMESPACE andXml:destRespX];
                                 if ([resp.Errorcode intValue] == 0) {
                                     nextSendingChunk = [resp.NextExpectedChunk intValue];
                                     if ([resp.NextExpectedChunk intValue] > -1) {
                                         if ([resp.NextExpectedChunk intValue] > [fileDesc.MaxPacketCount intValue] - 1){
                                             //something went wrong?
                                             
                                             [self finalizeCurrentFile];
                                             
                                         } else {
                                             [self sendNextChunk];
                                         }
                                     } else {
                                         // must be finished file...
                                         [self finalizeCurrentFile];
                                     }
                                     
                                 } else {
                                     NSLog(@"Error code %@: %@", resp.Errorcode, resp.Message);
                                     if (delegate != nil) {
                                         [delegate formSendingError:sendingTransaction error:resp.Message];
                                     }
                                 }
                             }
                             
                             destRespX = destRespX->nextSibling;
                         }
                     }
                     child = child->nextSibling;
                 }
             }
             
         }];

        
    } else {
        PHAsset *asset = nil;
        if ([photo.ImagePath rangeOfString:@"{PH}"].location == NSNotFound) {
            NSURL *url = [NSURL URLWithString:photo.ImagePath];
            PHFetchOptions *opts = [[PHFetchOptions alloc] init];
            opts.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary | PHAssetSourceTypeCloudShared;
            PHFetchResult *fetchRes = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:opts];
            if (fetchRes.count > 0) {
                asset = [fetchRes firstObject];
            }
        }
        
        if (!asset) {
            NSString *localId = [photo.ImagePath stringByReplacingOccurrencesOfString:@"{PH}" withString:@""];
            PHFetchOptions *opts = [[PHFetchOptions alloc] init];
            opts.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary | PHAssetSourceTypeCloudShared;
            PHFetchResult *fetchRes = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:opts];
            if (fetchRes.count > 0) {
                asset = [fetchRes firstObject];
            }
        }
        
        if (asset) {
            CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
            PHImageRequestOptions *imgOpts = [[PHImageRequestOptions alloc] init];
            imgOpts.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            imgOpts.resizeMode = PHImageRequestOptionsResizeModeExact;
            imgOpts.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:imgOpts resultHandler:^(UIImage *img, NSDictionary *info){
                fileData = UIImageJPEGRepresentation(img, 80);
                
                fileDesc = [[IWFileDescriptionPacketWithTabletInfo alloc] initWithNamespace:NAMESPACE];
                fileDesc.Username = sendingTransaction.Username;
                fileDesc.Password = sendingTransaction.HashedPassword;
                fileDesc.TabletId = [[UIDevice currentDevice].identifierForVendor UUIDString];
                fileDesc.Filename = fileName;
                fileDesc.Filesize = [NSNumber numberWithInt: fileData.length];
                fileDesc.PacketSize = CHUNK_SIZE;
                fileDesc.MaxPacketCount = [NSNumber numberWithInt:(int)ceilf([fileDesc.Filesize floatValue] / [fileDesc.PacketSize floatValue])];
                
            }];
            
        }
        
        //fileData = [NSData dataWithContentsOfURL:url];
        
        // OLD method - deprecated 12/11/15
//        
//        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
//        {
//            @try {
//            if (myasset) {
//                ALAssetRepresentation *rep = [myasset defaultRepresentation];
//                CGImageRef imgRef = [rep fullScreenImage];
//                
//                UIImageOrientation orientation = UIImageOrientationUp;
//                
//                NSNumber* orientationValue = [myasset valueForProperty:@"ALAssetPropertyOrientation"];
//                if (orientationValue != nil) {
//                    orientation = [orientationValue intValue];
//                }
//                UIImage *img = [UIImage imageWithCGImage:imgRef];
//                //scale:[rep scale] orientation:orientation];
//                
//                fileData = UIImageJPEGRepresentation(img, 80);
//                
//                fileDesc = [[IWFileDescriptionPacketWithTabletInfo alloc] initWithNamespace:NAMESPACE];
//                fileDesc.Username = sendingTransaction.username;
//                fileDesc.Password = sendingTransaction.hashedPassword;
//                fileDesc.TabletId = [[UIDevice currentDevice].identifierForVendor UUIDString];
//                fileDesc.Filename = fileName;
//                fileDesc.Filesize = [NSNumber numberWithInt: fileData.length];
//                fileDesc.PacketSize = CHUNK_SIZE;
//                fileDesc.MaxPacketCount = [NSNumber numberWithInt:(int)ceilf([fileDesc.Filesize floatValue] / [fileDesc.PacketSize floatValue])];
//                
//                NSString *functionName = @"StartSendFilePacketWithTablet";
//                NSMutableURLRequest *request = [self getRequestWithFunctionName:functionName andObject:fileDesc];
//                
//                [NSURLConnection sendAsynchronousRequest:request
//                                                   queue:queue
//                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//                 {
//                     if (error != nil) {
//                         NSLog(@"%@", error.localizedDescription);
//                         if (delegate != nil) {
//                             [delegate formSendingError:sendingTransaction error:error.localizedDescription];
//                         }
//                         return;
//                     }
//                     if (((NSHTTPURLResponse *)response).statusCode == 404) {
//                         if (delegate != nil) {
//                             [delegate formSendingError:sendingTransaction error:@"404"];
//                         }
//                         return;
//                     }
//                     NSError *err;
//                     TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
//                     
//                     
//                     TBXMLElement *elem = [xmlFile rootXMLElement];
//                     
//                     if ([[TBXML elementName:elem] rangeOfString:@"Envelope"].location != NSNotFound) {
//                         NSLog (@"%@", @"Envelope found");
//                         IWDestinyChunkResponseMessage *resp;
//                         TBXMLElement *child = elem->firstChild;
//                         while (child) {
//                             if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
//                                 TBXMLElement *destRespX = child->firstChild;
//                                 while (destRespX) {
//                                     if ([[TBXML elementName:destRespX] isEqualToString:@"DestinyChunkResponseMessage"]){
//                                         //found destchunk
//                                         resp = [[IWDestinyChunkResponseMessage alloc] initWithNamespace:NAMESPACE andXml:destRespX];
//                                         if ([resp.Errorcode intValue] == 0) {
//                                             nextSendingChunk = [resp.NextExpectedChunk intValue];
//                                             if ([resp.NextExpectedChunk intValue] > -1) {
//                                                 if ([resp.NextExpectedChunk intValue] > [fileDesc.MaxPacketCount intValue] - 1){
//                                                     //something went wrong?
//                                                     
//                                                     [self finalizeCurrentFile];
//                                                     
//                                                 } else {
//                                                     [self sendNextChunk];
//                                                 }
//                                             } else {
//                                                 // must be finished file...
//                                                 [self finalizeCurrentFile];
//                                             }
//                                             
//                                         } else {
//                                             NSLog(@"Error code %@: %@", resp.Errorcode, resp.Message);
//                                             if (delegate != nil) {
//                                                 [delegate formSendingError:sendingTransaction error:resp.Message];
//                                             }
//                                         }
//                                     }
//                                     
//                                     destRespX = destRespX->nextSibling;
//                                 }
//                             }
//                             child = child->nextSibling;
//                         }
//                     }
//                     
//                 }];
//            }
//            } @catch (NSException *ex) {
//                NSLog(@"Error at sendNextPhoto");
//            }
//        };
//        
//        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
//        {
//            NSLog(@"Can't get image - %@",[myerror localizedDescription]);
//        };
//        
//         ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
//         [assetslibrary assetForURL:url
//                        resultBlock:resultblock
//                       failureBlock:failureblock];
        
        
        
    }
    
}

- (void) sendNextPhotoSecure {
    IWAttachedPhoto *photo = photoList[currentSendingImage];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@_%d_%d.jpg", [photo.ImageType isEqualToString:@"FORM_PHOTO"] ? @"camera" : @"gallery", sendingTransaction.Username, [[[UIDevice currentDevice] identifierForVendor] UUIDString], (int)sendingTransaction.ColumnIndex, currentSendingImage];
    
    if ([photo.ImageStatus isEqualToString:STATUS_SENT]) {
        NSDate *date = [NSDate date];
        [filesSent setObject:date forKey:fileName];
        if ([photo.ImageType isEqualToString:@"FORM_PHOTO"]) {
            NSString *uuidStr = [[photo.ImagePath.lastPathComponent stringByReplacingOccurrencesOfString:@".png" withString:@""] stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
            sendingTransaction.PenDataXml = [sendingTransaction.PenDataXml stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{UUID}%@{/UUID}", uuidStr] withString:fileName];
        } else {
            sendingTransaction.PenDataXml = [sendingTransaction.PenDataXml stringByReplacingOccurrencesOfString:photo.ImagePath withString:fileName];
        }
        currentSendingImage++;
        if (currentSendingImage > photoList.count - 1) {
            // all files done...
            [self sendSecureTransactionInfo];
        } else {
            [self sendNextPhotoSecure];
        }
        return;
    }
    
    fileData = nil;
    
    if ([photo.ImageType isEqualToString:@"FORM_PHOTO"]) {
        NSString *uuidStr = [[photo.ImagePath.lastPathComponent stringByReplacingOccurrencesOfString:@".png" withString:@""] stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
        sendingTransaction.PenDataXml = [sendingTransaction.PenDataXml stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{UUID}%@{/UUID}", uuidStr] withString:fileName];
        
        
        
        fileData = [IWFileSystem loadDataFromFile:photo.ImagePath];
        
        startSendDesc = [[IWStartSendFilePacketWithTablet alloc] initWithUserName:sendingTransaction.Username password:sendingTransaction.HashedPassword fileName:fileName maxPackets:(int)ceilf((float)fileData.length / [CHUNK_SIZE floatValue]) blockSize:[CHUNK_SIZE intValue] fileSize:fileData.length];
//        fileDesc = [[IWFileDescriptionPacketWithTabletInfo alloc] initWithNamespace:NAMESPACE];
//        fileDesc.Username = sendingTransaction.username;
//        fileDesc.Password = sendingTransaction.hashedPassword;
//        fileDesc.TabletId = [[UIDevice currentDevice].identifierForVendor UUIDString];
//        fileDesc.Filename = fileName;
//        fileDesc.Filesize = [NSNumber numberWithInt: fileData.length];
//        fileDesc.PacketSize = CHUNK_SIZE;
//        fileDesc.MaxPacketCount = [NSNumber numberWithInt:(int)ceilf([fileDesc.Filesize floatValue] / [fileDesc.PacketSize floatValue])];
//
        
        IWSendData *sendData = [[IWSendData alloc] initWithNameSpace:DEST_NAMESPACE propNameSpace:DEST_NAMESPACE];
        sendData.Date = [[IWInkworksService getInstance].encryptedDateFormatter stringFromDate:[NSDate new]];
        sendData.Data = [IWInkworksService encrypt:[startSendDesc GetXml] withKey:[IWInkworksService getCryptoKey:sendData.Date]];
        
        
        NSString *functionName = @"SendData";
        NSMutableURLRequest *request = [self getSecureRequestWithFunctionName:functionName andObject:sendData];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             if (error != nil) {
                 NSLog(@"%@", error.localizedDescription);
                 if (delegate != nil) {
                     [delegate formSendingError:sendingTransaction error:error.localizedDescription];
                 }
                 return;
             }
             if (((NSHTTPURLResponse *)response).statusCode == 404) {
                 if (delegate != nil) {
                     [delegate formSendingError:sendingTransaction error:@"404"];
                 }
                 return;
             }
             NSError *err;
             TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
             if (err != nil) {
                 if (delegate != nil) {
                     [delegate formSendingError:sendingTransaction error:@"9111"];
                 }
                 return;
             }
             
             TBXMLElement *elem = [xmlFile rootXMLElement];
             
             if ([[TBXML elementName:elem] rangeOfString:@"Envelope"].location != NSNotFound) {
                 NSLog (@"%@", @"Envelope found");
                 IWDestinyResponse *resp;
                 TBXMLElement *child = elem->firstChild;
                 while (child) {
                     if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                         TBXMLElement *destRespX = child->firstChild;
                         while (destRespX) {
                             if ([[TBXML elementName:destRespX] isEqualToString:@"DestRespMessage"]){
                                 //found destchunk
                                 resp = [[IWDestinyResponse alloc] initWithNamespace:NAMESPACE andXml:destRespX];
                                 IWSecureResponse *secResp = nil;
                                 if (![resp.Data isEqualToString:@""]) {
                                     NSString *decrypted = [IWInkworksService decrypt:resp.Data withKey:[IWInkworksService getCryptoKey:resp.Date]];
                                     secResp = [[IWSecureResponse alloc] initWithXml:decrypted];
                                 }
                                 
                                 if (secResp.ErrorCode == 0) {
                                     nextSendingChunk = secResp.NextPacketId;
                                     if (secResp.NextPacketId > -1) {
                                         if (secResp.NextPacketId > startSendDesc.MaxPackets - 1){
                                             //something went wrong?
                                             
                                             [self finalizeCurrentFileSecure];
                                             
                                         } else {
                                             [self sendNextChunkSecure];
                                         }
                                     } else {
                                         // must be finished file...
                                         [self finalizeCurrentFileSecure];
                                     }
                                     
                                 } else {
                                     NSLog(@"Error code %ld: %@", (long)secResp.ErrorCode, secResp.Message);
                                     if (delegate != nil) {
                                         [delegate formSendingError:sendingTransaction error:secResp.Message];
                                     }
                                 }
                             }
                             
                             destRespX = destRespX->nextSibling;
                         }
                     }
                     child = child->nextSibling;
                 }
             }
             
         }];
        
        
    } else {
        
        PHAsset *asset = nil;
        if ([photo.ImagePath rangeOfString:@"{PH}"].location == NSNotFound) {
            NSURL *url = [NSURL URLWithString:photo.ImagePath];
            PHFetchOptions *opts = [[PHFetchOptions alloc] init];
            opts.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary | PHAssetSourceTypeCloudShared;
            PHFetchResult *fetchRes = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:opts];
            if (fetchRes.count > 0) {
                asset = [fetchRes firstObject];
            }
        }
        
        if (!asset) {
            NSString *localId = [photo.ImagePath stringByReplacingOccurrencesOfString:@"{PH}" withString:@""];
            PHFetchOptions *opts = [[PHFetchOptions alloc] init];
            opts.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary | PHAssetSourceTypeCloudShared;
            PHFetchResult *fetchRes = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:opts];
            if (fetchRes.count > 0) {
                asset = [fetchRes firstObject];
            }
        }
        
        if (asset) {
            
            
            
            NSString *repl = [NSString stringWithFormat:@"{PH}%@{/PH}", asset.localIdentifier];
            sendingTransaction.PenDataXml = [sendingTransaction.PenDataXml stringByReplacingOccurrencesOfString:repl withString:fileName];
            
            CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
            PHImageRequestOptions *imgOpts = [[PHImageRequestOptions alloc] init];
            imgOpts.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            imgOpts.resizeMode = PHImageRequestOptionsResizeModeExact;
            imgOpts.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:imgOpts resultHandler:^(UIImage *img, NSDictionary *info){
                
                UIImage *uiimg = nil;
                
                switch (img.imageOrientation) {
                    case UIImageOrientationUp:
                        uiimg = img;
                        break;
                    default:
                        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
                        [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
                        uiimg = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        break;
                }
                
                fileData = UIImagePNGRepresentation(uiimg);
                startSendDesc = [[IWStartSendFilePacketWithTablet alloc] initWithUserName:sendingTransaction.Username password:sendingTransaction.HashedPassword fileName:fileName maxPackets:(int)ceilf((float)fileData.length / [CHUNK_SIZE floatValue]) blockSize:[CHUNK_SIZE intValue] fileSize:fileData.length];
                
                fileDesc = [[IWFileDescriptionPacketWithTabletInfo alloc] initWithNamespace:NAMESPACE];
                fileDesc.Username = sendingTransaction.Username;
                fileDesc.Password = sendingTransaction.HashedPassword;
                fileDesc.TabletId = [[UIDevice currentDevice].identifierForVendor UUIDString];
                fileDesc.Filename = fileName;
                fileDesc.Filesize = [NSNumber numberWithInt: fileData.length];
                fileDesc.PacketSize = CHUNK_SIZE;
                fileDesc.MaxPacketCount = [NSNumber numberWithInt:(int)ceilf([fileDesc.Filesize floatValue] / [fileDesc.PacketSize floatValue])];
                
                NSString *unenc = [startSendDesc GetXml];
                
                IWSendData *sendData = [[IWSendData alloc] initWithNameSpace:DEST_NAMESPACE propNameSpace:DEST_NAMESPACE];
                sendData.Date = [[IWInkworksService getInstance].encryptedDateFormatter stringFromDate:[NSDate new]];
                sendData.Data = [IWInkworksService encrypt:[startSendDesc GetXml] withKey:[IWInkworksService getCryptoKey:sendData.Date]];
                
                
                NSString *functionName = @"SendData";
                NSMutableURLRequest *request = [self getSecureRequestWithFunctionName:functionName andObject:sendData];
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:queue
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                 {
                     
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     if (error != nil) {
                         NSLog(@"%@", error.localizedDescription);
                         if (delegate != nil) {
                             [delegate formSendingError:sendingTransaction error:error.localizedDescription];
                         }
                         return;
                     }
                     if (((NSHTTPURLResponse *)response).statusCode == 404) {
                         if (delegate != nil) {
                             [delegate formSendingError:sendingTransaction error:@"404"];
                         }
                         return;
                     }
                     NSError *err;
                     TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
                     if (err != nil) {
                         if (delegate != nil) {
                             [delegate formSendingError:sendingTransaction error:@"9111"];
                         }
                         return;
                     }
                     
                     TBXMLElement *elem = [xmlFile rootXMLElement];
                     
                     if ([[TBXML elementName:elem] rangeOfString:@"Envelope"].location != NSNotFound) {
                         NSLog (@"%@", @"Envelope found");
                         IWDestinyResponse *resp;
                         TBXMLElement *child = elem->firstChild;
                         while (child) {
                             if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                                 TBXMLElement *destRespX = child->firstChild;
                                 while (destRespX) {
                                     if ([[TBXML elementName:destRespX] isEqualToString:@"DestRespMessage"]){
                                         //found destchunk
                                         resp = [[IWDestinyResponse alloc] initWithNamespace:NAMESPACE andXml:destRespX];
                                         
                                         NSString *decrypted = [IWInkworksService decrypt:resp.Data withKey:[IWInkworksService getCryptoKey:resp.Date]];
                                         IWSecureResponse *secResp = [[IWSecureResponse alloc] initWithXml:decrypted];
                                         
                                         
                                         if (secResp.ErrorCode == 0) {
                                             nextSendingChunk = secResp.NextPacketId;
                                             if (secResp.NextPacketId > -1) {
                                                 if (secResp.NextPacketId > startSendDesc.MaxPackets - 1){
                                                     //something went wrong?
                                                     
                                                     [self finalizeCurrentFileSecure];
                                                     
                                                 } else {
                                                     [self sendNextChunkSecure];
                                                 }
                                             } else {
                                                 // must be finished file...
                                                 [self finalizeCurrentFileSecure];
                                             }
                                             
                                         } else {
                                             NSLog(@"Error code %ld: %@", (long)secResp.ErrorCode, secResp.Message);
                                             if (delegate != nil) {
                                                 [delegate formSendingError:sendingTransaction error:secResp.Message];
                                             }
                                         }
                                     }
                                     
                                     destRespX = destRespX->nextSibling;
                                 }
                             }
                             child = child->nextSibling;
                         }
                     }
                     
                 }];
                
            }];
            
            
            
        } else {
            photo.imageStatus = STATUS_SENT;
            [filesSent setObject:[NSDate date] forKey:fileName];
            currentSendingImage++;
            if (currentSendingImage > photoList.count - 1) {
                // all photos done...
                [self sendSecureTransactionInfo];
            } else {
                //send next photo
                [self sendNextPhotoSecure];
            }
        }

        
        
        
        // OLD method - deprecated 12/11/15
//        NSURL *url = [NSURL URLWithString:photo.imagePath];
//        //fileData = [NSData dataWithContentsOfURL:url];
//
//        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
//        {
//            @try {
//                if (myasset) {
//                    ALAssetRepresentation *rep = [myasset defaultRepresentation];
//                    CGImageRef imgRef = [rep fullScreenImage];
//
//                    UIImageOrientation orientation = UIImageOrientationUp;
//
//                    NSNumber* orientationValue = [myasset valueForProperty:@"ALAssetPropertyOrientation"];
//                    if (orientationValue != nil) {
//                        orientation = [orientationValue intValue];
//                    }
//                    UIImage *img = [UIImage imageWithCGImage:imgRef];
//                    //scale:[rep scale] orientation:orientation];
//                    
//                    fileData = UIImageJPEGRepresentation(img, 80);
//                    startSendDesc = [[IWStartSendFilePacketWithTablet alloc] initWithUserName:sendingTransaction.username password:sendingTransaction.hashedPassword fileName:fileName maxPackets:(int)ceilf((float)fileData.length / [CHUNK_SIZE floatValue]) blockSize:[CHUNK_SIZE intValue] fileSize:fileData.length];
////                    fileDesc = [[IWFileDescriptionPacketWithTabletInfo alloc] initWithNamespace:NAMESPACE];
////                    fileDesc.Username = sendingTransaction.username;
////                    fileDesc.Password = sendingTransaction.hashedPassword;
////                    fileDesc.TabletId = [[UIDevice currentDevice].identifierForVendor UUIDString];
////                    fileDesc.Filename = fileName;
////                    fileDesc.Filesize = [NSNumber numberWithInt: fileData.length];
////                    fileDesc.PacketSize = CHUNK_SIZE;
////                    fileDesc.MaxPacketCount = [NSNumber numberWithInt:(int)ceilf([fileDesc.Filesize floatValue] / [fileDesc.PacketSize floatValue])];
//                    
//                    //NSString *unenc = [startSendDesc GetXml];
//                    
//                    IWSendData *sendData = [[IWSendData alloc] initWithNameSpace:DEST_NAMESPACE propNameSpace:DEST_NAMESPACE];
//                    sendData.Date = [[IWInkworksService getInstance].encryptedDateFormatter stringFromDate:[NSDate new]];
//                    sendData.Data = [IWInkworksService encrypt:[startSendDesc GetXml] withKey:[IWInkworksService getCryptoKey:sendData.Date]];
//                    
//                    
//                    NSString *functionName = @"SendData";
//                    NSMutableURLRequest *request = [self getSecureRequestWithFunctionName:functionName andObject:sendData];
//                    
//                    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
//                    [NSURLConnection sendAsynchronousRequest:request
//                                                       queue:queue
//                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//                     {
//                         
//                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//                         if (error != nil) {
//                             NSLog(@"%@", error.localizedDescription);
//                             if (delegate != nil) {
//                                 [delegate formSendingError:sendingTransaction error:error.localizedDescription];
//                             }
//                             return;
//                         }
//                         if (((NSHTTPURLResponse *)response).statusCode == 404) {
//                             if (delegate != nil) {
//                                 [delegate formSendingError:sendingTransaction error:@"404"];
//                             }
//                             return;
//                         }
//                         NSError *err;
//                         TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
//                         
//                         
//                         TBXMLElement *elem = [xmlFile rootXMLElement];
//                         
//                         if ([[TBXML elementName:elem] rangeOfString:@"Envelope"].location != NSNotFound) {
//                             NSLog (@"%@", @"Envelope found");
//                             IWDestinyResponse *resp;
//                             TBXMLElement *child = elem->firstChild;
//                             while (child) {
//                                 if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
//                                     TBXMLElement *destRespX = child->firstChild;
//                                     while (destRespX) {
//                                         if ([[TBXML elementName:destRespX] isEqualToString:@"DestRespMessage"]){
//                                             //found destchunk
//                                             resp = [[IWDestinyResponse alloc] initWithNamespace:NAMESPACE andXml:destRespX];
//                                             
//                                             NSString *decrypted = [IWInkworksService decrypt:resp.Data withKey:[IWInkworksService getCryptoKey:resp.Date]];
//                                             IWSecureResponse *secResp = [[IWSecureResponse alloc] initWithXml:decrypted];
//                                             
//                                             
//                                             if (secResp.ErrorCode == 0) {
//                                                 nextSendingChunk = secResp.NextPacketId;
//                                                 if (secResp.NextPacketId > -1) {
//                                                     if (secResp.NextPacketId > startSendDesc.MaxPackets - 1){
//                                                         //something went wrong?
//                                                         
//                                                         [self finalizeCurrentFileSecure];
//                                                         
//                                                     } else {
//                                                         [self sendNextChunkSecure];
//                                                     }
//                                                 } else {
//                                                     // must be finished file...
//                                                     [self finalizeCurrentFileSecure];
//                                                 }
//                                                 
//                                             } else {
//                                                 NSLog(@"Error code %ld: %@", (long)secResp.ErrorCode, secResp.Message);
//                                                 if (delegate != nil) {
//                                                     [delegate formSendingError:sendingTransaction error:secResp.Message];
//                                                 }
//                                             }
//                                         }
//                                         
//                                         destRespX = destRespX->nextSibling;
//                                     }
//                                 }
//                                 child = child->nextSibling;
//                             }
//                         }
//                         
//                     }];
//                } else {
//                    photo.imageStatus = STATUS_SENT;
//                    [filesSent setObject:[NSDate date] forKey:fileName];
//                    currentSendingImage++;
//                    if (currentSendingImage > photoList.count - 1) {
//                        // all photos done...
//                        [self sendSecureTransactionInfo];
//                    } else {
//                        //send next photo
//                        [self sendNextPhotoSecure];
//                    }
//                }
//            } @catch (NSException *ex) {
//                NSLog(@"Error at sendNextPhoto");
//            }
//        };
//        
//        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
//        {
//            NSLog(@"Can't get image - %@",[myerror localizedDescription]);
//        };
//        
//        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
//        [assetslibrary assetForURL:url
//                       resultBlock:resultblock
//                      failureBlock:failureblock];
        
    }
    
}


- (void) sendNextChunk {
    NSUInteger length = [fileData length];
    NSUInteger offset = nextSendingChunk * [CHUNK_SIZE intValue];
    
    NSUInteger thisChunkSize = length - offset > [CHUNK_SIZE intValue] ? [CHUNK_SIZE intValue] : length - offset;
    
    NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[fileData bytes] + offset
                                         length:thisChunkSize
                                   freeWhenDone:NO];
    NSString *b64chunk = [chunk base64EncodedStringWithOptions:0];
    IWFilePacketWithTabletInfo *filePacket = [[IWFilePacketWithTabletInfo alloc] initWithNamespace:NAMESPACE];
    filePacket.Username = sendingTransaction.Username;
    filePacket.Password = sendingTransaction.HashedPassword;
    filePacket.TabletId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    filePacket.PacketIndex = [NSNumber numberWithInt:nextSendingChunk];
    filePacket.FilePacketdata = b64chunk;

    NSString *functionName = @"SendFilePacketWithTablet";
    NSMutableURLRequest *request = [self getRequestWithFunctionName:functionName andObject:filePacket];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (error != nil) {
                                   NSLog(@"%@", error.localizedDescription);
                                   if (delegate!=nil) {
                                       [delegate formSendingError:sendingTransaction error:error.localizedDescription];
                                   }
                                   return;
                               }
                               if (((NSHTTPURLResponse *)response).statusCode == 404) {
                                   if (delegate != nil) {
                                       [delegate formSendingError:sendingTransaction error:@"404"];
                                   }
                                   return;
                               }
                               NSError *err;
                               TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
                               TBXMLElement *root = [xmlFile rootXMLElement];
                               
                               IWDestinyChunkResponseMessage *resp;
                               
                               if ([[TBXML elementName:root] rangeOfString:@"Envelope"].location != NSNotFound) {
                                   //envelope found
                                   TBXMLElement *child = root->firstChild;
                                   while (child) {
                                       
                                       if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                                           //body found
                                           
                                           TBXMLElement *destResp = child->firstChild;
                                           
                                           while (destResp) {
                                               if ([[TBXML elementName:destResp] isEqualToString:@"DestinyChunkResponseMessage"]) {
                                                   //destchunk found
                                                   
                                                   resp = [[IWDestinyChunkResponseMessage alloc] initWithNamespace:NAMESPACE andXml:destResp];
                                                   
                                                   if ([resp.Errorcode intValue] == 0) {
                                                       if ([resp.NextExpectedChunk intValue] > -1 && [resp.NextExpectedChunk intValue] < [fileDesc.MaxPacketCount intValue]) {
                                                           //next chunk
                                                           nextSendingChunk = [resp.NextExpectedChunk intValue];
                                                           [self sendNextChunk];
                                                       } else {
                                                           //finished file...
                                                           [self finalizeCurrentFile];
                                                       }
                                                   } else {
                                                       NSLog(@"Error code %@: %@", resp.Errorcode, resp.Message);
                                                       if (delegate != nil) {
                                                           [delegate formSendingError:sendingTransaction error:resp.Message];
                                                       }
                                                   }
                                                   
                                                   break;
                                               }
                                               
                                               destResp = destResp->nextSibling;
                                           }
                                           
                                           break;
                                       }
                                       
                                       child = child->nextSibling;
                                   }
                               }
                           }];
    
}

- (void) sendNextChunkSecure {
    NSUInteger length = [fileData length];
    NSUInteger offset = nextSendingChunk * [CHUNK_SIZE intValue];
    
    NSUInteger thisChunkSize = length - offset > [CHUNK_SIZE intValue] ? [CHUNK_SIZE intValue] : length - offset;
    
    NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[fileData bytes] + offset
                                         length:thisChunkSize
                                   freeWhenDone:NO];
    NSString *b64chunk = [chunk base64EncodedStringWithOptions:0];
//    IWFilePacketWithTabletInfo *filePacket = [[IWFilePacketWithTabletInfo alloc] initWithNamespace:NAMESPACE];
//    filePacket.Username = sendingTransaction.username;
//    filePacket.Password = sendingTransaction.hashedPassword;
//    filePacket.TabletId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    filePacket.PacketIndex = [NSNumber numberWithInt:nextSendingChunk];
//    filePacket.FilePacketdata = b64chunk;
    
    IWSendFilePacketWithTablet *packetData = [[IWSendFilePacketWithTablet alloc] initWithUserName:sendingTransaction.Username password:sendingTransaction.HashedPassword fileData:b64chunk packetIndex:nextSendingChunk];
    
    IWSendData *filePacket = [[IWSendData alloc] initWithNameSpace:DEST_NAMESPACE propNameSpace:DEST_NAMESPACE];
    
    filePacket.Date = [[IWInkworksService getInstance].encryptedDateFormatter stringFromDate:[NSDate new]];
    filePacket.Data = [IWInkworksService encrypt:[packetData GetXml] withKey:[IWInkworksService getCryptoKey:filePacket.Date]];
    
    //NSString *unenc = [packetData GetXml];
    
    NSString *functionName = @"SendData";
    NSMutableURLRequest *request = [self getSecureRequestWithFunctionName:functionName andObject:filePacket];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               if (error != nil) {
                                   NSLog(@"%@", error.localizedDescription);
                                   if (delegate!=nil) {
                                       [delegate formSendingError:sendingTransaction error:error.localizedDescription];
                                   }
                                   return;
                               }
                               if (((NSHTTPURLResponse *)response).statusCode == 404) {
                                   if (delegate != nil) {
                                       [delegate formSendingError:sendingTransaction error:@"404"];
                                   }
                                   return;
                               }
                               NSError *err;
                               TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
                               
                               if (err != nil) {
                                   if (delegate != nil) {
                                       [delegate formSendingError:sendingTransaction error:@"9111"];
                                   }
                                   return;
                               }
                               
                               TBXMLElement *root = [xmlFile rootXMLElement];
                               
                               IWDestinyResponse *resp;
                               
                               if ([[TBXML elementName:root] rangeOfString:@"Envelope"].location != NSNotFound) {
                                   //envelope found
                                   TBXMLElement *child = root->firstChild;
                                   while (child) {
                                       
                                       if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                                           //body found
                                           
                                           TBXMLElement *destResp = child->firstChild;
                                           
                                           while (destResp) {
                                               if ([[TBXML elementName:destResp] isEqualToString:@"DestRespMessage"]) {
                                                   //destchunk found
                                                   
                                                   resp = [[IWDestinyResponse alloc] initWithNamespace:NAMESPACE andXml:destResp];
                                                   NSString *decrypted = [IWInkworksService decrypt:resp.Data withKey:[IWInkworksService getCryptoKey:resp.Date]];
                                                   IWSecureResponse *secResp = [[IWSecureResponse alloc] initWithXml:decrypted];
                                                   
                                                   if (secResp.ErrorCode == 0) {
                                                       if (secResp.NextPacketId > -1 && secResp.NextPacketId < startSendDesc.MaxPackets) {
                                                           //next chunk
                                                           nextSendingChunk = secResp.NextPacketId;
                                                           [self sendNextChunkSecure];
                                                       } else {
                                                           //finished file...
                                                           [self finalizeCurrentFileSecure];
                                                       }
                                                   } else {
                                                       NSLog(@"Error code %ld: %@", (long)secResp.ErrorCode, secResp.Message);
                                                       if (delegate != nil) {
                                                           [delegate formSendingError:sendingTransaction error:secResp.Message];
                                                       }
                                                   }
                                                   
                                                   break;
                                               }
                                               
                                               destResp = destResp->nextSibling;
                                           }
                                           
                                           break;
                                       }
                                       
                                       child = child->nextSibling;
                                   }
                               }
                           }];
    
}


- (void) finalizeCurrentFileSecure {
    
    IWFinishSendFilePacketWithTablet *finish = [[IWFinishSendFilePacketWithTablet alloc] initWithUserName:startSendDesc.Username password:startSendDesc.PasswordHash fileName:startSendDesc.FileName maxPackets:startSendDesc.MaxPackets];
    
    IWSendData *send = [[IWSendData alloc] initWithNameSpace:DEST_NAMESPACE propNameSpace:DEST_NAMESPACE];
    send.Date = [[IWInkworksService getInstance].encryptedDateFormatter stringFromDate:[NSDate date]];
    send.Data = [IWInkworksService encrypt:[finish GetXml] withKey:[IWInkworksService getCryptoKey:send.Date]];
    
    NSMutableURLRequest *request = [self getSecureRequestWithFunctionName:@"SendData" andObject:send];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:error.localizedDescription];
                
            }
            return;
        }
        
        if (((NSHTTPURLResponse *)response).statusCode == 404) {
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:@"404"];
            }
            return;
        }
        NSError *err;
        TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
        
        if (err != nil) {
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:@"9111"];
            }
            return;
        }
        
        IWDestinyResponse *resp;
        TBXMLElement *root = [xmlFile rootXMLElement];
        if ([[TBXML elementName:root] rangeOfString:@"Envelope"].location != NSNotFound) {
            //found envelope...
            
            TBXMLElement *child = root->firstChild;
            while (child) {
                
                if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                    TBXMLElement *destResp = child->firstChild;
                    
                    while (destResp) {
                        if ([[TBXML elementName:destResp] isEqualToString:@"DestRespMessage"]) {
                            resp = [[IWDestinyResponse alloc] initWithNamespace:NAMESPACE andXml:destResp];
                            
                            NSString *decrypted = [IWInkworksService decrypt:resp.Data withKey:[IWInkworksService getCryptoKey:resp.Date]];
                            IWSecureResponse *secResp = [[IWSecureResponse alloc] initWithXml:decrypted];
                            if (secResp.ErrorCode == 0) {
                                [filesSent setObject:[NSDate date] forKey:startSendDesc.FileName];
                                IWAttachedPhoto *photo = photoList[currentSendingImage];
                                
                                photo.ImageStatus = STATUS_SENT;
                                
                                [[IWInkworksService dbHelper] addOrUpdatePhoto:photo];
                                
                                currentSendingImage ++;
                                if (currentSendingImage > photoList.count - 1) {
                                    // all photos done...
                                    [self sendSecureTransactionInfo];
                                } else {
                                    //send next photo
                                    [self sendNextPhotoSecure];
                                }
                            } else {
                                NSLog(@"Error code %ld: %@", (long)secResp.ErrorCode, secResp.Message);
                                if (delegate != nil) {
                                    [delegate formSendingError:sendingTransaction error:secResp.Message];
                                }
                                
                            }
                            break;
                        }
                        
                        destResp = destResp -> nextSibling;
                    }
                    break;
                }
                
                child = child->nextSibling;
            }
        }
    }];
}


- (void) finalizeCurrentFile {
    NSMutableURLRequest *request = [self getRequestWithFunctionName:@"FinishSendFilePacketWithTablet" andObject:fileDesc];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:error.localizedDescription];
                
            }
            return;
        }
        
        if (((NSHTTPURLResponse *)response).statusCode == 404) {
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:@"404"];
            }
            return;
        }
        NSError *err;
        TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
        IWDestinyChunkResponseMessage *resp;
        TBXMLElement *root = [xmlFile rootXMLElement];
        if ([[TBXML elementName:root] rangeOfString:@"Envelope"].location != NSNotFound) {
            //found envelope...
            
            TBXMLElement *child = root->firstChild;
            while (child) {
                
                if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                    TBXMLElement *destResp = child->firstChild;
                    
                    while (destResp) {
                        if ([[TBXML elementName:destResp] isEqualToString:@"DestinyChunkResponseMessage"]) {
                            resp = [[IWDestinyChunkResponseMessage alloc] initWithNamespace:NAMESPACE andXml:destResp];
                            if ([resp.Errorcode intValue] == 0) {
                                [filesSent setObject:[NSDate date] forKey:fileDesc.Filename];
                                IWAttachedPhoto *photo = photoList[currentSendingImage];
                                
                                photo.imageStatus = STATUS_SENT;
                                
                                [[IWInkworksService dbHelper] addOrUpdatePhoto:photo];
                                
                                currentSendingImage ++;
                                if (currentSendingImage > photoList.count - 1) {
                                    // all photos done...
                                    [self sendTransactionInfo];
                                } else {
                                    //send next photo
                                    [self sendNextPhoto];
                                }
                            } else {
                                NSLog(@"Error code %@: %@", resp.Errorcode, resp.Message);
                                if (delegate != nil) {
                                    [delegate formSendingError:sendingTransaction error:resp.Message];
                                }
                                
                            }
                            break;
                        }
                        
                        destResp = destResp -> nextSibling;
                    }
                    break;
                }
                
                child = child->nextSibling;
            }
        }
    }];
}


- (NSMutableURLRequest *) getRequestWithFunctionName: (NSString *) functionName andObject:(NSObject *) object {
    return [self getRequestWithFunctionName:functionName andObject:object serviceRequest:NO];
}

- (NSMutableURLRequest *) getRequestWithFunctionName: (NSString *) functionName andObject:(NSObject *) object serviceRequest:(BOOL)service{
    NSString *sendXml = [IWDestFormService getXmlStringWithName:functionName andObject:object andUrl:connURL serviceReq:service];
    NSURL *url = [NSURL URLWithString: connURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                            timeoutInterval:60];
    NSString *requestLen = [NSString stringWithFormat:@"%lu", (long unsigned)sendXml.length];
    [request addValue:[url host] forHTTPHeaderField:@"Host"];
    [request addValue:[NSString stringWithFormat:@"%@%@/%@", NAMESPACE, service?@"IServiceCenterService":@"IDestFormService", functionName] forHTTPHeaderField:@"SOAPAction"];
    [request addValue:@"application/soap+xml" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/soap+xml" forHTTPHeaderField:@"Accept"];
    [request addValue:requestLen forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[sendXml dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (NSMutableURLRequest *) getSecureRequestWithFunctionName: (NSString *) functionName andObject:(NSObject *) object {
    return [self getSecureRequestWithFunctionName:functionName andObject:object serviceRequest:NO];
}

- (NSMutableURLRequest *) getSecureRequestWithFunctionName: (NSString *) functionName andObject:(NSObject *) object serviceRequest:(BOOL)service{
    NSString *sendXml = [IWDestFormService getSecureXmlStringWithName:functionName andObject:object andUrl:connURL serviceReq:service];
    NSURL *url = [NSURL URLWithString: connURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                            timeoutInterval:60];
    NSString *requestLen = [NSString stringWithFormat:@"%lu", (long unsigned)sendXml.length];
    [request addValue:[url host] forHTTPHeaderField:@"Host"];
    [request addValue:[NSString stringWithFormat:@"%@%@/%@", DEST_NAMESPACE, service?@"ISvcCenterSecService":@"IDestFormServiceSec", functionName] forHTTPHeaderField:@"SOAPAction"];
    [request addValue:@"application/soap+xml" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/soap+xml" forHTTPHeaderField:@"Accept"];
    [request addValue:requestLen forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[sendXml dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

+ (NSString *) getTransactionXmlWithFiles: (NSMutableDictionary *) sentFiles andStartedDate:(NSDate *)started andSentDate: (NSDate *) date andGPS: (IWGPSUnit *) gpsUnit andPrepopId:(int) prepopId {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    NSMutableString *s = [NSMutableString string];
    
    [s appendString: @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"];
    [s appendString: @"<dtran xmlns=\"http://destiny.com/xml/routertrans\">\n"];
    [s appendString: @"  <form>\n"];
    [s appendString: @"    <formtran id=\"1\""];
    if (prepopId != -1) {
        [s appendString:[NSString stringWithFormat:@" prepopkey=\"%lu\"", (long unsigned)prepopId]];
    }
    [s appendString:@">\n"];
    [s appendString: @"      <files>\n"];
    for (NSString *key in sentFiles.keyEnumerator) {
        [s appendString:[NSString stringWithFormat:@"        <att filename=\"%@\" type=\"img\" sendtime=\"%@\" />\n", key, [formatter stringFromDate:[sentFiles objectForKey:key]] ]];
    }
    [s appendString:@"      </files>\n"];
    [s appendString:@"    </formtran>\n"];
    [s appendString:[NSString stringWithFormat:@"    <pgc filename=\"filename1\" recvtime=\"%@\" sendtime=\"%@\" />\n", [formatter stringFromDate:started], [formatter stringFromDate:date]]];
    if (gpsUnit != nil) {
        [s appendString:[NSString stringWithFormat:@"    <gpsloc acc=\"gps\" long=\"%f\" lat=\"%f\" alt=\"%f\" time=\"%@\" />\n", [gpsUnit.longitude floatValue], [gpsUnit.latitude floatValue], [gpsUnit.altitude floatValue], [formatter stringFromDate:gpsUnit.dateStamp]]];
    }
    [s appendString:@"  </form>\n" ];
    [s appendString:@"</dtran>\n"];
    return s;
}



+ (NSString *) getXmlStringWithName: (NSString *) name andObject: (NSObject *)obj andUrl:(NSString *)url serviceReq:(BOOL) serv {
    NSMutableString *ret = [NSMutableString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<v:Envelope xmlns:v=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:c=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:d=\"http://www.w3.org/2001/XMLSchema\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">\n    <v:Header>\n        <n0:Action xmlns:n0=\"http://www.w3.org/2005/08/addressing\">http://tempuri.org/%@/%@</n0:Action>\n        <n1:To xmlns:n1=\"http://www.w3.org/2005/08/addressing\">%@</n1:To>\n    </v:Header>\n    <v:Body>\n",serv ? @"IServiceCenterService" : @"IDestFormService", name, url];
    if ([obj isKindOfClass:[IWDestFormObject class]]) {
        [ret appendString:[(IWDestFormObject *)obj getXml]];
    }
    else {
        [ret appendString:[(IWSvcGetUserPrepopDataRequest *)obj GetXml]];
    }
    
    
    [ret appendString:@"    </v:Body>\n</v:Envelope>"];
    return ret;
}

+ (NSString *) getSecureXmlStringWithName: (NSString *) name andObject: (NSObject *)obj andUrl:(NSString *)url serviceReq:(BOOL) serv {
    NSMutableString *ret = [NSMutableString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<v:Envelope xmlns:v=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:c=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:d=\"http://www.w3.org/2001/XMLSchema\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">\n    <v:Header>\n        <n0:Action xmlns:n0=\"http://www.w3.org/2005/08/addressing\">http://destinywireless.com/%@/%@</n0:Action>\n        <n1:To xmlns:n1=\"http://www.w3.org/2005/08/addressing\">%@</n1:To>\n    </v:Header>\n    <v:Body>\n",serv ? @"ISvcCenterSecService" : @"IDestFormServiceSec", name, url];
    if ([obj isKindOfClass:[IWDestFormObject class]]) {
        [ret appendString:[(IWDestFormObject *)obj getXml]];
    }
    else {
        [ret appendString:[(IWSvcGetUserPrepopDataRequest *)obj GetXml]];
    }
    
    
    [ret appendString:@"    </v:Body>\n</v:Envelope>"];
    return ret;
}

#pragma mark Login

- (void)login:(NSString *)username password:(NSString *)password {
    IWFileDescriptionWithTabletInfo *loginDesc = [[IWFileDescriptionWithTabletInfo alloc] initWithNamespace:NAMESPACE];
    
    loginDesc.UserName = username;
    loginDesc.PassWord = password;
    loginDesc.TabletId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    loginDesc.Filename = @"";
    loginDesc.Filedata = @"";
    NSMutableURLRequest *request = [self getRequestWithFunctionName:@"ValidateTablet" andObject:loginDesc];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            if (delegate != nil) {
                [delegate loginComplete:loginDesc completion:nil status:2];
            }
            return;
        }
        
        if (((NSHTTPURLResponse *)response).statusCode == 404) {
            if (delegate != nil) {
                [delegate loginComplete:loginDesc completion:nil status:1];
            }
            return;
        }
        
        NSError *err;
        TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
        
        
        TBXMLElement *elem = [xmlFile rootXMLElement];
        
        IWDestinyResponse *resp;
        if ([[TBXML elementName:elem] rangeOfString:@"Envelope"].location != NSNotFound) {
            NSLog (@"%@", @"Envelope found");
            TBXMLElement *child = elem->firstChild;
            while (child) {
                if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                    TBXMLElement *destRespX = child->firstChild;
                    while (destRespX) {
                        if ([[TBXML elementName:destRespX] isEqualToString:@"DestinyResponseMessage"]){
                            //found destchunk
                            resp = [[IWDestinyResponse alloc] initWithNamespace:NAMESPACE andXml:destRespX];
                                
                            if (delegate != nil) {
                                [delegate loginComplete:loginDesc completion:resp status:0];
                            }
                        }
                        
                        destRespX = destRespX->nextSibling;
                    }
                }
                child = child->nextSibling;
            }
        }

        
        
    }];
}

- (void)secureLogin:(NSString *)username password:(NSString *)password {
    IWSendData *loginDesc = [[IWSendData alloc] initWithNameSpace:DEST_NAMESPACE propNameSpace:DEST_NAMESPACE];
    
    IWValidateTablet *validate = [[IWValidateTablet alloc] initWithUserName:username password:password];
    //NSString *unencrypted = [validate GetXml];
    loginDesc.Date = [[IWInkworksService getInstance].encryptedDateFormatter stringFromDate:[NSDate new]];
    
    loginDesc.Data = [IWInkworksService encrypt:[validate GetXml] withKey:[IWInkworksService getCryptoKey:loginDesc.Date]];
    
    
    NSMutableURLRequest *request = [self getSecureRequestWithFunctionName:@"SendData" andObject:loginDesc];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    //NSURLSessionConfiguration *conf = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"INKWRX"];
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:conf];
    //[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            if (delegate != nil) {
                [delegate loginComplete:loginDesc completion:nil status:2];
            }
            return;
        }
        
        if (((NSHTTPURLResponse *)response).statusCode == 404) {
            if (delegate != nil) {
                [delegate loginComplete:loginDesc completion:nil status:1];
            }
            return;
        }
        
        NSError *err;
        TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
        if (err != nil) {
            if (delegate != nil) {
                [delegate loginComplete:loginDesc completion:nil status:3];
            }
            return;
        }
        
        TBXMLElement *elem = [xmlFile rootXMLElement];
        
        IWDestinyResponse *resp;
        if ([[TBXML elementName:elem] rangeOfString:@"Envelope"].location != NSNotFound) {
            NSLog (@"%@", @"Envelope found");
            TBXMLElement *child = elem->firstChild;
            while (child) {
                if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                    TBXMLElement *destRespX = child->firstChild;
                    while (destRespX) {
                        if ([[TBXML elementName:destRespX] isEqualToString:@"DestRespMessage"]){
                            //found destchunk
                            resp = [[IWDestinyResponse alloc] initWithNamespace:DEST_NAMESPACE andXml:destRespX];
                            
                            if (delegate != nil) {
                                [delegate loginComplete:loginDesc completion:resp status:0];
                            }
                        }
                        
                        destRespX = destRespX->nextSibling;
                    }
                }
                child = child->nextSibling;
            }
        }
        
        
        
    }];
}


#pragma mark Prepop

- (void) getPrepopForms {
    IWSvcGetUserPrepopDataRequest *obj = [[IWSvcGetUserPrepopDataRequest alloc] initWithNameSpace:SERVICE_NAMESPACE propNameSpace:NAMESPACE];
    IWSavedSettings *versionSetting = [[IWInkworksService dbHelper] getSetting:[NSString stringWithFormat:@"%@_PREPOP_VERSION", [IWInkworksService getInstance].loggedInUser]];
    NSString *versionString = @"-1";
    if (versionSetting) {
        versionString = versionSetting.SettingValue;
    }
    int versionNumber = [versionString intValue];
    obj.CurrentVersion = versionNumber;
    obj.UserName = [IWInkworksService getInstance].loggedInUser;
    obj.Password = [IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword];
    NSMutableURLRequest *request = [self getRequestWithFunctionName:@"GetEformPrepopDataForUser" andObject:obj serviceRequest:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:error.localizedDescription];
                
            }
            return;
        }
        
        if (((NSHTTPURLResponse *)response).statusCode == 404) {
            if (delegate != nil) {
                [delegate formSendingError:sendingTransaction error:@"404"];
            }
            return;
        }
        NSError *err;
        TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
        IWSvcGetUserPrepopDataResponse *resp;
        TBXMLElement *root = [xmlFile rootXMLElement];
        if ([[TBXML elementName:root] rangeOfString:@"Envelope"].location != NSNotFound) {
            //found envelope...
            
            TBXMLElement *child = root->firstChild;
            while (child) {
                
                if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                    TBXMLElement *destResp = child->firstChild;
                    
                    while (destResp) {
                        if ([[TBXML elementName:destResp] isEqualToString:@"SvcGetUserPrepopDataResponse"]) {
                            resp = [[IWSvcGetUserPrepopDataResponse alloc] initWithNameSpace:NAMESPACE];
                            
                            TBXMLElement *versionElem = [TBXML childElementNamed:@"VersionNumber" parentElement:destResp];
                            TBXMLElement *dataElem = [TBXML childElementNamed:@"Data" parentElement:destResp];
                            TBXMLElement *resultElem = [TBXML childElementNamed:@"ResultCode" parentElement:destResp];
                            TBXMLElement *messageElem = [TBXML childElementNamed:@"Message" parentElement:destResp];
                            int version = -1;
                            NSString *data = @"";
                            int resultCode = -1;
                            NSString *message = @"";
                            if (versionElem != nil) {
                                version = [[TBXML textForElement:versionElem] intValue];
                            }
                            if (dataElem != nil) {
                                data = [[[[TBXML textForElement:dataElem] stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"] stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"] stringByReplacingOccurrencesOfString:@"&#xD;" withString:@""];
                            }
                            if (resultElem != nil) {
                                resultCode = [[TBXML textForElement:resultElem] intValue];
                            }
                            if (messageElem != nil) {
                                message = [TBXML textForElement:messageElem];
                            }
                            
                            resp.VersionNumber = version;
                            resp.Data = data;
                            resp.ResultCode = resultCode;
                            resp.Message = message;
                            
                            if (resp.ResultCode == 0) {
                                NSString *data = resp.Data;
                                
                                
                                
                                [IWPrepopXmlHandler HandleXML:data newVersion:resp.VersionNumber];
                                
                                //update version number
                                [[IWInkworksService dbHelper] saveSetting:[NSString stringWithFormat:@"%@_PREPOP_VERSION", [IWInkworksService getInstance].loggedInUser] value:[NSString stringWithFormat:@"%lu", (long unsigned)resp.VersionNumber]];
//                                if ([IWInkworksService getInstance].homeInstance) {
//                                    [(IWHomeController *)[IWInkworksService getInstance].homeInstance refreshIndicators];
//                                }
                            } else {
                                NSLog(@"Error code %lu: %@", (long unsigned)resp.ResultCode, resp.Message);
                                if (delegate != nil) {
                                    [delegate formSendingError:sendingTransaction error:resp.Message];
                                }
                                
                            }
                            break;
                        }
                        
                        destResp = destResp -> nextSibling;
                    }
                    break;
                }
                
                child = child->nextSibling;
            }
        }
    }];
}

- (void) getPrepopFormsSecure {
    //IWSvcGetUserPrepopDataRequest *obj = [[IWSvcGetUserPrepopDataRequest alloc] initWithNameSpace:SERVICE_NAMESPACE propNameSpace:NAMESPACE];
    IWSavedSettings *versionSetting = [[IWInkworksService dbHelper] getSetting:[NSString stringWithFormat:@"%@_PREPOP_VERSION", [IWInkworksService getInstance].loggedInUser]];
    NSString *versionString = @"-1";
    if (versionSetting) {
        versionString = versionSetting.SettingValue;
    }
    int versionNumber = [versionString intValue];
//    obj.CurrentVersion = versionNumber;
//    obj.UserName = [IWInkworksService getInstance].loggedInUser;
//    obj.Password = [IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword];
    
    IWGetEformPrepopDataForUser *prepopReq = [[IWGetEformPrepopDataForUser alloc] initWithUserName:[IWInkworksService getInstance].loggedInUser password:[IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword] currVer:versionNumber];
    
    IWSendData *obj = [[IWSendData alloc] initWithNameSpace:DEST_NAMESPACE propNameSpace:DEST_NAMESPACE];
    //NSString *unenc = [prepopReq GetXml];
    obj.Date = [[IWInkworksService getInstance].encryptedDateFormatter stringFromDate:[NSDate new]];
    obj.Data = [IWInkworksService encrypt:[prepopReq GetXml] withKey:[IWInkworksService getCryptoKey:obj.Date]];
    
    NSMutableURLRequest *request = [self getSecureRequestWithFunctionName:@"SendData" andObject:obj serviceRequest:YES];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            if (delegate != nil) {
                //[delegate formSendingError:sendingTransaction error:error.localizedDescription];
                
            }
            [IWInkworksService getInstance].webserviceError = YES;
            [IWInkworksService getInstance].isRefreshing = NO;
            __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
            if (main) {
                [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            }
            return;
        }
        
        if (((NSHTTPURLResponse *)response).statusCode == 404) {
            if (delegate != nil) {
                //[delegate formSendingError:sendingTransaction error:@"404"];
                
            }
            [IWInkworksService getInstance].webserviceError = YES;
            [IWInkworksService getInstance].isRefreshing = NO;
            __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
            if (main) {
                [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            }
            return;
        }
        NSError *err;
        TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
        if (err != nil) {
            if (delegate != nil) {
                
            }
            [IWInkworksService getInstance].webserviceError = YES;
            [IWInkworksService getInstance].isRefreshing = NO;
            __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
            if (main) {
                [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            }
            return;
        }
        IWDestinyResponse *resp;
        TBXMLElement *root = [xmlFile rootXMLElement];
        if ([[TBXML elementName:root] rangeOfString:@"Envelope"].location != NSNotFound) {
            //found envelope...
            
            TBXMLElement *child = root->firstChild;
            while (child) {
                
                if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                    TBXMLElement *destResp = child->firstChild;
                    
                    while (destResp) {
                        if ([[TBXML elementName:destResp] isEqualToString:@"DestRespMessage"]) {
                            resp = [[IWDestinyResponse alloc] initWithNamespace:DEST_NAMESPACE andXml:destResp];
                            
                            NSString *decrypted = [IWInkworksService decrypt:resp.Data withKey:[IWInkworksService getCryptoKey:resp.Date]];
                            IWSecureResponse *secResp = [[IWSecureResponse alloc] initWithXml:decrypted];
                            
                            secResp.PrepopData = [[[secResp.PrepopData stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"] stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"] stringByReplacingOccurrencesOfString:@"&#xD;" withString:@""];
                            
                            if (secResp.ErrorCode == 0) {
                                NSString *data = secResp.PrepopData;
                                
                                
                                
                                [IWPrepopXmlHandler HandleXML:data newVersion:secResp.PrepopVersion];
                                
                                //update version number
                                [[IWInkworksService dbHelper] saveSetting:[NSString stringWithFormat:@"%@_PREPOP_VERSION", [IWInkworksService getInstance].loggedInUser] value:[NSString stringWithFormat:@"%lu", (long unsigned)secResp.PrepopVersion]];
                                //                                if ([IWInkworksService getInstance].homeInstance) {
                                //                                    [(IWHomeController *)[IWInkworksService getInstance].homeInstance refreshIndicators];
                                //                                }
                            } else {
                                NSLog(@"Error code %lu: %@", (long unsigned)secResp.ErrorCode, secResp.Message);
                                if (delegate != nil) {
                                    //[delegate formSendingError:sendingTransaction error:secResp.Message];
                                    
                                }
                                [IWInkworksService getInstance].webserviceError = YES;
                                [IWInkworksService getInstance].isRefreshing = NO;
                                __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
                                if (main) {
                                    [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                                    [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                                }
                                
                            }
                            break;
                        }
                        
                        destResp = destResp -> nextSibling;
                    }
                    break;
                }
                
                child = child->nextSibling;
            }
        }
    }];
}

- (void) getEFormsSecure {
    //IWSvcGetUserPrepopDataRequest *obj = [[IWSvcGetUserPrepopDataRequest alloc] initWithNameSpace:SERVICE_NAMESPACE propNameSpace:NAMESPACE];
    
    
    IWGetEforms *req = [[IWGetEforms alloc] initWithUserName:[IWInkworksService getInstance].loggedInUser password:[IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword]];
    
    
    IWSendData *obj = [[IWSendData alloc] initWithNameSpace:DEST_NAMESPACE propNameSpace:DEST_NAMESPACE];
    //NSString *unenc = [prepopReq GetXml];
    obj.Date = [[IWInkworksService getInstance].encryptedDateFormatter stringFromDate:[NSDate new]];
    obj.Data = [IWInkworksService encrypt:[req GetXml] withKey:[IWInkworksService getCryptoKey:obj.Date]];
    
    NSMutableURLRequest *request = [self getSecureRequestWithFunctionName:@"SendData" andObject:obj serviceRequest:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            if (delegate != nil) {
                //[delegate formSendingError:sendingTransaction error:error.localizedDescription];
                

            }
            [IWInkworksService getInstance].webserviceError = YES;
            [IWInkworksService getInstance].isRefreshing = NO;
            __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
            if (main) {
                [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            }
            return;
        }
        
        if (((NSHTTPURLResponse *)response).statusCode == 404) {
            if (delegate != nil) {
                //[delegate formSendingError:sendingTransaction error:@"404"];
                
            }
            [IWInkworksService getInstance].webserviceError = YES;
            [IWInkworksService getInstance].isRefreshing = NO;
            __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
            if (main) {
                [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            }
            return;
        }
        NSError *err;
        TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
        if (err != nil) {
            if (delegate != nil) {
                //[delegate formSendingError:sendingTransaction error:@"9111"];
            }
            [IWInkworksService getInstance].webserviceError = YES;
            [IWInkworksService getInstance].isRefreshing = NO;
            __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
            if (main) {
                [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            }
            return;
        }
        IWDestinyResponse *resp;
        TBXMLElement *root = [xmlFile rootXMLElement];
        if ([[TBXML elementName:root] rangeOfString:@"Envelope"].location != NSNotFound) {
            //found envelope...
            
            TBXMLElement *child = root->firstChild;
            while (child) {
                
                if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                    TBXMLElement *destResp = child->firstChild;
                    
                    while (destResp) {
                        if ([[TBXML elementName:destResp] isEqualToString:@"DestRespMessage"]) {
                            resp = [[IWDestinyResponse alloc] initWithNamespace:DEST_NAMESPACE andXml:destResp];
                            
                            NSString *decrypted = [IWInkworksService decrypt:resp.Data withKey:[IWInkworksService getCryptoKey:resp.Date]];
                            IWSecureResponse *secResp = [[IWSecureResponse alloc] initWithXml:decrypted];
                            
                            if (secResp.ErrorCode == 0) {
                                NSString *data = secResp.PrepopData;
                                
                                
                                
                                [IWGetEformsXmlHandler HandleXML:data];
                                
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    
                                    
                                    [self getPrepopFormsSecure];
                                    
                                });
                            } else {
                                NSLog(@"Error code %lu: %@", (long unsigned)secResp.ErrorCode, secResp.Message);
                                if (delegate != nil) {
                                    //[delegate formSendingError:sendingTransaction error:secResp.Message];
                                }
                                [IWInkworksService getInstance].webserviceError = YES;
                                [IWInkworksService getInstance].isRefreshing = NO;
                                __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
                                if (main) {
                                    [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                                    [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                                }
                            }
                            break;
                        }
                        
                        destResp = destResp -> nextSibling;
                    }
                    break;
                }
                
                child = child->nextSibling;
            }
        }
    }];
}

- (void) getZipFormsSecure:(int) appKey {
    //IWSvcGetUserPrepopDataRequest *obj = [[IWSvcGetUserPrepopDataRequest alloc] initWithNameSpace:SERVICE_NAMESPACE propNameSpace:NAMESPACE];
    
    
    IWGetZipFormSecure *req = [[IWGetZipFormSecure alloc] initWithUserName:[IWInkworksService getInstance].loggedInUser password:[IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword] appId:appKey];
    NSLog(@"%@", [req GetXml]);
    
    IWSendData *obj = [[IWSendData alloc] initWithNameSpace:DEST_NAMESPACE propNameSpace:DEST_NAMESPACE];
    //NSString *unenc = [prepopReq GetXml];
    obj.Date = [[IWInkworksService getInstance].encryptedDateFormatter stringFromDate:[NSDate new]];
    obj.Data = [IWInkworksService encrypt:[req GetXml] withKey:[IWInkworksService getCryptoKey:obj.Date]];
    //NSString *unenc = [req GetXml];
    NSMutableURLRequest *request = [self getSecureRequestWithFunctionName:@"SendData" andObject:obj serviceRequest:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            if (delegate != nil) {
                //[delegate formSendingError:sendingTransaction error:error.localizedDescription];
                
            }
            [IWInkworksService getInstance].webserviceError = YES;
            
            [IWInkworksService getInstance].isRefreshing = NO;
            __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
            if (main) {
                [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            }
            return;
        }
        
        if (((NSHTTPURLResponse *)response).statusCode == 404) {
            if (delegate != nil) {
                //[delegate formSendingError:sendingTransaction error:@"404"];
                
            }
            [IWInkworksService getInstance].webserviceError = YES;
            [IWInkworksService getInstance].isRefreshing = NO;
            __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
            if (main) {
                [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            }
            return;
        }
        NSError *err;
        TBXML *xmlFile = [[TBXML alloc] initWithXMLData:data error:&err];
        if (err != nil) {
            if (delegate != nil) {
                //[delegate formSendingError:sendingTransaction error:@"9111"];
            }
            [IWInkworksService getInstance].webserviceError = YES;
            [IWInkworksService getInstance].isRefreshing = NO;
            __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
            if (main) {
                [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            }
            return;
        }
        IWDestinyResponse *resp;
        TBXMLElement *root = [xmlFile rootXMLElement];
        if ([[TBXML elementName:root] rangeOfString:@"Envelope"].location != NSNotFound) {
            //found envelope...
            
            TBXMLElement *child = root->firstChild;
            while (child) {
                
                if ([[TBXML elementName:child] rangeOfString:@"Body"].location != NSNotFound) {
                    TBXMLElement *destResp = child->firstChild;
                    
                    while (destResp) {
                        if ([[TBXML elementName:destResp] isEqualToString:@"DestRespMessage"]) {
                            resp = [[IWDestinyResponse alloc] initWithNamespace:DEST_NAMESPACE andXml:destResp];
                            
                            NSString *decrypted = [IWInkworksService decrypt:resp.Data withKey:[IWInkworksService getCryptoKey:resp.Date]];
                            IWSecureResponse *secResp = [[IWSecureResponse alloc] initWithXml:decrypted];
                            
                            if (secResp.ErrorCode == 0) {
                                
                                if (delegate != nil) {
                                    [delegate getZipFormSecureDownloaded:req completion:resp];
                                }
                                
                            } else {
                                NSLog(@"Error code %lu: %@", (long unsigned)secResp.ErrorCode, secResp.Message);
                                if (delegate != nil) {
                                    //[delegate formSendingError:sendingTransaction error:secResp.Message];
                                }
                                [IWInkworksService getInstance].webserviceError = YES;
                                [IWInkworksService getInstance].isRefreshing = NO;
                                __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
                                if (main) {
                                    [main performSelectorOnMainThread:@selector(resetButtons) withObject:nil waitUntilDone:YES];
                                    [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                                }
                            }
                            break;
                        }
                        
                        destResp = destResp -> nextSibling;
                    }
                    break;
                }
                
                child = child->nextSibling;
            }
        }
    }];
}


@end
