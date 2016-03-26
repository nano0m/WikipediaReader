//
//  SettingsManager.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "SettingsManager.h"

@implementation SettingsManager

+ (void)setValue:(NSString *)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

+ (void)registerValue:(NSString *)value forKey:(NSString *)key; {
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults]
     registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                       value, key, nil]];
    
}

+ (NSString *)valueForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

//BOOL
+ (void)setBool:(BOOL)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
}

+ (BOOL)boolForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}


//Double
+ (void)setDouble:(double)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:key];
}

+ (double)doubleForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] doubleForKey:key];
}

//Integer
+ (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
}

+ (NSInteger)integerForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

//Dictionary
+ (void)setDictionary:(NSDictionary *)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

+ (NSDictionary *)dictionaryForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
}


@end
