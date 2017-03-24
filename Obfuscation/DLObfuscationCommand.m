//
//  DLObfuscationCommand
//  Obfuscation
//
//  Created by Dan.Lee on 2017/3/24.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

#import "DLObfuscationCommand.h"
#import "NSString+Extension.h"


BOOL isSelectedText(NSArray<XCSourceTextRange *>*selections) {
    if (selections.count == 1
        && selections[0].start.line == selections[0].end.line
        && selections[0].start.column == selections[0].end.column) {
        return NO;
    }
    return YES;
}

BOOL isOCHeaderOrSourceFile(NSString *uti) {
    return [uti isEqualToString:@"public.c-header"] || [uti isEqualToString:@"public.objective-c-source"];
}

NSArray *getSelectedStrings(NSArray *lines, NSArray *selections) {
    if (!isSelectedText(selections)) {
        return nil;
    }
    NSMutableArray *selectedStrings = [NSMutableArray arrayWithCapacity:selections.count];
    for (XCSourceTextRange *textRange in selections) {
        NSInteger startLine = textRange.start.line;
        NSInteger endLine = textRange.end.line;
        NSInteger startColumn = textRange.start.column;
        NSInteger endColumn = textRange.end.column;
        NSMutableString *result = [NSMutableString new];
        for (NSInteger lineIndex = startLine; lineIndex <= endLine; lineIndex ++) {
            if (startLine == endLine) {
                [result appendString:[lines[startLine] substringWithRange:NSMakeRange(startColumn, endColumn - startColumn)]];
            } else if (lineIndex == endLine) {
                [result appendString:[lines[endLine] substringToIndex:endColumn]];
            } else if (lineIndex == startLine) {
                [result appendString:[lines[startLine] substringFromIndex:startColumn]];
            } else {
                [result appendString:lines[lineIndex]];
            }
        }
        [selectedStrings addObject:result];
    }
    return selectedStrings.copy;
}

NSString *getAnUniqueRandomStringForBuffer(XCSourceTextBuffer *buffer) {
    NSString *randomString = [NSString randomStringWithLength:10].lowercaseString;
    while (randomString
           && buffer.completeBuffer
           && [buffer.completeBuffer rangeOfString:randomString].location != NSNotFound) {
        randomString = [NSString randomStringWithLength:10].lowercaseString;
    }
    return randomString;
}

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
    if ([invocation.commandIdentifier isEqualToString:@"Obscure Method/Class Name"]) {
        for (NSInteger index = 0; index < selectedStrings.count; index ++) {
            NSString *toBeObscured = selectedStrings[index];
            NSString *obscuredSymbol = getAnUniqueRandomStringForBuffer(buffer);
            NSString *notifyComment = [NSString stringWithFormat:@"// %@ has been obscured as %@", toBeObscured, obscuredSymbol];
            [lines insertObject:notifyComment atIndex:selections[index].start.line];
            [lines insertObject:[NSString stringWithFormat:@"#ifndef %@\n#define %@ %@\n#endif", toBeObscured, toBeObscured, obscuredSymbol]
                        atIndex:0];
        }
    } else if ([invocation.commandIdentifier isEqualToString:@"Obscure Property"]) {
        for (NSInteger index = 0; index < selectedStrings.count; index ++) {
            NSString *toBeObscured = selectedStrings[index];
            NSString *obscuredSymbol = getAnUniqueRandomStringForBuffer(buffer);
            NSString *notifyComment = [NSString stringWithFormat:@"// %@ has been obscured as %@", toBeObscured, obscuredSymbol];
            [lines insertObject:notifyComment atIndex:selections[index].start.line];
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
    //    else if ([invocation.commandIdentifier isEqualToString:@"Obscure plain text"]) {
    //        for (NSInteger index = 0; index < selectedStrings.count; index ++) {
    //            NSString *toBeObscured = selectedStrings[index];
    //            NSString *obscuredString = [toBeObscured encryptTextUsingXORWithRandomByte:0x11 version:0x11];
    //            NSString *replaceString = [NSString stringWithFormat:@"%@(%@)", defaultDecryptString, obscuredString];
    //        }
    //    }
    completionHandler(nil);
}

@end
