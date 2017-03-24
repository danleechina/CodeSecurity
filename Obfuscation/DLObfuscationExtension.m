//
//  DLObfuscationExtension
//  Obfuscation
//
//  Created by Dan.Lee on 2017/3/24.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

#import "DLObfuscationExtension.h"

@implementation DLObfuscationExtension

/*
- (void)extensionDidFinishLaunching
{
    // If your extension needs to do any work at launch, implement this optional method.
}
*/


- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions
{
    return @[@{XCSourceEditorCommandIdentifierKey: @"Obscure Property",
               XCSourceEditorCommandNameKey: @"Obscure Property",
               XCSourceEditorCommandClassNameKey: @"DLObfuscationCommand"},
             
             @{XCSourceEditorCommandIdentifierKey: @"Obscure Method/Class Name",
               XCSourceEditorCommandNameKey: @"Obscure Method/Class Name",
               XCSourceEditorCommandClassNameKey: @"DLObfuscationCommand"}];
}


@end
