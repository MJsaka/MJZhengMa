//
//  Dict_String_Transform.m
//  MJZhengMa
//
//  Created by MJsaka on 15/2/14.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import "MJDict.h"
#import "DictStringTransfer.h"

@implementation DictStringTransfer


-(NSComparator)MJDictCompare{
    return ^(id obj1,id obj2)
    {
        NSString* codeString1 = [obj1 codeString];
        NSString* codeString2 = [obj2 codeString ];
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
}

-(NSComparator)MJFreqCompare{
    return ^(id obj1,id obj2)
    {
        double wordFreq1 = [obj1 wordFrequency];
        double wordFreq2 = [obj2 wordFrequency];
        if (wordFreq1 > wordFreq2)
            return NSOrderedAscending;
        else if (wordFreq1 < wordFreq2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    };
}

-(NSMutableArray*)xmDictArrayFromString:(NSString*)dictString hasCode:(Boolean)hasCode hasWord:(Boolean)hasWord hasFreq:(Boolean)hasFreq{
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
        if ([array count] > 3) {
            continue;
        }
        MJXMDict* dict = [MJXMDict alloc];
        NSInteger i = 0;
        if (hasCode) {
            [dict setCodeString:[array objectAtIndex:i]];
            ++i;
        }
        if (hasWord) {
            [dict setWordString:[array objectAtIndex:i]];
            ++i;
        }
        if (hasFreq) {
            [dict setWordFrequency:[[array objectAtIndex:i] doubleValue]];
            ++i;
        }
        [_originalDictionary addObject:dict];
    }
    return [NSMutableArray arrayWithArray:[_originalDictionary sortedArrayUsingComparator:[self MJDictCompare]]];
}

-(NSMutableArray*)engDictArrayFromString:(NSString*)dictString hasCode:(Boolean)hasCode hasWord:(Boolean)hasWord hasFreq:(Boolean)hasFreq{
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
        if ([array count] > 3) {
            continue;
        }
        MJENDict* dict = [MJENDict alloc];
        NSInteger i = 0;
        if (hasCode) {
            [dict setCodeString:[array objectAtIndex:i]];
            ++i;
        }
        if (hasWord) {
            [dict setWordString:[array objectAtIndex:i]];
            ++i;
        }
        if (hasFreq) {
            [dict setWordFrequency:[[array objectAtIndex:i] doubleValue]];
            ++i;
        }
        [_originalDictionary addObject:dict];
    }
    return [NSMutableArray arrayWithArray:[_originalDictionary sortedArrayUsingComparator:[self MJDictCompare]]];
}

-(NSMutableArray*)pyDictArrayFromString:(NSString*)dictString hasCode:(Boolean)hasCode hasWord:(Boolean)hasWord hasFreq:(Boolean)hasFreq hasXMCode:(Boolean)hasXMCode{
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
        if ([array count] > 4) {
            continue;
        }
        MJPYDict* dict = [MJPYDict alloc];
        NSInteger i = 0;
        if (hasCode) {
            [dict setCodeString:[array objectAtIndex:i]];
            ++i;
        }
        if (hasWord) {
            [dict setWordString:[array objectAtIndex:i]];
            ++i;
        }
        if (hasFreq) {
            [dict setWordFrequency:[[array objectAtIndex:i] doubleValue]];
            ++i;
        }
        if (hasXMCode) {
            [dict setXmCodeString:[array objectAtIndex:i]];
            ++i;
        }
        [_originalDictionary addObject:dict];
    }
    return [NSMutableArray arrayWithArray:[_originalDictionary sortedArrayUsingComparator:[self MJDictCompare]]];
}

-(NSString*)stringFromMJDictArray:(NSArray*)array hasCode:(Boolean)hasCode hasWord:(Boolean)hasWord hasFreq:(Boolean)hasFreq hasXMCode:(Boolean)hasXMCode{
    NSMutableString* _dictString = [NSMutableString string];
    
    for (NSInteger i = 0; i < [array count]; ++i) {
        if (hasCode) {
            [_dictString appendFormat:@"%@ ",[[array objectAtIndex:i]codeString]];
        }
        if (hasWord) {
            [_dictString appendFormat:@"%@ ",[[array objectAtIndex:i]wordString]];
        }
        if (hasFreq) {
            [_dictString appendFormat:@"%G",[[array objectAtIndex:i]wordFrequency]];
        }
        if (hasXMCode) {
            [_dictString appendFormat:@" %@",[[array objectAtIndex:i]xmCodeString]];
        }
        [_dictString appendString:@"\n"];
    }
    return _dictString;
}



@end
