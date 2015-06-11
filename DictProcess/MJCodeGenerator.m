//
//  MJCodeGenerator.m
//  MJ郑码
//
//  Created by MJsaka on 15/3/7.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MJCodeGenerator.h"

@interface MJCodeGenerator(){
    NSMutableDictionary* _gouCiDict;
}
@end
@implementation MJCodeGenerator

-(id) init {
    self = [super init];
    if (self) {
        _gouCiDict = [NSMutableDictionary dictionaryWithCapacity:0];
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
            [_gouCiDict setValue:[array objectAtIndex:1] forKey:[array objectAtIndex:0]];
        }
    }
    return self;
}

-(BOOL)generateCodeForDictElement:(MJDict*)dict{
    NSString* wordString = [dict wordString];
    NSInteger wordLength = [wordString length];
    NSMutableString* codeString = [NSMutableString string];
    if (wordLength < 2) {
        return NO;
    }
    for (NSInteger i=0; i<wordLength; ++i) {
        if ( ![_gouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(i, 1)]] ) {
            return NO;
        }
    }
    if (wordLength == 2) {
        [codeString appendFormat:@"%@%@",
         [_gouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(0, 1)]],
         [_gouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(1, 1)]]];
    }else if ( wordLength == 3 ) {
        [codeString appendFormat:@"%@%@%@",
         [[_gouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(0, 1)]] substringWithRange:NSMakeRange(0, 1)],
         [[_gouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(1, 1)]] substringWithRange:NSMakeRange(0, 1)],
         [_gouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(2, 1)]]];
    }else {
        [codeString appendFormat:@"%@%@%@%@",
         [[_gouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(0, 1)]] substringWithRange:NSMakeRange(0, 1)],
         [[_gouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(1, 1)]] substringWithRange:NSMakeRange(0, 1)],
         [[_gouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(2, 1)]] substringWithRange:NSMakeRange(0, 1)],
         [[_gouCiDict objectForKey:[wordString substringWithRange:NSMakeRange(3, 1)]] substringWithRange:NSMakeRange(0, 1)]];
    }
    [dict setCodeString:codeString];
    return YES;
}
@end
