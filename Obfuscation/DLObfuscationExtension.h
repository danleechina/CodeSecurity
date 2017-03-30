//
//  DLObfuscationExtension
//  Obfuscation
//
//  Created by Dan.Lee on 2017/3/24.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

extern NSString *const ObfuscateProperty;
extern NSString *const ObfuscateMethodOrClassName;
extern NSString *const ObfuscateEncryptPlainText;
extern NSString *const ObfuscateDecryptPlainText;

@interface DLObfuscationExtension : NSObject <XCSourceEditorExtension>

@end
