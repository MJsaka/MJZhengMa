//
//  Dict_String_Transform.m
//  MJZhengMa
//
//  Created by MJsaka on 15/2/14.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dict_String.h"
NSComparator  MJDictCompare = ^(id obj1,id obj2)
{
    NSString* codeString1 = [obj1 codeString];
    NSString* codeString2 = [obj2 codeString];
    NSComparisonResult _result = [codeString1 compare:codeString2];
    if ( _result != NSOrderedSame )
        return _result;
    else{
        double wordFreq1 = [obj1 wordFrequency];
        double wordFreq2 = [obj2 wordFrequency];
        if (wordFreq1 > wordFreq2)
            return NSOrderedAscending;
        else if (wordFreq1 < wordFreq2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }
};

NSMutableArray* dictArrayFromTextString(NSString* string){
    NSMutableArray* _originalDictionary = [NSMutableArray array];
    NSUInteger length = [string length];
    NSUInteger startIndex = 0;
    NSUInteger endIndex = 0;
    NSUInteger constentsEndIndex = 0;
    while ( endIndex < length ){
        [string getLineStart:&startIndex end:&endIndex contentsEnd:&constentsEndIndex forRange:NSMakeRange(endIndex, 1)];
        //get a line of one transformdict
        NSString* stringLine = [NSString stringWithString:[string substringWithRange:NSMakeRange(startIndex, constentsEndIndex-startIndex)]];
        //divide line to an array
        NSArray* array = [stringLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([array count] != 2) {
            continue;
        }
        MJDict* dict = [[MJDict alloc] init];
        [dict setWordString:[array objectAtIndex:0]];
        [dict setWordFrequency:[[array objectAtIndex:1] doubleValue]];
        [_originalDictionary addObject:dict];
    }
    return _originalDictionary;
//    return [NSMutableArray arrayWithArray:[_originalDictionary sortedArrayUsingComparator:MJDictCompare]];
}

NSMutableArray* dictArrayFromDictString(NSString* dictString){
    NSMutableArray* _originalDictionary = [NSMutableArray array];
    NSUInteger length = [dictString length];
    NSUInteger startIndex = 0;
    NSUInteger endIndex = 0;
    NSUInteger constentsEndIndex = 0;
    while ( endIndex < length ){
        [dictString getLineStart:&startIndex end:&endIndex contentsEnd:&constentsEndIndex forRange:NSMakeRange(endIndex, 1)];
        //get a line of one transformdict
        NSString* stringLine = [NSString stringWithString:[dictString substringWithRange:NSMakeRange(startIndex, constentsEndIndex-startIndex)]];
        //divide line to an array
        NSArray* array = [stringLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([array count] != 3) {
            continue;
        }
        MJDict* dict = [[MJDict alloc] init];
        [dict setCodeString:[array objectAtIndex:0]];
        [dict setWordString:[array objectAtIndex:1]];
        [dict setWordFrequency:[[array objectAtIndex:2] doubleValue]];
        [_originalDictionary addObject:dict];
    }
    return _originalDictionary;
}

NSString* stringFromDictArray(NSArray* array){
    NSMutableString* _dictString = [NSMutableString string];
    for (NSInteger i = 0; i < [array count]; ++i) {
        [_dictString appendFormat:@"%@ %@ %G\n",[[array objectAtIndex:i]codeString],[[array objectAtIndex:i]wordString],[[array objectAtIndex:i]wordFrequency]];
    }
    return _dictString;
}
