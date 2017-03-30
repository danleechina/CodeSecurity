//
//  DLObfuscationCommand
//  Obfuscation
//
//  Created by Dan.Lee on 2017/3/24.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

#import "DLObfuscationCommand.h"
#import "DLObfuscationExtension.h"
#import "NSString+Extension.h"
#import "NSData+Extension.h"
#import "DLUnExcapeString.h"
#import "DLXcodeKit.h"

static NSString *const defaultDecryptString = @"dl_getRealText";

@implementation DLObfuscationCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation
                   completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    XCSourceTextBuffer *buffer = invocation.buffer;
    NSMutableArray *lines = invocation.buffer.lines;
    NSMutableArray <XCSourceTextRange *>*selections = invocation.buffer.selections;
    // no selection, no obscuring
    if (!isSelectedText(selections)) {
        completionHandler(nil);
        return;
    }
    // not OC header or source file
    if (!isOCHeaderOrSourceFile(buffer.contentUTI)) {
        completionHandler(nil);
        return;
    }
    
    NSArray *selectedStrings = getSelectedStrings(lines, selections);
    if ([invocation.commandIdentifier isEqualToString:ObfuscateMethodOrClassName]) {
        for (NSInteger index = 0; index < selectedStrings.count; index ++) {
            NSString *toBeObscured = selectedStrings[index];
            // \s*#\s*ifndef\s*%@\s*\n\s*#\s*define\s*%@\s*\w+\s*\n\s*#\s*endif\s*\n
            NSString *regex = [NSString stringWithFormat:@"\\s*#\\s*ifndef\\s*%@\\s*\\n\\s*#\\s*define\\s*%@\\s*\\w+\\s*\\n\\s*#\\s*endif\\s*\\n", toBeObscured, toBeObscured];
            NSArray<NSTextCheckingResult *> *regexMatchResult = getRegexMatchResult(buffer.completeBuffer, regex);
            if (regexMatchResult.count > 0) {
                // 反混淆
                    [lines removeObjectsInRange:getLineRange(buffer.completeBuffer, regexMatchResult.firstObject.range)];
                    // Xcode crash when using buffer.completeBuffer: http://www.openradar.me/29001007
                    // buffer.completeBuffer = [buffer.completeBuffer stringByReplacingCharactersInRange:item.range withString:@""];
            } else {
                // 混淆
                NSString *obscuredSymbol = getAnUniqueRandomStringForBuffer(buffer);
                [lines insertObject:[NSString stringWithFormat:@"#ifndef %@\n#define %@ %@\n#endif", toBeObscured, toBeObscured, obscuredSymbol]
                            atIndex:0];
            }
        }
    } else if ([invocation.commandIdentifier isEqualToString:ObfuscateProperty]) {
        for (NSInteger index = 0; index < selectedStrings.count; index ++) {
            NSString *toBeObscured = selectedStrings[index];
            // \s*#\s*ifndef\s*%@\s*\n\s*#\s*define\s*%@\s*\w+\s*\n\s*#\s*endif\s*\n
            NSString *regex = [NSString stringWithFormat:@"\\s*#\\s*ifndef\\s*%@\\s*\\n\\s*#\\s*define\\s*%@\\s*\\w+\\s*\\n\\s*#\\s*endif\\s*\\n", toBeObscured, toBeObscured];
            NSArray<NSTextCheckingResult *> *regexMatchResult = getRegexMatchResult(buffer.completeBuffer, regex);
            if (regexMatchResult.count > 0) {
                // 反混淆
                [lines removeObjectsInRange:getLineRange(buffer.completeBuffer, regexMatchResult.firstObject.range)];
                
                regex = [NSString stringWithFormat:@"\\s*#\\s*ifndef\\s*_%@\\s*\\n\\s*#\\s*define\\s*_%@\\s*\\w+\\s*\\n\\s*#\\s*endif\\s*\\n", toBeObscured, toBeObscured];
                regexMatchResult = getRegexMatchResult(buffer.completeBuffer, regex);
                [lines removeObjectsInRange:getLineRange(buffer.completeBuffer, regexMatchResult.firstObject.range)];
                
                toBeObscured = [toBeObscured capitalizedString];
                regex = [NSString stringWithFormat:@"\\s*#\\s*ifndef\\s*set%@\\s*\\n\\s*#\\s*define\\s*set%@\\s*\\w+\\s*\\n\\s*#\\s*endif\\s*\\n", toBeObscured, toBeObscured];
                regexMatchResult = getRegexMatchResult(buffer.completeBuffer, regex);
                [lines removeObjectsInRange:getLineRange(buffer.completeBuffer, regexMatchResult.firstObject.range)];
            } else {
                NSString *obscuredSymbol = getAnUniqueRandomStringForBuffer(buffer);
                [lines insertObject:[NSString stringWithFormat:@"#ifndef %@\n#define %@ %@\n#endif", toBeObscured, toBeObscured, obscuredSymbol]
                            atIndex:0];
                [lines insertObject:[NSString stringWithFormat:@"#ifndef _%@\n#define _%@ _%@\n#endif", toBeObscured, toBeObscured, obscuredSymbol]
                            atIndex:0];
                toBeObscured = [toBeObscured capitalizedString];
                obscuredSymbol = [obscuredSymbol capitalizedString];
                [lines insertObject:[NSString stringWithFormat:@"#ifndef set%@\n#define set%@ set%@\n#endif", toBeObscured, toBeObscured, obscuredSymbol]
                            atIndex:0];
            }
        }
    } else if ([invocation.commandIdentifier isEqualToString:ObfuscateEncryptPlainText]) {
        for (NSInteger index = 0; index < selectedStrings.count; index ++) {
            NSString *selectedString = selectedStrings[index];
            if (selectedString.length <= 3) {
                continue;
            }
//            selectedString = [selectedString substringWithRange:NSMakeRange(2, selectedString.length - 3)];
            NSString *toBeObscured = getLiteralStringFromUnEscapeString(selectedString);
            NSString *obscuredString = [toBeObscured dl_encryptTextUsingXORWithRandomByte:0x11 version:0x11];
//            NSString *replaceString = [NSString stringWithFormat:@"%@(@\"%@\")", defaultDecryptString, obscuredString];
            NSString *replaceString = obscuredString;
            XCSourceTextRange *selectRange = selections[index];
            replace(lines, selectRange, replaceString);
        }
    } else if ([invocation.commandIdentifier isEqualToString:ObfuscateDecryptPlainText]) {
        for (NSInteger index = 0; index < selectedStrings.count; index ++) {
            NSString *replaceString = selectedStrings[index];
            NSData *data = [[NSData alloc] initWithBase64EncodedString:replaceString options:NSDataBase64DecodingIgnoreUnknownCharacters];
            replaceString = [data dl_decryptTextUsingXOR];
            XCSourceTextRange *selectRange = selections[index];
            replace(lines, selectRange, replaceString);
        }
    }
    completionHandler(nil);
}

@end
