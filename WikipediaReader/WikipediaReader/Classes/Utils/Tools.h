//
//  Tools.h
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalizationSystem.h"
#import "SettingsManager.h"

extern NSString *const kApplicationLanguageChangedNotification;
extern NSString *const kSearchLanguageKey;

@interface Tools : NSObject

+ (BOOL)stringIsNullOrEmpty:(NSString*)value;
+ (NSString *) dateToString:(NSDate *)srcDate;
+ (void)changeLanguageTo:(NSString*)code withNotification:(BOOL)sendNotification;

@end
