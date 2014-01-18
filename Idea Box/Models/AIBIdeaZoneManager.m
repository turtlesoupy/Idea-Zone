//
// Created by Thomas Dimson on 12/25/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBIdeaZoneManager.h"
#import "AIBIdeaZoneDescriptor.h"
#import "AIBIdeaDescriptor.h"
#import "AIBIdea.h"
#import "AIBAlerts.h"
#import "AIBIdeaComment.h"
#import "UIColor+AIBExtensions.h"
#import "AIBPathViewStates.h"
#import "CocoaSecurity.h"
#import "AIBPathViewStates.h"
#import "AIBConstants.h"
#import <Dropbox/Dropbox.h>
#import "UIImage+Resizing.h"

static NSString * const  kDataStoreIdeaZoneMetadata = @"IdeaZones";

@implementation AIBIdeaZoneManager {
    DBDatastore *_dataStore;
    DBTable *_ideaZonesTable;
    NSInteger _paletteOffset;
    BOOL _wasInitialSignIn;
}

+ (AIBIdeaZoneManager *)sharedInstance {
    static AIBIdeaZoneManager *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AIBIdeaZoneManager  alloc] init];
    });
    return sharedInstance;
}

- (BOOL) isIdeaDescriptor:(DBFileInfo *)info {
    return ![info isFolder]
            && [info size] < 1024 * 10
            && [[[[info path] stringValue] lowercaseString] hasSuffix:@".txt"];
}

- (id) init {
    if((self = [super init])) {
        _paletteOffset = rand();
        _wasInitialSignIn = NO;
    }

    return self;
}

- (NSError *)handleAuthorized {
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
    [DBFilesystem setSharedFilesystem:filesystem];

    DBError  *error;
    _dataStore = [DBDatastore openDefaultStoreForAccount:account error:&error];
    _ideaZonesTable = [_dataStore getTable:@"ideaZones"];
    _pathViewStates = [[AIBPathViewStates alloc] initWithDatastore:_dataStore];

    if(error) {
        return error;
    }
    

    [filesystem createFolder:[self rootIdeaPath] error:&error];
    if(error) {
        if([error code] != DBErrorParamsExists) {
            return error;
        }
    }
    return nil;
}

- (BOOL) completedInitialSync {
    return [[DBFilesystem sharedFilesystem] completedFirstSync];
}

- (DBPath *)rootIdeaPath {
    return [[DBPath root] childPath:@"Idea Zone"];
}

- (DBPath *)zonePath:(NSString *)zoneName {
    return [[self rootIdeaPath] childPath:zoneName];
}

- (DBPath *)ideaPath:(NSString *)zoneName documentName:(NSString *)documentName {
    return [[self zonePath:zoneName] childPath:[self documentName:documentName]];
}

- (NSString *)documentName:(NSString *)title {
    return [NSString stringWithFormat:@"%@.txt", title];
}

- (void) createSampleFolders {
    static NSString * const kSharedFoldersSample =
            @"Collaboration with friends\n\n"
            "You can collaborate on ideas with friends in Idea Zone. Visit an Idea Zone, press 'Configure' "
            "and follow the on-screen instructions. Collaboration uses Dropbox's shared folders and can even "
            "work outside this app\n\n"
            "## Context\n"
            "Author: A future collaborator\n"
            "Location: Stanford, California @ 37.4225,-122.1653";

    static NSString * const kSampleSample =
        @"Sample Idea\n\n"
         "Ideas in Idea Zone are just text files in Dropbox. This idea is accessible "
         "as '/Idea Zone/Life Ideas/Sample Idea.txt'.\n\n"
         "## Context\n"
         "Author: A mysterious voice\n"
         "Location: Stanford, California @ 37.4225,-122.1653\n\n"
         "## Comment by Your pal, Thomas\n"
         "You can comment and start elaborations and discussions. Press the comment button to make it happen\n";

    static NSString * const kDeleteSample =
            @"Swipe to delete me\n\n"
             "Remove ideas by swiping them on the previous screen. Or, you can always delete the file in dropbox!\n\n"
             "## Context\n"
             "Author: Bumblebee Man\n"
             "Location: Tijuana, Mexico @ 37.4225,-122.1653\n\n"
    ;

    [self addZone:@"Life Ideas" error:nil];
    [self addZone:@"Game Ideas" error:nil];
    [self addZone:@"App Ideas" error:nil];

    DBFile *file = [[DBFilesystem sharedFilesystem] createFile:[self ideaPath:@"App Ideas"
                                                                 documentName:@"Collaboration With Friends"]
                                                         error:nil];

    if(file) {
        [file writeString:kSharedFoldersSample error:nil];
        [file close];
    }

    file = [[DBFilesystem sharedFilesystem] createFile:[self ideaPath:@"Game Ideas"
                                                                 documentName:@"Swipe to Delete"]
                                                         error:nil];

    if(file) {
        [file writeString:kDeleteSample error:nil];
        [file close];
    }

    file = [[DBFilesystem sharedFilesystem] createFile:[self ideaPath:@"Life Ideas"
                                                         documentName:@"Sample Idea"]
                                                 error:nil];

    if(file) {
        [file writeString:kSampleSample error:nil];
        [file close];
    }
}


