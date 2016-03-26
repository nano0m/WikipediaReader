//
//  OfflineService.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "OfflineService.h"
#import "Tools.h"
#include <sys/xattr.h>

static NSString *const kResourceRuntimeFolder   = @"Runtime";
static NSString *const kResourcePermamentFolder = @"Permament";

@interface OfflineService()

@property(copy, nonatomic)  NSString *pDocDirectory;

@end

@implementation OfflineService

#pragma mark - Memory Management
- (void)dealloc {
}

#pragma mark - Interface methods
+ (id)sharedService {
    static dispatch_once_t once;
    static OfflineService *offlineService = nil;
    
    dispatch_once(&once, ^{
        offlineService = [[OfflineService alloc] init];
    });
    return offlineService;
}

- (id)init {
    self = [super init];
    if (self) {
        _pDocDirectory = [OfflineService applicationDocumentsDirectory];
        [self p_setupFolders];
    }
    
    return self;
}

- (void)cleanAllSavedData {
    [self cleanAllSavedData:NO];
}

- (void)cleanAllSavedData:(BOOL)isPermanent {
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    NSString *directoryPath =[self.pDocDirectory stringByAppendingPathComponent:(isPermanent?kResourcePermamentFolder:kResourceRuntimeFolder)];
    
    NSArray *savedFilesArray = [defaultFileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    
    for (NSString* filePath in savedFilesArray) {
        [defaultFileManager removeItemAtPath:[directoryPath stringByAppendingPathComponent:filePath] error:nil];
    }
}

- (void)symbolicLinkResource:(NSString *)resourceId toResourceId:(NSString*)targetResourceId {
    if ([self isResourceAvailable:resourceId]) {
        if ([self isResourceAvailable:targetResourceId]) {
            [self deleteResource:targetResourceId];
        }
        
        NSError *error =nil;
        [[NSFileManager defaultManager] createSymbolicLinkAtPath:[self filePathForResource:resourceId]
                                             withDestinationPath:[self filePathForResource:targetResourceId]
                                                           error:&error];
    }
}

- (void)linkResource:(NSString *)resourceId toResourceId:(NSString*)targetResourceId {
    if ([self isResourceAvailable:resourceId]) {
        if ([self isResourceAvailable:targetResourceId]) {
            [self deleteResource:targetResourceId];
        }
        
        NSError *error =nil;
        [[NSFileManager defaultManager] linkItemAtPath:[self filePathForResource:resourceId]
                                                toPath:[self filePathForResource:targetResourceId]
                                                 error:&error];
    }
}

- (void)deleteResource:(NSString *)resourceToDelete {
    if ([self isResourceAvailable:resourceToDelete]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[self filePathForResource:resourceToDelete]
                                                   error:&error];
    }
}

- (BOOL)isResourceAvailable:(NSString *)resourceID {
    return [self isResourceAvailable:resourceID permanent:NO];
}

- (BOOL)isResourceAvailable:(NSString *)resourceID permanent:(BOOL)isPermanent{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self filePathForResource:resourceID permanent:isPermanent]];
}

- (NSString*)filePathForResource:(NSString *)resourceID {
    NSString *filePath = [self filePathForResource:resourceID permanent:NO];
    return filePath;
}

- (NSString*)filePathForResource:(NSString *)resourceID permanent:(BOOL)isPermanent{
    NSString *name = [Tools stringIsNullOrEmpty:resourceID]?@"":resourceID;
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",(isPermanent?kResourcePermamentFolder:kResourceRuntimeFolder), name];
    NSString *filePath = [self.pDocDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}


- (void)cleanupUnfinishedDownloadsForResource:(NSString *)resourceID {
    // get path to save resource part
    NSString *resourcePartPath = [self p_filePathForPartOfResource:resourceID];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:resourcePartPath]) {
        // if there is a file, remove it
        NSError *error = nil;
        [fileManager removeItemAtPath:resourcePartPath error:&error];
    }
}

