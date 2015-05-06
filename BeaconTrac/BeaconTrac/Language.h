//
//  Language.h
//  CrewPad
//
//  Created by Bilal Itani on 10/10/12.
//
//

#import <Foundation/Foundation.h>

@interface Language : NSObject

+(void)initialize;
+(void)setLanguage:(NSString *)code;
+(NSString *)get:(NSString *)key alter:(NSString *)alternate;
+(NSString *)getLocalizedStringByKey:(NSString *)key;

+(NSString *)getAbvrByLanguage:(NSString *)language;
+(NSString *)getLanguageByAbvr:(NSString *)code;

@end