- (void) addZone:(NSString *)name error:(DBError **)srcError {
    DBError *error;
    [[DBFilesystem sharedFilesystem] createFolder:[[self rootIdeaPath] childPath:name] error:&error];

    if(error) {
        if(srcError) {
            *srcError = error;
        }
    } else {
        [self getOrInsertIdeaZoneMetadata:name];
        [_dataStore sync:&error];
        if(error) {
            if(srcError) {
                *srcError = error;
            }
            AIBLog(@"Error adding zone: %@", error);
        }
    }
}

- (NSString *)zoneDatastoreKey:(NSString *)name {
    return [[CocoaSecurity md5:name] base64];
}

- (DBRecord *)getOrInsertIdeaZoneMetadata:(NSString *)name {
    BOOL wasInserted;
    DBError *error;
    DBRecord *rec = [_ideaZonesTable getOrInsertRecord:[self zoneDatastoreKey:name]
    fields:@{@"zone-name": name,
            @"color": [[UIColor ideaZonePalette][(NSUInteger) (_paletteOffset % [[UIColor ideaZonePalette] count])] hexString]}
            inserted:&wasInserted error:&error];
    _paletteOffset++;

    if(error) {
        AIBLog(@"Error for getting/inserting zone md %@", error);
    }
    return rec;

}

- (void) changeZoneColor:(AIBIdeaZoneDescriptor *)zone toColor:(UIColor *)color error:(DBError **)srcError {
    DBRecord *md = [self getOrInsertIdeaZoneMetadata:[zone name]];
    md[@"color"] = [color hexString];
    DBError *error;
    [_dataStore sync:&error];
    if(error) {
        if(srcError) {
            *srcError = error;
        }
    } else {
        [zone setColor:color];
    }
}

- (void)renameIdea:(AIBIdeaDescriptor *)descriptor toName:(NSString *)name error:(DBError **)error {
    DBError *_error;
    DBPath *newPath = [[[[descriptor info] path] parent] childPath:[self documentName:name]];
    BOOL moved =  [[DBFilesystem sharedFilesystem] movePath:[[descriptor info] path] toPath:newPath error:&_error];
    AIBReturnVoidIfErrorPtr(error, _error)

    if(!moved) {
        return;
    }

    [descriptor setName:name];

    DBFileInfo *info = [[DBFilesystem sharedFilesystem] fileInfoForPath:newPath error:&_error];
    [descriptor setInfo:info];
}

- (void) renameZone:(AIBIdeaZoneDescriptor *)zone toName:(NSString *)name error:(DBError **)srcError {
    DBError *error;
    BOOL moved =  [[DBFilesystem sharedFilesystem] movePath:[[zone fileInfo] path] toPath:[self zonePath:name] error:&error];
    if(error) {
        if(srcError) {
            *srcError = error;
        }
    }

    if(!moved) {
        return;
    }

    [zone setName:name];

    DBFileInfo *info = [[DBFilesystem sharedFilesystem] fileInfoForPath:[self zonePath:name] error:&error];

    [zone setFileInfo:info];
}


- (void) warmIdeaDescriptors:(NSArray *) fileInfos {
    for(DBFileInfo *info in fileInfos) {
        if([self isIdeaDescriptor:info]) {
            DBError *error;
            DBFile *file = [[DBFilesystem sharedFilesystem] openFile:[info path] error:&error];
            if(error) {
                AIBLog(@"Error warming %@: %@", [info path], error);
            } else if(file.status.cached) {

            } else {
                AIBLog(@"Warming %@", [info path]);
                [file readHandle:&error];
            }
            [file close];
        }
    }
}

