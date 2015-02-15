//
// Created by Thomas Dimson on 12/28/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (AIBFormatting)
- (NSString *)formatWithString:(NSString *)format;
- (NSString *)formatWithStyle:(NSDateFormatterStyle)style;
- (NSString *)distanceOfTimeInWords;
- (NSString *)distanceOfTimeInWords:(NSDate *)date;
@end