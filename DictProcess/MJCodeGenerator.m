//
//  MJCodeGenerator.m
//  MJ郑码
//
//  Created by MJsaka on 15/3/7.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MJCodeGenerator.h"


@implementation MJCodeGenerator{
    NSMutableDictionary* _ZMGouCiDict;
    NSMutableDictionary* _ZMDanZiCiPinDict;
}

-(id) init {
    self = [super init];
    if (self) {
        _ZMGouCiDict = [NSMutableDictionary dictionaryWithCapacity:0];
        NSBundle* _bundle= [NSBundle mainBundle];
        NSString  *pathOfGouCiFile=[_bundle pathForResource:@"GouCi" ofType:@"txt"];
        NSString* gouciDictFileString = [NSString stringWithContentsOfFile:pathOfGouCiFile encoding:NSUTF8StringEncoding error:NULL];
        NSUInteger length = [gouciDictFileString length];
        NSUInteger startIndex = 0;
        NSUInteger endIndex = 0;
        NSUInteger constentsEndIndex = 0;
        while ( endIndex < length ){
            [gouciDictFileString getLineStart:&startIndex end:&endIndex contentsEnd:&constentsEndIndex forRange:NSMakeRange(endIndex, 1)];
            //get a line of one transformdict
            NSString* stringLine = [NSString stringWithString:[gouciDictFileString substringWithRange:NSMakeRange(startIndex, constentsEndIndex-startIndex)]];
            //divide line to an array
            NSArray* array = [stringLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [_ZMGouCiDict setValue:[array objectAtIndex:1] forKey:[array objectAtIndex:0]];
        }
        
        _ZMDanZiCiPinDict = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString *pathOfDanZiCiPinFile=[_bundle pathForResource:@"zmdzcipin" ofType:@"txt"];
        NSString* ciPinDictFileString = [NSString stringWithContentsOfFile:pathOfDanZiCiPinFile encoding:NSUTF8StringEncoding error:NULL];
        length = [ciPinDictFileString length];
        startIndex = 0;
        endIndex = 0;
        constentsEndIndex = 0;
        while ( endIndex < length ){
            [ciPinDictFileString getLineStart:&startIndex end:&endIndex contentsEnd:&constentsEndIndex forRange:NSMakeRange(endIndex, 1)];
            //get a line of one transformdict
            NSString* stringLine = [NSString stringWithString:[ciPinDictFileString substringWithRange:NSMakeRange(startIndex, constentsEndIndex-startIndex)]];
            //divide line to an array
            NSArray* array = [stringLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [_ZMDanZiCiPinDict setValue:[array objectAtIndex:1] forKey:[array objectAtIndex:0]];
        }
        
    }
    return self;
}
-(Boolean)apendWordFrequency:(MJXMDict*)dict{
    NSString* wordString = dict.wordString;
    NSString* wordFreqString = [_ZMDanZiCiPinDict objectForKey:wordString];
    if (wordFreqString != nil ) {
        double freq = [wordFreqString doubleValue];
        dict.wordFrequency = freq;
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)generateCodeForDictElement:(MJXMDict*)dict{
    NSString* wordString = [dict wordString];
    NSInteger wordLength = [wordString length];
    NSMutableString* codeString = [NSMutableString string];
    if (wordLength < 2) {
        return NO;
    }
    for (NSInteger i=0; i<wordLength; ++i) {
        if ( ![_ZMGouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(i, 1)]] ) {
            return NO;
        }
    }
    if (wordLength == 2) {
        [codeString appendFormat:@"%@%@",
         [_ZMGouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(0, 1)]],
         [_ZMGouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(1, 1)]]];
    }else if ( wordLength == 3 ) {
        [codeString appendFormat:@"%@%@%@",
         [[_ZMGouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(0, 1)]] substringWithRange:NSMakeRange(0, 1)],
         [[_ZMGouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(1, 1)]] substringWithRange:NSMakeRange(0, 1)],
         [_ZMGouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(2, 1)]]];
    }else {
        [codeString appendFormat:@"%@%@%@%@",
         [[_ZMGouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(0, 1)]] substringWithRange:NSMakeRange(0, 1)],
         [[_ZMGouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(1, 1)]] substringWithRange:NSMakeRange(0, 1)],
         [[_ZMGouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(2, 1)]] substringWithRange:NSMakeRange(0, 1)],
         [[_ZMGouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(3, 1)]] substringWithRange:NSMakeRange(0, 1)]];
    }
    dict.codeString = codeString;
    return YES;
}
@end
