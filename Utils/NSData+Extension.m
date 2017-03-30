//
//  NSData+Extension.m
//  CodeSecurity
//
//  Created by Dan.Lee on 2017/3/30.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

#import "NSData+Extension.h"

@implementation NSData (Extension)
- (NSString *)dl_decryptTextUsingXOR {
    if (self == nil || self.length <= 0) {
        return nil;
    }
    
    Byte *dataBytes = (Byte *)[self bytes];
    NSUInteger originalBytesLength = self.length;
    
    Byte randomByte = dataBytes[originalBytesLength - 2];
    //    Byte version = dataBytes[originalBytesLength + 1];
    for (int i = 0; i < originalBytesLength - 2; i++) {
        dataBytes[i] ^= randomByte;
    }
    
    Byte *bytesBuffer = malloc(originalBytesLength - 2);
    memcpy(bytesBuffer, dataBytes, originalBytesLength - 2);
    
    NSData *decryptedData = [[NSData alloc] initWithBytes:bytesBuffer length:(originalBytesLength - 2)];
    NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    free(bytesBuffer);
    bytesBuffer = NULL;
    
    return decryptedString;
}
@end
