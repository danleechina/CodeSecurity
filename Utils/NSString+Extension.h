//
//  NSString+Extension.h
//  xSecurity
//
//  Created by Dan.Lee on 2017/3/24.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

+ (NSString *)dl_randomStringWithLength:(int)len;
- (NSString *)dl_encryptTextUsingXORWithRandomByte:(Byte)randomByte version:(Byte)version;

@end
