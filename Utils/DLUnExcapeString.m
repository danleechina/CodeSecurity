//
//  DLUnExcapeString.m
//  CodeSecurity
//
//  Created by Dan.Lee on 2017/3/30.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

#import "DLUnExcapeString.h"

NSString *escapeUnicodeStringToLiteral(NSString *escapeUnicodeString) {
    NSString *convertedString = [escapeUnicodeString mutableCopy];
    // http://userguide.icu-project.org/transforms/general
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    CFRelease(transform);
    return convertedString.copy;
}

bool isHexChar(char item) {
    return (item >= 'a' && item <= 'f') || (item >= '0' && item <= '9') || (item >= 'A' && item <= 'F');
}

bool isOctalChar(char item) {
    return item >= '0' && item <= '7';
}

char getNumberFromHexString(NSString *strNum) {
    return strtol(strNum.UTF8String, NULL, 16);
}

char getNumberFromOctalString(NSString *strNum) {
    return strtol(strNum.UTF8String, NULL, 8);
}

NSString *analyzeUnEscapeStringWithHexEscape(NSString *unEscapeString) {
    if (unEscapeString.length == 0) {
        return @"";
    }
    char firstChar = [unEscapeString characterAtIndex:0];
    char literalFirstChar = '\0';
    if (isHexChar(firstChar)) {
        literalFirstChar = getNumberFromHexString([unEscapeString substringWithRange:NSMakeRange(0, 1)]);
    } else {
        return [unEscapeString substringFromIndex:1];
    }
    
    if (unEscapeString.length == 1) {
        return [NSString stringWithFormat:@"%c", literalFirstChar];
    }
    
    char secondChar = [unEscapeString characterAtIndex:1];
    if (isHexChar(secondChar)) {
        char literalCombineChar = getNumberFromHexString([unEscapeString substringWithRange:NSMakeRange(0, 2)]);
        return [NSString stringWithFormat:@"%c%@", literalCombineChar, [unEscapeString substringFromIndex:2]];
    } else {
        return [NSString stringWithFormat:@"%c%@", literalFirstChar, [unEscapeString substringFromIndex:1]];
    }
}

NSString *anylyzeUnEscapeStringWithOctalEscape(NSString *unEscapeString) {
    char firstChar = [unEscapeString characterAtIndex:0];
    char literalFirstChar = '\0';
    if (isOctalChar(firstChar)) {
        literalFirstChar = getNumberFromOctalString([unEscapeString substringWithRange:NSMakeRange(0, 1)]);
    } else {
        return [unEscapeString substringFromIndex:1];
    }
    
    if (unEscapeString.length == 1) {
        return [NSString stringWithFormat:@"%c", literalFirstChar];
    }
    
    char secondChar = [unEscapeString characterAtIndex:1];
    if (isOctalChar(secondChar)) {
        if (unEscapeString.length == 2) {
            char literalCombineChar = getNumberFromOctalString(unEscapeString);
            return [NSString stringWithFormat:@"%c", literalCombineChar];
        } else {
            char thirdChar = [unEscapeString characterAtIndex:2];
            if (isOctalChar(thirdChar)) {
                char literalCombineChar = getNumberFromOctalString([unEscapeString substringWithRange:NSMakeRange(0, 3)]);
                return [NSString stringWithFormat:@"%c%@", literalCombineChar, [unEscapeString substringFromIndex:3]];
            } else {
                char literalCombineChar = getNumberFromOctalString([unEscapeString substringWithRange:NSMakeRange(0, 2)]);
                return [NSString stringWithFormat:@"%c%@", literalCombineChar, [unEscapeString substringFromIndex:2]];
            }
        }
        
    } else {
        return [NSString stringWithFormat:@"%c%@", literalFirstChar, [unEscapeString substringFromIndex:1]];
    }
}

NSString *analyzeUnEscapeString(NSString *unEscapeString) {
    if (unEscapeString.length == 0) {
        return @"";
    }
    char firstChar = [unEscapeString characterAtIndex:0];
    if (firstChar == '\n') {
        return [unEscapeString substringFromIndex:1];
    }
    if (firstChar == '\''
        || firstChar == '"'
        || firstChar == '?'
        || firstChar == '\\') {
        return unEscapeString;
    }
    if (firstChar == 'a') {
        return [NSString stringWithFormat:@"\a%@", [unEscapeString substringFromIndex:1]];
    }
    if (firstChar == 'b') {
        return [NSString stringWithFormat:@"\b%@", [unEscapeString substringFromIndex:1]];
    }
    if (firstChar == 'f') {
        return [NSString stringWithFormat:@"\f%@", [unEscapeString substringFromIndex:1]];
    }
    if (firstChar == 'n') {
        return [NSString stringWithFormat:@"\n%@", [unEscapeString substringFromIndex:1]];
    }
    if (firstChar == 'r') {
        return [NSString stringWithFormat:@"\r%@", [unEscapeString substringFromIndex:1]];
    }
    if (firstChar == 't') {
        return [NSString stringWithFormat:@"\t%@", [unEscapeString substringFromIndex:1]];
    }
    if (firstChar == 'v') {
        return [NSString stringWithFormat:@"\v%@", [unEscapeString substringFromIndex:1]];
    }
    if (firstChar == 'x') {
        return analyzeUnEscapeStringWithHexEscape([unEscapeString substringFromIndex:1]);
    }
    if (firstChar == 'u') {
        if (unEscapeString.length < 5) {
            return @"";
        }
        NSString *unEscapeUnicodeString = [NSString stringWithFormat:@"\\%@", [unEscapeString substringWithRange:NSMakeRange(0, 5)]];
        return [NSString stringWithFormat:@"%@%@", escapeUnicodeStringToLiteral(unEscapeUnicodeString), [unEscapeString substringFromIndex:5]];
    }
    if (firstChar == 'U') {
        if (unEscapeString.length < 9) {
            return @"";
        }
        NSString *unEscapeUnicodeString = [NSString stringWithFormat:@"\\%@", [unEscapeString substringWithRange:NSMakeRange(0, 9)]];
        return [NSString stringWithFormat:@"%@%@", escapeUnicodeStringToLiteral(unEscapeUnicodeString), [unEscapeString substringFromIndex:9]];
    }
    return anylyzeUnEscapeStringWithOctalEscape(unEscapeString);
}

// http://en.cppreference.com/w/cpp/language/escape
// http://www.asciitable.com/
NSString *getLiteralStringFromUnEscapeString(NSString *unEscapeString) {
    NSArray <NSString *>*topParts = [unEscapeString componentsSeparatedByString:@"\\\\"];
    NSMutableString *topLiteralString = [NSMutableString new];
    [topParts enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *unEscapeString = obj;
        NSArray <NSString *>*parts = [unEscapeString componentsSeparatedByString:@"\\"];
        NSMutableString *literalString = [NSMutableString new];
        [parts enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *escapeString = obj;
            if (idx > 0) {
                escapeString = analyzeUnEscapeString(obj);
            }
            [literalString appendString:escapeString];
        }];
        if (idx > 0) {
            [topLiteralString appendString:@"\\"];
        }
        [topLiteralString appendString:literalString];
    }];
    return topLiteralString;
}

NSString *getUnEscapeStringFromEscapeString(NSString *unEscapeString) {
    // TODO
    return @"";
}
