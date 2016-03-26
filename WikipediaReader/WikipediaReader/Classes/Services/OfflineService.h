//
//  OfflineService.h
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface OfflineService : NSObject


+ (id)sharedService;
+ (NSString *)applicationDocumentsDirectory;
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)path;
- (void)cleanAllSavedData;
- (BOOL)saveDownloadedResource:(NSString *)resourceID;
- (BOOL)appendDataPart:(NSData*)data toFileOfResource:(NSString *)resourceID;
- (void)cleanupUnfinishedDownloadsForResource:(NSString *)resourceID;
- (void)deleteResource:(NSString *)resourceIDToDelete;
- (BOOL)isResourceAvailable:(NSString *)resourceID;
- (NSString*)filePathForResource:(NSString *)resourceID;
- (NSString*)filePathForResource:(NSString *)resourceID permanent:(BOOL)isPermanent;
- (BOOL)copyBundleFileToDocumentsFolder:(NSString*)fileName withExtension:(NSString*)ext;
- (NSObject *)readObjectFromFile:(NSString *)fileName decodeWithKey:(NSString *)decodeKey;
- (BOOL)saveObject:(NSObject *)object toFile:(NSString *)fileName encodeWithKey:(NSString *)encodeKey;
- (void)symbolicLinkResource:(NSString *)resourceId toResourceId:(NSString*)targetResourceId;
- (void)linkResource:(NSString *)resourceId toResourceId:(NSString*)targetResourceId;

@end