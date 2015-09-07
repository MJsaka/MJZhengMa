//
//  DictProcess.m
//  MJZhengMa
//
//  Created by MJsaka on 15/2/13.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "DictProcess.h"
#import "Dict_String.h"
#import "MJDict.h"
#import "MJCodeGenerator.h"

@implementation DictProcess

-(void) awakeFromNib{
    codeGenerator = [[MJCodeGenerator alloc] init];
}

-(IBAction)selectTextFile:(id)sender {
    NSOpenPanel *theOpenPanel = [NSOpenPanel openPanel];
    [theOpenPanel setTitle:@"Select Text File"];
    if ([theOpenPanel runModal] == NSModalResponseOK)
    {
        NSString* theFileName = [theOpenPanel filename];
        _stringOfTextFile = [NSString stringWithContentsOfFile:theFileName encoding:NSUTF8StringEncoding error:NULL];
        [_textView setString:_stringOfTextFile];
    }
}
-(IBAction)selectDictFile:(id)sender {
    NSOpenPanel *theOpenPanel = [NSOpenPanel openPanel];
    [theOpenPanel setTitle:@"Select Dict File"];
    if ([theOpenPanel runModal] == NSModalResponseOK)
    {
        NSString* theFileName = [theOpenPanel filename];
        _stringOfXMDictFile = [NSString stringWithContentsOfFile:theFileName encoding:NSUTF8StringEncoding error:NULL];
        NSArray* array = xmDictArrayFromDictString(_stringOfXMDictFile);
        _stringOfTextFile = stringFromXMDictArray(array);
        [_textView setString:_stringOfTextFile];
    }
}

-(IBAction)selectXMDZDictFile:(id)sender {
    NSOpenPanel *theOpenPanel = [NSOpenPanel openPanel];
    [theOpenPanel setTitle:@"Select Dict File"];
    if ([theOpenPanel runModal] == NSModalResponseOK)
    {
        NSString* theFileName = [theOpenPanel filename];
        NSString* _stringOfXMDZDictFile = [NSString stringWithContentsOfFile:theFileName encoding:NSUTF8StringEncoding error:NULL];
        _arrayOfXMDZDict = xmDictArrayFromDictString(_stringOfXMDZDictFile);
    }
}


-(IBAction)selectPYDictFile:(id)sender {
    NSOpenPanel *theOpenPanel = [NSOpenPanel openPanel];
    [theOpenPanel setTitle:@"Select Dict File"];
    if ([theOpenPanel runModal] == NSModalResponseOK)
    {
        NSString* theFileName = [theOpenPanel filename];
        NSString* _stringOfPYDictFile = [NSString stringWithContentsOfFile:theFileName encoding:NSUTF8StringEncoding error:NULL];
        _arrayOfPYDict = pyDictArrayFromCodeWordFreqString(_stringOfPYDictFile);
    }
}

-(IBAction)establishDict:(id)sender{
    NSMutableArray* array = xmDictArrayFromWordFreqString(_stringOfTextFile);
    for (NSInteger i = 0; i < [array count]; ++i) {
        if ( ![codeGenerator generateCodeForDictElement:[array objectAtIndex:i]] ) {
            [array removeObjectAtIndex:i];
            --i;
        }
    }
    _stringOfXMDictFile = stringFromXMDictArray(array);
    [_textView setString:_stringOfXMDictFile];
    _stringOfTextFile = [NSString string];
}

