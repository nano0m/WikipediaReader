//
//  LocalizationSystem.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "LocalizationSystem.h"

NSString *const kLanguageRU = @"ru";
NSString *const kLanguageEN = @"en";
NSString *const kLanguageLV = @"lv";


NSString *const kLocaleRuRU = @"ru_RU";
NSString *const kLocaleEnUK = @"en_UK";
NSString *const kLocaleLvLV = @"lv_LV";

NSString *const kLocalizationSystemCurrentLanguageDefaultValue = @"en";

@interface LocalizationSystem ()

@property (strong, nonatomic) NSArray *pApplicationLanguages;
@property (copy, nonatomic) NSString *currentAppLanguage;

@end

@implementation LocalizationSystem

//Current application bundle to get the languages.
static NSBundle *bundle = nil;

//Singleton instance
+ (id)sharedLocalSystem {
    static dispatch_once_t once;
    static LocalizationSystem *sharedLocalSystem = nil;
    
    dispatch_once(&once, ^{
        sharedLocalSystem = [[LocalizationSystem alloc] init];
    });
    return sharedLocalSystem;
}

- (id)init{
    if ((self = [super init])){
        //empty.
        bundle = [NSBundle mainBundle];
        _pApplicationLanguages = @[kLanguageRU, kLanguageLV, kLanguageEN];
    }
    return self;
}

// Gets the current localized string as in NSLocalizedString.
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment{
    return [bundle localizedStringForKey:key value:comment table:nil];
}



// If this function is not called it will use the default OS language.
// If the language does not exists y returns the default OS language.
- (void)setLanguage:(NSString*)lang{
    self.currentAppLanguage = lang;
    NSString *path = [[ NSBundle mainBundle ] pathForResource:lang ofType:@"lproj" ];
    
    if (path == nil){
        //in case the language does not exists
        [self resetLocalization];
    }else{
        //load the bundle
        bundle = [NSBundle bundleWithPath:path];
    }
}

// Just gets the current setted up language.
// returns "es","fr",...
//
// example call:
// NSString * currentL = LocalizationGetLanguage;
- (NSString*)systemLanguage{
    
    NSArray* languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [languages objectAtIndex:0];
    
    return preferredLang;
}

- (NSString*)applicationLanguage{
    return self.currentAppLanguage;
}

- (NSString*)currentApplicationLocale{
    NSString *locale = kLocaleEnUK;
    NSString *curLanguage = self.currentAppLanguage;
    
    if ([curLanguage isEqualToString:kLanguageRU]){
        locale = kLocaleRuRU;
    }else if ([curLanguage isEqualToString:kLanguageLV]){
        locale = kLocaleLvLV;
    }
    
    return locale;
}

// Resets the localization system, so it uses the OS default language.
//
// example call:
// LocalizationReset;
- (void)resetLocalization{
    bundle = [NSBundle mainBundle];
}

- (NSArray *)languagesSupportedByApplication{
    return self.pApplicationLanguages;
}

- (BOOL)isLanguageSupportedByApplication:(NSString *)lang{
    return [self.pApplicationLanguages containsObject:lang];
}

@end
