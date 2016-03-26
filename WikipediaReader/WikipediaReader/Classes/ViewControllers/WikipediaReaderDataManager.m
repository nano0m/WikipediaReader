//
//  WikipediaReaderDataManager.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "WikipediaReaderDataManager.h"
#import <sqlite3.h>
#import "Tools.h"
#import "OfflineService.h"

@interface WikipediaReaderDataManager ()

@property(assign, nonatomic)sqlite3 *db;

@end

@implementation WikipediaReaderDataManager

+ (instancetype) sharedManager {
    static dispatch_once_t once;
    static WikipediaReaderDataManager *wikipediaReaderDataManager = nil;
    
    dispatch_once(&once, ^{
        wikipediaReaderDataManager = [[WikipediaReaderDataManager alloc] init];
    });
    return wikipediaReaderDataManager;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        NSString *dbPath = [[OfflineService sharedService] filePathForResource:@"Bookmarks.db" permanent:YES];
        
        if (SQLITE_OK != sqlite3_open([dbPath UTF8String], &_db)) {
            sqlite3_close(_db);
        }else{
            sqlite3_exec(_db, "PRAGMA foreign_keys = on", NULL, NULL, NULL);
        }
    }
    return self;
}

-(void)dealloc{
    sqlite3_close(self.db);
}