- (NSArray *) zones:(DBError **)srcError {
    DBError *error;
    AIBLog(@"Requesting idea zones");
    NSArray *listing = [[DBFilesystem sharedFilesystem] listFolder:[self rootIdeaPath] error:&error];

    if(error) {
        AIBLog(@"Error requesting idea zones, %@", error);
        if(srcError) {
            *srcError = error;
        }
        return nil;
    }

    BOOL firstSignIn = NO;
    [_ideaZonesTable getOrInsertRecord:@"INITIAL" fields:@{} inserted:&firstSignIn error:nil];
    AIBLog(@"Was first sign in: %d", firstSignIn);
    if(firstSignIn) {
        [self createSampleFolders];
        return [self zones:srcError];
    }

    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for(DBFileInfo *info in listing) {
        if([info isFolder]) {
            AIBIdeaZoneDescriptor *descriptor =  [[AIBIdeaZoneDescriptor alloc] initWithName:[[info path] name] fileInfo:info];

            DBError *descriptorError;
            NSArray *descriptorListing = [[DBFilesystem sharedFilesystem] listFolder:[info path] error:&descriptorError];


            if(!error) {
                BOOL anyUpdated = NO;
                NSUInteger numIdeas = 0;
                for(DBFileInfo *subInfo in descriptorListing) {
                    if([self isIdeaDescriptor:subInfo]) {
                        if([_pathViewStates pathWasUpdated:subInfo error:nil])  {
                            anyUpdated = YES;
                        }
                        numIdeas++;
                    }
                }
                [descriptor setNumIdeas:numIdeas];
                [descriptor setAnyUpdated:anyUpdated];
            }

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self warmIdeaDescriptors:descriptorListing];
            });

            DBRecord *zoneMd = [self getOrInsertIdeaZoneMetadata:[descriptor name]];
            if(zoneMd[@"color"]) {
                UIColor *color = [UIColor colorWithHexString:zoneMd[@"color"]];
                if(color) {
                    [descriptor setColor:color];
                }
            }
            [ret addObject:descriptor];
        }
    }
    [_dataStore sync:nil];
    return ret;
}

- (NSArray *) ideasInZone:(AIBIdeaZoneDescriptor *)zone error:(DBError **)srcError {
    DBError *error;
    AIBLog(@"Retrieving ideas for %@", [zone name]);
    NSArray *listing = [[DBFilesystem sharedFilesystem]
            listFolder:[[zone fileInfo] path] error:&error];

    if(error) {
        if(srcError) {
            *srcError = error;
        }
        return nil;
    }

    NSMutableArray *ideaDescriptors = [[NSMutableArray alloc] init];

    for(DBFileInfo *info in listing) {
        if([self isIdeaDescriptor:info]) {
            AIBIdeaDescriptor *descriptor = [[AIBIdeaDescriptor alloc] initWithFileInfo:info];
            [ideaDescriptors addObject:descriptor];
            DBError *readError;
            DBFile *file = [[DBFilesystem sharedFilesystem] openFile:[info path] error:&readError];
            if(!readError && [[file status] cached]) {
                [file close];
                AIBIdea *idea = [self readIdea:descriptor error:&readError];
                if(!readError && idea) {
                    [descriptor setNumComments:[[idea comments] count]];
                }
            } else{
                [file close];
            }
        }
    }

    return ideaDescriptors;
}

- (void) createIdea:(AIBIdea *)idea inZone:(AIBIdeaZoneDescriptor *)zone error:(DBError **)srcError {
    AIBLog(@"Creating idea %@.txt", [idea documentTitle]);

    DBError *error;
    DBFile *file = [[DBFilesystem sharedFilesystem] createFile:[self ideaPath:[zone name]
                                                                 documentName:[idea documentTitle]]
                                                          error:&error];
    if(error) {
        if(srcError) {
            *srcError = error;
        }

        return;
    }

    [file writeString:[idea asDocument] error:&error];
    [file close];

    if(error) {
        if(srcError) {
            *srcError = error;
        }
    }
}

- (void) writeIdea:(AIBIdea *)idea error:(DBError **)srcError {
    DBError *error;
    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:[[[idea descriptor] info] path]
                                                         error:&error];
    if(error) {
        if(srcError) {
            *srcError = error;
        }

        return;
    }

    [file writeString:[idea asDocument] error:&error];
    [[idea descriptor] setInfo:[file info]];
    [file close];

    if(error) {
        if(srcError) {
            *srcError = error;
        }
    }
}

