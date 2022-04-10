//
//  IWWebServiceHelper.h
//  Inkworks
//
//  Created by Jamie Duggan on 12/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormDataWSProxy.h"

@interface IWWebServiceHelper : NSObject <Wsdl2CodeProxyDelegate> {
    FormDataWSProxy *service;
}

@property (nonatomic, retain) FormDataWSProxy *service;




@end
