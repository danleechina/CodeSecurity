//
//  DLObfuscationExtension
//  Obfuscation
//
//  Created by Dan.Lee on 2017/3/24.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

#import "DLObfuscationExtension.h"

NSString *const ObfuscateProperty = @"ObfuscateProperty";
NSString *const ObfuscateMethodOrClassName = @"ObfuscateMethodOrClassName";
NSString *const ObfuscateEncryptPlainText = @"ObfuscateEncryptPlainText";
NSString *const ObfuscateDecryptPlainText = @"ObfuscateDecryptPlainText";

@implementation DLObfuscationExtension

- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions {
    return @[@{XCSourceEditorCommandIdentifierKey: ObfuscateProperty,
               XCSourceEditorCommandNameKey: @"Obfuscate Property",
               XCSourceEditorCommandClassNameKey: @"DLObfuscationCommand"},
             
             @{XCSourceEditorCommandIdentifierKey: ObfuscateMethodOrClassName,
               XCSourceEditorCommandNameKey: @"Obfuscate Method/Class Name",
               XCSourceEditorCommandClassNameKey: @"DLObfuscationCommand"},
             
             @{XCSourceEditorCommandIdentifierKey: ObfuscateEncryptPlainText,
               XCSourceEditorCommandNameKey: @"Obfuscate Encrypt Plain Text",
               XCSourceEditorCommandClassNameKey: @"DLObfuscationCommand"},
             
             @{XCSourceEditorCommandIdentifierKey: ObfuscateDecryptPlainText,
               XCSourceEditorCommandNameKey: @"Obfuscate Decrypt Plain Text",
               XCSourceEditorCommandClassNameKey: @"DLObfuscationCommand"},];
}


@end