- (Bookmark*)addBookmarkUrl:(NSString*)urlString withTitle:(NSString*)title forEmail:(NSString*)email{
    Bookmark *result = nil;
    NSInteger userId = -1;
    
    if (![Tools stringIsNullOrEmpty:email]) {
        userId = [self p_getUserId:email];
    }
    
    NSString *query = nil;
    sqlite3_stmt *stmt = nil;
    
    if (userId > 0) {
        query = @"INSERT INTO boockmark (URL, Title, Timestamp, User_ID) VALUES (?, ?, ?, ?);";
    }else{
        query = @"INSERT INTO boockmark (URL, Title, Timestamp) VALUES (?, ?, ?);";
    }
    
    if (SQLITE_OK == sqlite3_prepare_v2(self.db, [query UTF8String], -1, &stmt, nil)) {
        sqlite3_bind_text(stmt, 1, [urlString UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [title UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt, 3, [[NSDate date] timeIntervalSince1970]);
        
        if (userId > 0) {
            sqlite3_bind_int(stmt, 4, (int)userId);
        }
        
        NSInteger bookmarkId = -1;
        
        if (SQLITE_DONE != sqlite3_step(stmt)) {
            NSLog(@"Error while inserting. %s", sqlite3_errmsg(self.db));
        }else{
            bookmarkId = (NSInteger)sqlite3_last_insert_rowid(self.db);
        }
        
        sqlite3_finalize(stmt);
        stmt = nil;
        
        if (bookmarkId > 0) {
            query = @"SELECT Boockmark_ID, URL, Title, Timestamp FROM boockmark WHERE Boockmark_ID = ?";
            
            if (SQLITE_OK == sqlite3_prepare_v2(self.db, [query UTF8String], -1, &stmt, nil)) {
                sqlite3_bind_int(stmt, 1, (int)bookmarkId);
                
                if (SQLITE_ROW == sqlite3_step(stmt)) {
                    result = [self p_readBookmarkInstance:stmt];
                }
                
                sqlite3_finalize(stmt);
            }
        }
    }
    stmt = nil;
    
    return result;
}

- (NSMutableArray<Bookmark*>*)loadBookmarksForEmail:(NSString*)email{
    NSMutableArray<Bookmark*>* result = [[NSMutableArray alloc] init];
    
    NSString *query = nil;
    sqlite3_stmt *stmt = nil;
    
    query = @"SELECT\
    bm.Boockmark_ID,\
    bm.URL,\
    bm.Title,\
    bm.Timestamp\
    FROM boockmark bm\
    LEFT JOIN user u on u.User_ID = bm.User_ID\
    WHERE ";
    
    if (![Tools stringIsNullOrEmpty:email]) {
        query = [query stringByAppendingString:@"u.E_Mail = ?"];
    }else{
        query = [query stringByAppendingString:@"bm.User_ID IS NULL"];
    }
    
    if (SQLITE_OK == sqlite3_prepare_v2(self.db, [query UTF8String], -1, &stmt, nil)) {
        if (![Tools stringIsNullOrEmpty:email]) {
            sqlite3_bind_text(stmt, 1, [email UTF8String], -1, SQLITE_TRANSIENT);
        }
        
        while (SQLITE_ROW == sqlite3_step(stmt)) {
            [result addObject:[self p_readBookmarkInstance:stmt]];
        }
        
        sqlite3_finalize(stmt);
    }
    stmt = nil;
    
    return result;
}

- (void)removeBookmarkWithId:(NSInteger)recordId{
    NSString *query = nil;
    sqlite3_stmt *stmt = nil;
    
    query = @"DELETE FROM boockmark WHERE Boockmark_ID = ?";
    
    if (SQLITE_OK == sqlite3_prepare_v2(self.db, [query UTF8String], -1, &stmt, nil)) {
        sqlite3_bind_int(stmt, 1, (int)recordId);
        
        if (SQLITE_DONE != sqlite3_step(stmt)) {
            NSLog(@"Error while deleting. %s", sqlite3_errmsg(self.db));
        }
        
        sqlite3_finalize(stmt);
    }
    stmt = nil;
}

#pragma mark - Hidden methods

- (Bookmark*)p_readBookmarkInstance:(sqlite3_stmt*)stmt{
    Bookmark *bookmark = [[Bookmark alloc] init];
    
    bookmark.bookmarkId = [self p_columnInt:stmt atIndex:0];
    bookmark.bookmarkUrl = [self p_columnString:stmt atIndex:1];
    bookmark.bookmarkTitle = [self p_columnString:stmt atIndex:2];
    bookmark.bookmarkDate = [NSDate dateWithTimeIntervalSince1970:[self p_columnInt:stmt atIndex:3]];
    
    return bookmark;
}

- (NSInteger)p_getUserId:(NSString*)email{
    NSString *query = nil;
    sqlite3_stmt *stmt = nil;
    BOOL recordExists = NO;
    NSInteger userId = -1;
    
    query = @"SELECT User_ID, E_Mail FROM user WHERE E_Mail = ?";
    
    if (SQLITE_OK == sqlite3_prepare_v2(self.db, [query UTF8String], -1, &stmt, nil)) {
        sqlite3_bind_text(stmt, 2, [email UTF8String], -1, SQLITE_TRANSIENT);
        
        if (SQLITE_ROW == sqlite3_step(stmt)) {
            recordExists = YES;
            userId = [self p_columnInt:stmt atIndex:1];
        }
        
        sqlite3_finalize(stmt);
    }
    stmt = nil;
    
    if (!recordExists) {
        query = @"INSERT INTO user(E_Mail) VALUES (?)";
        
        if (SQLITE_OK == sqlite3_prepare_v2(self.db, [query UTF8String], -1, &stmt, nil)) {
            sqlite3_bind_text(stmt, 1, [email UTF8String], -1, SQLITE_TRANSIENT);
            
            if(SQLITE_DONE != sqlite3_step(stmt)){
                NSLog(@"Error while inserting. %s", sqlite3_errmsg(self.db));
            }else{
                userId = (NSInteger)sqlite3_last_insert_rowid(self.db);
            }
            
            sqlite3_finalize(stmt);
        }
        stmt = nil;
    }
    return userId;
}

- (NSString*)p_columnString:(sqlite3_stmt*)stm atIndex:(int)index{
    NSString *text = nil;
    char *chars = (char *) sqlite3_column_text(stm, index);
    
    if (NULL != chars) {
        text = [[NSString alloc] initWithUTF8String:chars];
    }
    
    return text;
}

- (NSInteger)p_columnInt:(sqlite3_stmt*)stm atIndex:(int)index{
    int value = sqlite3_column_int(stm, index);
    return value;
}

-(void)p_startTransaction{
    sqlite3_exec(self.db, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
}

-(NSString*)p_commit{
    NSString *text = nil;
    
    char* errmsg;
    sqlite3_exec(self.db, "COMMIT", NULL, NULL, &errmsg);
    
    if (NULL != errmsg) {
        text = [[NSString alloc] initWithUTF8String:errmsg];
    }
    
    return text;
}


@end
