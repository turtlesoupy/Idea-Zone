//
// Created by Thomas Dimson on 12/29/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AIBIdea.h"
#import "AIBIdeaComment.h"
#import "AIBIdeaDescriptor.h"
#import "AIBConstants.h"
#import "AIBIdeaZoneManager.h"
#import <Dropbox/Dropbox.h>


@implementation AIBIdea {
}

- (id) initWithText:(NSString *)text {
    if((self = [super init]))  {
        _text = text;
        _comments = [[NSMutableArray alloc] init];
        _author = @"Unknown";
    }

    return self;
}

- (id) initFromDocument:(NSString *)document descriptor:(AIBIdeaDescriptor *)descriptor {
    if((self = [super init])) {
        _comments = [[NSMutableArray alloc] init];
        _descriptor = descriptor;
        _author = @"Unknown";


        NSError *error = NULL;
        NSRegularExpression *specialMatcher = [NSRegularExpression regularExpressionWithPattern:@"\\s*##\\s(Context|Comment\\s+by\\s+(.*))"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];

        NSArray *matches = [specialMatcher matchesInString:document
                                          options:0
                                            range:NSMakeRange(0, [document length])];
        if ([matches count] == 0) {
            _text =  [document stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        } else {
            _text = [[document substringToIndex:((NSTextCheckingResult *) matches[0]).range.location]
                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            for(NSUInteger i = 0 ; i < [matches count]; i++) {
                NSTextCheckingResult *match = matches[i];
                NSUInteger nextLocation;
                if(i == [matches count] - 1) {
                    nextLocation = [document length];
                } else {
                    nextLocation = ((NSTextCheckingResult *)matches[i+1]).range.location;
                }

                NSString *type = [document substringWithRange:[match rangeAtIndex:1]];
                if([[type lowercaseString] hasPrefix:@"context"]) {
                    NSString *context = [document substringWithRange:AIBMakeRange(match.range.location + match.range.length, nextLocation)];
                    NSRegularExpression *locationMatcher = [NSRegularExpression
                            regularExpressionWithPattern:@"\\s*Location\\s*:\\s*(?:(.*?)\\s*@)?\\s*([-+]?[0-9]*\\.?[0-9]+)\\s*,\\s*([-+]?[0-9]*\\.?[0-9]+)\\s*$"
                                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                                      error:&error];
                    NSTextCheckingResult *locationCheck = [locationMatcher firstMatchInString:context options:0 range:NSMakeRange(0, [context length])];
                    if(locationCheck) {
                        if(!NSEqualRanges([locationCheck rangeAtIndex:1], NSMakeRange(NSNotFound, 0))) {
                            _coordinateName = [context substringWithRange:[locationCheck rangeAtIndex:1]];
                        }

                        NSString *latStr = [context substringWithRange:[locationCheck rangeAtIndex:2]];
                        NSString *lngStr = [context substringWithRange:[locationCheck rangeAtIndex:3]];
                        _coordinate = CLLocationCoordinate2DMake([latStr doubleValue], [lngStr doubleValue]);
                    }

                    NSRegularExpression *authorMatching = [NSRegularExpression
                            regularExpressionWithPattern:@"Author:(.*)"
                                                 options:NSRegularExpressionCaseInsensitive
                                                   error:&error];
                    NSTextCheckingResult *authorCheck = [authorMatching firstMatchInString:context options:0 range:NSMakeRange(0, [context length])];
                    if(authorCheck) {
                        _author = [context substringWithRange:[authorCheck rangeAtIndex:1]];
                    }
                } else if([[type lowercaseString] hasPrefix:@"comment"]) {
                    NSString *authorString= [[document substringWithRange:[match rangeAtIndex:2]]
                        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                    NSRegularExpression *imageMatching= [NSRegularExpression
                            regularExpressionWithPattern:@"!\\[Image\\]\\((.*?)\\)"
                                                 options:NSRegularExpressionCaseInsensitive
                                                   error:&error];


                    NSString *commentText = [[document substringWithRange:AIBMakeRange(match.range.location + match.range.length, nextLocation)]
                            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                    NSTextCheckingResult *imageCheck = [imageMatching firstMatchInString:commentText options:0 range:NSMakeRange(0, [commentText length])];
                    if(imageCheck) {
                        NSString *imagePath = [commentText substringWithRange:[imageCheck rangeAtIndex:1]];
                        if(![imagePath hasPrefix:@"/"]) {
                            imagePath = [[[[[descriptor info] path] parent] childPath:imagePath] stringValue];
                        }
                        [_comments addObject:[[AIBIdeaComment alloc] initWithImagePath:imagePath
                                                                                author:authorString]];
                    } else {
                        [_comments addObject:[[AIBIdeaComment alloc] initWithText:commentText
                                                                           author:authorString]];
                    }

                }
            }
        }
    }

    return self;
}

- (void) addComment:(AIBIdeaComment *)comment {
    [self.comments addObject:comment];
}

- (void) removeLastComment {
    [self.comments removeLastObject];
}


- (NSString *) asDocument {
    NSMutableDictionary *metadataDict = [[NSMutableDictionary alloc] init];

    NSString *ret = [NSString stringWithFormat:@"%@\n\n", _text];

    if(CLLocationCoordinate2DIsValid(_coordinate)) {
        if(_coordinateName) {
            metadataDict[@"Location"] = [NSString stringWithFormat:@"%@ @ %f,%f",
                                            _coordinateName, _coordinate.latitude, _coordinate.longitude];
        } else {
            metadataDict[@"Location"] = [NSString stringWithFormat:@"%f,%f",
                                                                   _coordinate.latitude, _coordinate.longitude];
        }

        metadataDict[@"Author"] = _author;
    }

    if([metadataDict count] > 0) {
        ret = [ret stringByAppendingFormat:@"## Context\n"];

        for(NSString *key in metadataDict) {
            ret = [ret stringByAppendingFormat:@"%@: %@\n", key, metadataDict[key]];
        }
        ret = [ret stringByAppendingFormat:@"\n"];
    }


    for(AIBIdeaComment *comment in self.comments) {
        if([comment imagePath]) {
            NSString *truePath = [comment imagePath];
            NSString *parentFolder =[[[[[self descriptor] info] path] parent] stringValue];
            if([[comment imagePath] hasPrefix:parentFolder]) {
                truePath = [[comment imagePath] substringFromIndex:([parentFolder length] +1)];
            }

            ret = [ret stringByAppendingFormat:@"## Comment by %@\n![Image](%@)\n\n",
                                               [comment author],
                                               truePath];
        } else {
            ret = [ret stringByAppendingFormat:@"## Comment by %@\n%@\n\n",
                                               [comment author],
                                               [comment text]];
        }
    }

    return ret;
}

- (NSString *) documentTitle {
    NSString *ret = @"";
    CFStringRef string = (__bridge CFStringRef) _text; // Get string from somewhere
    CFLocaleRef locale = CFLocaleCopyCurrent();

    CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, string,
            CFRangeMake(0, CFStringGetLength(string)), kCFStringTokenizerUnitSentence, locale);
    CFStringTokenizerTokenType tokenType = kCFStringTokenizerTokenNone;
    while(kCFStringTokenizerTokenNone != (tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer))) {
        CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        CFStringRef tokenValue = CFStringCreateWithSubstring(kCFAllocatorDefault, string, tokenRange);
        NSString *tokenStr = (__bridge NSString *) tokenValue;


        if([ret length] == 0) {
            ret = [tokenStr copy];
        } else {
            ret = [ret stringByAppendingFormat:@" %@", tokenStr];
        }

        if([ret length] > 3) {
            CFRelease(tokenValue);
            break;
        } else {
            CFRelease(tokenValue);
        }
    }

    CFRelease(tokenizer);
    CFRelease(locale);

    return [[ret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
            stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

@end