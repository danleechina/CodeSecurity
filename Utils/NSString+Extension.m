//
//  NSString+Extension.m
//  xSecurity
//
//  Created by Dan.Lee on 2017/3/24.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

+ (NSString *)randomStringWithLength:(int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i = 0; i < len; i ++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((unsigned int)[letters length])]];
    }
    return randomString;
}

- (NSString *)encryptTextUsingXORWithRandomByte:(Byte)randomByte version:(Byte)version {
    if (self == nil || self.length <= 0) {
        return nil;
    }
    
    NSData *originalData = [self dataUsingEncoding:NSUTF8StringEncoding];
    Byte *dataBytes = (Byte *)[originalData bytes];
    NSUInteger originalBytesLength = originalData.length;
    
    for (int i = 0; i < originalBytesLength; i++) {
        dataBytes[i] ^= randomByte;
    }
    
    Byte *bytesBuffer = malloc(originalBytesLength + 2);
    memcpy(bytesBuffer, dataBytes, originalBytesLength);
    bytesBuffer[originalBytesLength] = randomByte;
    bytesBuffer[originalBytesLength + 1] = version;
    
    NSData *encryptedData = [[NSData alloc] initWithBytes:bytesBuffer length:(originalBytesLength + 2)];
    NSString *encryptedString = [encryptedData base64EncodedStringWithOptions:0];
    
    free(bytesBuffer);
    bytesBuffer = NULL;
    
    return encryptedString;
}

@end
