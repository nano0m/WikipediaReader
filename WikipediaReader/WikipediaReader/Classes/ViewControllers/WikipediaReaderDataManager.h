//
//  WikipediaReaderDataManager.h
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bookmark.h"

@interface WikipediaReaderDataManager : NSObject

+ (instancetype)sharedManager;

- (Bookmark*)addBookmarkUrl:(NSString*)urlString withTitle:(NSString*)title forEmail:(NSString*)email;
- (NSMutableArray<Bookmark*>*)loadBookmarksForEmail:(NSString*)email;
- (void)removeBookmarkWithId:(NSInteger)recordId;

@end
