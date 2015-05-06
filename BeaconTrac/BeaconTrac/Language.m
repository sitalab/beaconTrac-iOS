//
//  Language.m
//  CrewPad
//
//  Created by Bilal Itani on 10/10/12.
//
//

#import "Language.h"

@implementation Language

static NSBundle *bundle = nil;

+(void)initialize {
    
    /*NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString *current = [[languages objectAtIndex:0] retain];
    [self setLanguage:current];*/
}

+(void)setLanguage:(NSString *)code {
    
    NSString *path = [[ NSBundle mainBundle ] pathForResource:code ofType:@"lproj"];
    // Use bundle = [NSBundle mainBundle] if you
    // dont have all localization files in your project.
    bundle = [NSBundle bundleWithPath:path];
}

+(NSString *)getLocalizedStringByKey:(NSString *)key{
    return [bundle localizedStringForKey:key value:nil table:nil];
}

+(NSString *)get:(NSString *)key alter:(NSString *)alternate {
    NSString *value=[bundle localizedStringForKey:key value:alternate table:nil];
    if (value==nil) {
        value=NSLocalizedString(key, nil);
    }
    return value;
}


+(NSString *)getLanguageByAbvr:(NSString *)code
{
    if ([code isEqualToString:@"en"]) {
        return @"English";
    }else if ([code isEqualToString:@"fr"]) {
        return @"Français";
    }else if([code isEqualToString:@"ar"]){
        return @"العربية";
    }else if ([code isEqualToString:@"es"]) {
        return @"Spanish";
    }
    
    return code;
}

+(NSString *)getAbvrByLanguage:(NSString *)language
{
    if ([language isEqualToString:@"English"]) {
        return @"en";
    }else if ([language isEqualToString:@"Français"]) {
        return @"fr";
    }else if ([language isEqualToString:@"العربية"]) {
        return @"ar";
    }else if ([language isEqualToString:@"Spanish"]) {
        return @"es";
    }
    return language;
}

@end
