//
//  Tools.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "Tools.h"

NSString *const kApplicationLanguageChangedNotification = @"ApplicationLanguageChanged";
NSString *const kSearchLanguageKey = @"cl_language_code";

@interface Tools ()

#define LONG_DATE_FORMAT   @"dd.MM.yyyy HH:mm:ss"

@end

@implementation Tools

+ (BOOL)stringIsNullOrEmpty:(NSString*)value {
    BOOL result = NO;
    
    if (value == (id)[NSNull null] || nil == value || ([value length] < 1)) {
        result = YES;
    }
    
    return result;
}

+ (NSString *) dateToString:(NSDate *)srcDate {
    NSString *result = nil;
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    
    [formater setDateFormat:LONG_DATE_FORMAT];
    result = [formater stringFromDate:srcDate];
    
    return result;
}

+ (void)changeLanguageTo:(NSString*)code withNotification:(BOOL)sendNotification{
    AMLocalizationSetLanguage(code);
    [SettingsManager setValue:code forKey:kUserDefaultsCurrentLanguage];
    
    if (sendNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationLanguageChangedNotification
                                                            object:nil
                                                          userInfo:@{kSearchLanguageKey:code}];
    }
}

@end