- (AIBIdea *) readIdea:(AIBIdeaDescriptor *)descriptor error:(DBError **)srcError {
    DBError *error;
    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:[[descriptor info] path] error:&error];
    if(error) {
        if(srcError) {
            *srcError = error;
        }
        return nil;
    }

    NSString *text = [file readString:&error];
    [file close];
    if(error) {
        if(srcError) {
            *srcError = error;
        }
        return nil;
    }

    return [[AIBIdea alloc] initFromDocument:text descriptor:descriptor];
}

- (void) setImageViewFromPath:(DBPath *)path imageView:(__weak UIImageView *)imageView {
    DBError *_error;
    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:&_error];
    if(_error) {
        AIBLog(@"Error trying to set image view: %@", _error);
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DBError *_error2;
        UIImage *image = [[UIImage alloc] initWithData:[file readData:&_error2]];
        if(_error2) {
            AIBLog(@"Error trying to set image view: %@", _error2);
            return;
        }
        [file close];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageView setImage:image];
        });
    });
}

- (void) imageFromPath:(DBPath *)path callback:(UIImageBlock_t)callback {
    DBError *_error;
    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:&_error];
    if(_error) {
        AIBLog(@"Error trying to get image: %@", _error);
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DBError *_error2;
        UIImage *image = [[UIImage alloc] initWithData:[file readData:&_error2]];
        if(_error2) {
            AIBLog(@"Error trying to set image view: %@", _error2);
            return;
        }
        [file close];

        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image);
        });
    });

}

- (void) setImageButtonFromPath:(DBPath *)path imageView:(__weak UIButton *)imageButton {
    DBError *_error;
    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:&_error];
    if(_error) {
        AIBLog(@"Error trying to set image view: %@", _error);
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DBError *_error2;
        UIImage *image = [[UIImage alloc] initWithData:[file readData:&_error2]];
        if(_error2) {
            AIBLog(@"Error trying to set image view: %@", _error2);
            return;
        }
        [file close];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageButton setImage:image forState:UIControlStateNormal];
        });
    });
}

- (void)addCommentToIdea:(AIBIdea *)idea commentImage:(UIImage *)image error:(DBError **)error {
    DBError *_error;
    static const int numRandChars = 10;
    char data[numRandChars];
    for (int x=0;x<numRandChars;data[x++] = (char)('A' + (arc4random_uniform(26))));
    NSString *rand = [[NSString alloc] initWithBytes:data length:numRandChars encoding:NSUTF8StringEncoding];

    DBPath *imagePath = [[[[[[idea descriptor] info] path] parent] childPath:[[idea descriptor] name]]
            childPath:[NSString stringWithFormat:@"%@-%@.jpg", [[idea descriptor] name], rand]];

    DBFile *file = [[DBFilesystem sharedFilesystem] createFile:imagePath error:&_error];

    AIBReturnVoidIfErrorPtr(error, _error)

    NSData *imageData = UIImageJPEGRepresentation([image scaleToFitSize:CGSizeMake(960, 960)], 0.70);

    [file writeData:imageData error:&_error];
    [file close];

    AIBReturnVoidIfErrorPtr(error, _error)


    AIBIdeaComment *comment = [[AIBIdeaComment alloc] initWithImagePath:[imagePath stringValue] author:[self preferredUsername]];
    [idea addComment:comment];

    [self writeIdea:idea error:&_error];
    if(_error) {
        [idea removeLastComment];
        if(error) {
            *error = _error;
        }
    }
}

- (void) addCommentToIdea:(AIBIdea *)idea
              commentText:(NSString *)commentText
                    error:(DBError **)srcError {

    DBError *error;
    NSString *authorStr = [self preferredUsername];
    AIBIdeaComment *comment = [[AIBIdeaComment alloc] initWithText:commentText author:authorStr];
    [idea addComment:comment];

    [self writeIdea:idea error:&error];
    if(error) {
        [idea removeLastComment];
        if(srcError) {
            *srcError = error;
        }
    }
}

- (NSString *) preferredUsername {
    return [[[[DBAccountManager sharedManager] linkedAccount] info] displayName];
}

- (void)deleteIdea:(AIBIdeaDescriptor *)descriptor error:(DBError **)srcError {
    DBError *error;
    [[DBFilesystem sharedFilesystem] deletePath:[[descriptor info] path] error:&error];
    if(error && srcError) {
        *srcError = error;
    }
}
@end