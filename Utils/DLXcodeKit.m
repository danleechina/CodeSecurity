//
//  DLXcodeKit.m
//  CodeSecurity
//
//  Created by Dan.Lee on 2017/3/30.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//
#import "DLXcodeKit.h"
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
    NSString *randomString = [NSString dl_randomStringWithLength:10].lowercaseString;
    while (randomString
           && buffer.completeBuffer
           && [buffer.completeBuffer rangeOfString:randomString].location != NSNotFound) {
        randomString = [NSString dl_randomStringWithLength:10].lowercaseString;
    }
    return randomString;
}

NSArray<NSTextCheckingResult *> *getRegexMatchResult(NSString *string, NSString *regex) {
    NSRegularExpression *re = [[NSRegularExpression alloc] initWithPattern:regex
                                                                   options:NSRegularExpressionUseUnixLineSeparators
                                                                     error:nil];
    return [re matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)].copy;
}

NSInteger getStartLine(NSString *string, NSRange range) {
    NSInteger ret = 0;
    for (NSInteger index = 0; index < string.length && index <= range.location; index ++) {
        if ([[string substringWithRange:NSMakeRange(index, 1)] isEqualToString:@"\n"]) {
            ret ++;
        }
    }
    return ret;
}

NSInteger getLineCount(NSString *string, NSRange range) {
    NSInteger ret = 0;
    for (NSInteger index = range.location; index < string.length && index <= range.location + range.length - 1; index ++) {
        if ([[string substringWithRange:NSMakeRange(index, 1)] isEqualToString:@"\n"]) {
            ret ++;
        }
    }
    return ret == 0 ? 1 : ret;
}

NSRange getLineRange(NSString *string, NSRange range) {
    return NSMakeRange(getStartLine(string, range), getLineCount(string, range));
}

void replace(NSMutableArray<NSString *>* lines, XCSourceTextRange *inRange, NSString *withReplacedString) {
    NSInteger startLine = inRange.start.line;
    NSInteger endLine = inRange.end.line;
    NSInteger startColumn = inRange.start.column;
    NSInteger endColumn = inRange.end.column;
    
    if (startLine == endLine) {
        NSRange range = NSMakeRange(startColumn, endColumn - startColumn);
        lines[startLine] = [lines[startLine] stringByReplacingCharactersInRange:range withString:withReplacedString];
    } else {
        NSInteger index = startLine + 1;
        while (index < endLine) {
            lines[index] = @"";
            index ++;
        }
        lines[endLine] = [lines[endLine] stringByReplacingCharactersInRange:NSMakeRange(0, endColumn) withString:@""];
        lines[startLine] = [lines[startLine] stringByReplacingCharactersInRange:NSMakeRange(startColumn, lines[startLine].length - startColumn)
                                                                     withString:withReplacedString];
    }
}