- (BOOL)saveDownloadedResource:(NSString *)resourceID {
    // finalize resource download
    
    NSString *resourcePartPath = [self p_filePathForPartOfResource:resourceID];
    NSString *resourcePath = [self filePathForResource:resourceID];
    
    // rename file
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:resourcePartPath
                                            toPath:resourcePath error:&error];
    
    if (error) {
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)appendDataPart:(NSData*)data toFileOfResource:(NSString *)resourceID {
    
    @synchronized(self) {
        // while no errors occurred, assume that everything is OK
        BOOL success = YES;
        
        // get path to save resource part
        NSString *resourcePartPath = [self p_filePathForPartOfResource:resourceID];
        
        // if no stream, create it
        // before creating stream, ensure there is a file to write stream to
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:resourcePartPath]) {
            // if no file, create it with NSFileProtectionComplete attribute
            success = [fileManager createFileAtPath:resourcePartPath
                                           contents:nil
                                         attributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                                                forKey:NSFileProtectionKey]];
            if (!success) {
                NSString *errorMessage = [NSString stringWithFormat:@"Failed to create file for res:%@ part",
                                          resourceID];
                NSLog(@"OfflineService>appendDataPart>error: %@", errorMessage);
                return success;
            }
            // set "skip sync" attribute(flag)
            if (![OfflineService addSkipBackupAttributeToItemAtURL:resourcePartPath]) {
                NSString *errorMessage = [NSString stringWithFormat:@"Failed to set \"skip sync\" attribute(flag) "
                                          "for res: %@", resourceID];
                NSLog(@"OfflineService>appendDataPart>error: %@", errorMessage);
            }
        }
        
        // create stream and open it
        NSOutputStream *resourceOutputStream = [[NSOutputStream alloc] initToFileAtPath:resourcePartPath append:YES];
        [resourceOutputStream open];
        
        // write data stream
        NSUInteger dataBuffer = data.length;
        NSUInteger writtenBytes = 0;
        
        while (dataBuffer > 0) {
            // write bytes
            writtenBytes = [resourceOutputStream write:[data bytes] maxLength:dataBuffer];
            
            if (writtenBytes == -1) {
                // error occurred?
                
                NSError *outputStreamError = [resourceOutputStream streamError];
                if (outputStreamError) {
                    // error occurred, while writing stream
                    break;
                }
            }else{
                // decrease data buffer by writtenBytes
                dataBuffer -= writtenBytes;
            }
        }
        
        if (dataBuffer != 0) {
            // some bytes were not written
            success = NO;
            NSString *errorMessage = [NSString stringWithFormat:@"%lu bytes were not written(res:%@). Stream error: %@",
                                      (unsigned long)dataBuffer, resourceID, [resourceOutputStream streamError]];
            NSLog(@"OfflineService>appendDataPart>error: %@", errorMessage);
        }
        
        [resourceOutputStream close];
        resourceOutputStream = nil;
        
        return success;
    }
}

-(BOOL)copyBundleFileToDocumentsFolder:(NSString*)fileName withExtension:(NSString*)ext{
    BOOL result = YES;
    
    NSString *filePath = [self filePathForResource:fileName permanent:YES];
    
    filePath = [filePath stringByAppendingString:@"."];
    filePath = [filePath stringByAppendingString:ext];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:filePath]) {
        NSString * pathToFileInBundle = [[NSBundle mainBundle] pathForResource:fileName ofType:ext];
        
        NSError *err = nil;
        
        [fileManager copyItemAtPath:pathToFileInBundle
                             toPath:filePath
                              error:&err];
        
        if (!err) {
            [OfflineService addSkipBackupAttributeToItemAtURL:filePath];
            result = YES;
        }
    }
    
    
    return result;
}

#pragma mark Serialize/Deserialize methods

- (NSObject *)readObjectFromFile:(NSString *)fileName decodeWithKey:(NSString *)decodeKey {
    NSString *filePath = [self.pDocDirectory stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        // there is a file
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        NSObject *obj = [unarchiver decodeObjectForKey:decodeKey];
        [unarchiver finishDecoding];
        
        
        return obj;
    }else{
        // there is no file, nothing to read
        NSString *logMessage = [NSString stringWithFormat:@"File not found:%@", fileName];
        NSLog(@"OfflineService>readObjectFromFile:decodeWithKey:>error: %@", logMessage);
        return nil;
    }
}

- (BOOL)saveObject:(NSObject *)object toFile:(NSString *)fileName encodeWithKey:(NSString *)encodeKey {
    NSString *filePath = [self.pDocDirectory stringByAppendingPathComponent:fileName];
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:object forKey:encodeKey];
    [archiver finishEncoding];
    
    NSError *writingError = nil;
    BOOL result = [data writeToFile:filePath
                            options:NSDataWritingFileProtectionComplete|NSDataWritingAtomic
                              error:&writingError];
    if (!result) {
        NSString *logMessage = [NSString stringWithFormat:@"Saving object(%@) failed with error:%@",
                                fileName, writingError.debugDescription];
        NSLog(@"OfflineService>saveObject:toFile:encodeWithKey:>error: %@", logMessage);
    }
    return result;
}

#pragma mark - Hidden methods

-(void)p_setupFolders{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![self isResourceAvailable:nil permanent:NO]){
        NSError *err = nil;
        NSString *folderPath = [self filePathForResource:nil permanent:NO];
        
        [fileManager createDirectoryAtPath:folderPath
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:&err]; //Create folder
    }
    
    if (![self isResourceAvailable:nil permanent:YES]){
        NSError *err = nil;
        NSString *folderPath = [self filePathForResource:nil permanent:YES];
        
        [fileManager createDirectoryAtPath:folderPath
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:&err]; //Create folder
    }
}

- (NSString*)p_filePathForPartOfResource:(NSString *)resourceID {
    NSString *resourceFilePath = [self filePathForResource:resourceID];
    return [NSString stringWithFormat:@"%@_part", resourceFilePath];
}

#pragma mark - Helper methods

+ (NSString *)applicationDocumentsDirectory  {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)path {
    const char* filePath = [path fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    return result == 0;
}

@end