-(IBAction)regenerateDict:(id)sender{
    ///*
    NSMutableArray* array = xmDictArrayFromDictString(_stringOfXMDictFile);
    /*
    for (NSInteger i = 0; i < [array count]; ++i) {
        [codeGenerator generateCodeForDictElement:[array objectAtIndex:i]];
    }
     */
    NSMutableArray* sArray = [NSMutableArray arrayWithArray: [array sortedArrayUsingComparator:MJXMDictCompare]];
    _stringOfTextFile = stringFromXMDictArray(sArray);
    _stringOfXMDictFile = _stringOfTextFile;
    [_textView setString:_stringOfXMDictFile];
    _stringOfTextFile = [NSString string];
    //*/
    //////////去除7个以上的重码//////////////////////////////////////
    //NSMutableArray* array = xmDictArrayFromDictString(_stringOfXMDictFile);
    
    /*
    NSInteger length = [sArray count] ;
    NSInteger count = 1;
    NSInteger i = 1 ;
    NSString* sentryString = [[sArray objectAtIndex:0] codeString];
    while (i < length) {
        NSString* string = [[sArray objectAtIndex:i] codeString];
        if ([string isEqualToString:sentryString]) {
            count ++;
        }else{
            sentryString = string ;
            count = 0;
        }
        if (count > 6 && [[[sArray objectAtIndex:i] wordString] length] > 1 ) {
            [sArray removeObjectAtIndex:i];
            --i;
            --length;
        }
        ++i;
    }
     */
//    _stringOfTextFile = stringFromXMDictArray(sArray);
//    _stringOfXMDictFile = _stringOfTextFile;
//    [_textView setString:_stringOfXMDictFile];
    ///////////////////////////////////////////////////////////////////
}

-(IBAction)appendFreq:(id)sender{
    NSMutableArray* array = xmDictArrayFromDictString(_stringOfTextFile);
    for (NSInteger i = 0; i < [array count]; ++i) {
        if ( ![codeGenerator apendWordFrequency:[array objectAtIndex:i]] ) {
            [[array objectAtIndex:i] setWordFrequency:0];
        }
    }
    _stringOfXMDictFile = stringFromXMDictArray(array);
    [_textView setString:_stringOfXMDictFile];
    _stringOfTextFile = [NSString string];
}

-(IBAction)appendZMCodeForPinYin:(id)sender{
    
    for (NSInteger i = 0; i < [_arrayOfPYDict count]; ++i) {
        NSMutableString * string = [NSMutableString stringWithString:@""];
        for (NSInteger j = 0; j < [_arrayOfXMDZDict count] ; ++j) {
            if ([[[_arrayOfPYDict objectAtIndex:i] wordString]
                 isEqualToString:
                 [[_arrayOfXMDZDict objectAtIndex:j] wordString]]) {
                [string appendFormat:@"%@|",[[_arrayOfXMDZDict objectAtIndex:j] codeString]];
            }
        }
        [[_arrayOfPYDict objectAtIndex:i] setXmCodeString:string];
    }
    _stringOfPYDict = stringFromPYDictArray(_arrayOfPYDict);
    [_textView setString:_stringOfPYDict];
}

-(IBAction)removeDuplicate:(id)sender{
    NSMutableArray* array = xmDictArrayFromDictString(_stringOfXMDictFile);
    for (NSInteger i=0; i<24543; ++i) {
        NSString* preString = [[array objectAtIndex:i] wordString];
        for (NSInteger j=24543; j<[array count]; ++j) {
            NSString* postString = [[array objectAtIndex:j] wordString];
            if ([preString isEqualToString:postString]) {
                [array removeObjectAtIndex:j];
                --j;
            }
        }
    }
    _stringOfXMDictFile = stringFromXMDictArray(array);
    [_textView setString:_stringOfXMDictFile];
}
-(IBAction)saveDictFile:(id)sender {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:nil];
    [savePanel setTitle:@"Save Dict File"];
    if ([savePanel runModal] == NSModalResponseOK) {
        [_stringOfXMDictFile writeToFile:[savePanel filename] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
}

-(IBAction)savePYDictFile:(id)sender {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:nil];
    [savePanel setTitle:@"Save Dict File"];
    if ([savePanel runModal] == NSModalResponseOK) {
        [_stringOfPYDict writeToFile:[savePanel filename] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
}

@end
