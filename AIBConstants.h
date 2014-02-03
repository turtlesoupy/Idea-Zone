//
// Created by Thomas Dimson on 12/24/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AIBMakeRange(start, end) (NSMakeRange((start), (end) - (start)))
#define AIBAssignErrorPtr(ptr, error) if((ptr)) { *(ptr) = (error); }
#define AIBReturnVoidIfErrorPtr(ptr, error) if((error)) { if((ptr)) { *(ptr) = (error); } return; }
#define AIBReturnIfErrorPtr(ptr, error, retval) if((error)) { if((ptr)) { *(ptr) = (error); } return (retval); }

extern NSString * const kAIBDropboxApiKey;
extern NSString * const kAIBDropboxApiSecret;
extern NSString * const kAIBTestflightApiKey;
extern NSString * const kAIBDropboxOpenURLOccurred;
extern NSString * const kAIBCrashlyticsKey;
extern NSString * const kAIBAppStoreId;

@interface AIBConstants : NSObject
@end