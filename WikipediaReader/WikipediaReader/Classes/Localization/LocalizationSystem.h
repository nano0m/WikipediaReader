//
//  LocalizationSystem.h
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AMLocalizedString(key, comment) \
[[LocalizationSystem sharedLocalSystem] localizedStringForKey:(key) value:(comment)]

#define AMLocalizationSetLanguage(language) \
[[LocalizationSystem sharedLocalSystem] setLanguage:(language)]

#define AMLocalizationLanguage \
[[LocalizationSystem sharedLocalSystem] applicationLanguage]

#define AMLocalizationReset \
[[LocalizationSystem sharedLocalSystem] resetLocalization]

extern NSString *const kLanguageRU;
extern NSString *const kLanguageEN;
extern NSString *const kLanguageLV;

extern NSString *const kLocaleRuRU;
extern NSString *const kLocaleEnUK;
extern NSString *const kLocaleLvLV;

extern NSString *const kLocalizationSystemCurrentLanguageDefaultValue;

@interface LocalizationSystem : NSObject

// you really shouldn't care about this functions and use the MACROS
+ (LocalizationSystem *)sharedLocalSystem;

//gets the string localized
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment;

//sets the language
- (void)setLanguage:(NSString*)language;

//gets the current system language
- (NSString*)systemLanguage;

//gets the current application language
- (NSString*)applicationLanguage;

//gets the current application locale like ru_RU, lv_LV, en_US
- (NSString*)currentApplicationLocale;

//resets this system.
- (void)resetLocalization;

- (NSArray *)languagesSupportedByApplication;
//- (NSArray *)titlesForlanguagesSupportedByApplication;
- (BOOL)isLanguageSupportedByApplication:(NSString *)lang;

@end
