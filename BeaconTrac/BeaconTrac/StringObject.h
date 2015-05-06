//
//  StringObject.h
//  CrewPad
//
//  Created by Bilal Itani on 9/29/12.
//
//

#import <Foundation/Foundation.h>

@interface StringObject : NSObject

+ (NSData *)decodeBase64WithString:(NSString *)strBase64;
+ (NSString *)encodeBase64WithString:(NSString *)strData;

+ (NSString *)encodeBase64WithData:(NSData *)objData;

@end
