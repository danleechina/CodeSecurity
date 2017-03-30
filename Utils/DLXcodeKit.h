//
//  DLXcodeKit.h
//  CodeSecurity
//
//  Created by Dan.Lee on 2017/3/30.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XcodeKit/XcodeKit.h>
#ifndef DLXcodeKit_h
#define DLXcodeKit_h

BOOL isSelectedText(NSArray<XCSourceTextRange *>*selections);
BOOL isOCHeaderOrSourceFile(NSString *uti);
NSArray *getSelectedStrings(NSArray *lines, NSArray *selections);
NSString *getAnUniqueRandomStringForBuffer(XCSourceTextBuffer *buffer);
NSArray<NSTextCheckingResult *> *getRegexMatchResult(NSString *string, NSString *regex);
NSInteger getStartLine(NSString *string, NSRange range);
NSInteger getLineCount(NSString *string, NSRange range);
NSRange getLineRange(NSString *string, NSRange range);
void replace(NSMutableArray<NSString *>* lines, XCSourceTextRange *inRange, NSString *withReplacedString);

#endif /* DLXcodeKit_h */
