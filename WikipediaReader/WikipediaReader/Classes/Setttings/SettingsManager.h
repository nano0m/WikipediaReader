//
//  SettingsManager.h
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserDefaultsCurrentLanguage        @"currentLanguage"

@interface SettingsManager : NSObject

+ (void)registerValue:(NSString *)value forKey:(NSString *)key;
+ (void)setValue:(NSString *)value forKey:(NSString *)key;
+ (NSString *)valueForKey:(NSString *)key;

+ (void)setBool:(BOOL)value forKey:(NSString *)key;
+ (BOOL)boolForKey:(NSString *)key;

+ (void)setDouble:(double)value forKey:(NSString *)key;
+ (double)doubleForKey:(NSString *)key;

+ (void)setInteger:(NSInteger)value forKey:(NSString *)key;
+ (NSInteger)integerForKey:(NSString *)key;

+ (void)setDictionary:(NSDictionary *)value forKey:(NSString *)key;
+ (NSDictionary *)dictionaryForKey:(NSString *)key;

@end