//
//  DictProcess.m
//  MJZhengMa
//
//  Created by MJsaka on 15/2/13.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "DictProcess.h"
#import "MJDict.h"
#import "MJCodeGenerator.h"

@implementation DictProcess

-(void) awakeFromNib{
    codeGenerator = [[MJCodeGenerator alloc] init];
    _dictStringTransformer = [[DictStringTransfer alloc] init];
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

-(IBAction)generateArrayOfXMDict:(id)sender{
    _arrayOfXMDict = [_dictStringTransformer xmDictArrayFromString:_stringOfTextFile hasCode:YES hasWord:YES hasFreq:YES];

}
-(IBAction)generateArrayOfPYDict:(id)sender{
    _arrayOfPYDict = [_dictStringTransformer pyDictArrayFromString:_stringOfTextFile hasCode:YES hasWord:YES hasFreq:YES hasXMCode:NO];
}


-(IBAction)generateCodeForXMDict:(id)sender{
    NSMutableArray* array = [_dictStringTransformer xmDictArrayFromString:_stringOfTextFile hasCode:YES hasWord:YES hasFreq:YES];
    for (NSInteger i = 0; i < [array count]; ++i) {
        MJXMDict* dict = [array objectAtIndex:i];
        if ([[dict wordString] length] == 3) {
            [codeGenerator generateCodeForDictElement:dict];
        }
    }
    _stringOfDictFile = [_dictStringTransformer stringFromMJDictArray:array hasCode:YES hasWord:YES hasFreq:YES hasXMCode:NO];
    [_textView setString:_stringOfDictFile];
}

-(IBAction)sortXMDict:(id)sender{
    ///*
    NSMutableArray* array = [_dictStringTransformer xmDictArrayFromString:_stringOfTextFile hasCode:YES hasWord:YES hasFreq:YES];
    NSMutableArray* sArray = [NSMutableArray arrayWithArray: [array sortedArrayUsingComparator:[_dictStringTransformer MJDictCompare]]];
    _stringOfDictFile = [_dictStringTransformer stringFromMJDictArray:sArray hasCode:YES hasWord:YES hasFreq:YES hasXMCode:NO];
    [_textView setString:_stringOfDictFile];
}

-(IBAction)sortPYDict:(id)sender{
    NSMutableArray* array = [_dictStringTransformer pyDictArrayFromString:_stringOfTextFile hasCode:YES hasWord:YES hasFreq:YES hasXMCode:YES];
    NSMutableArray* sArray = [NSMutableArray arrayWithArray: [array sortedArrayUsingComparator:[_dictStringTransformer MJDictCompare]]];
    _stringOfDictFile = [_dictStringTransformer stringFromMJDictArray:sArray hasCode:YES hasWord:YES hasFreq:YES hasXMCode:YES];
    [_textView setString:_stringOfDictFile];
}

-(IBAction)appendFreqForXMDict:(id)sender{
    NSMutableArray* array = [_dictStringTransformer xmDictArrayFromString:_stringOfTextFile hasCode:YES hasWord:YES hasFreq:NO];
    for (NSInteger i = 0; i < [array count]; ++i) {
        if ( ![codeGenerator apendWordFrequency:[array objectAtIndex:i]] ) {
            [[array objectAtIndex:i] setWordFrequency:0];
        }
    }
    _stringOfDictFile = [_dictStringTransformer stringFromMJDictArray:array hasCode:YES hasWord:YES hasFreq:YES hasXMCode:NO];
    [_textView setString:_stringOfDictFile];
}

-(IBAction)appendXMCodeForPY:(id)sender{
    
    for (NSInteger i = 0; i < [_arrayOfPYDict count]; ++i) {
        NSMutableString * string = [NSMutableString stringWithString:@""];
        for (NSInteger j = 0; j < [_arrayOfXMDict count] ; ++j) {
            if ([[[_arrayOfPYDict objectAtIndex:i] wordString]
                 isEqualToString:
                 [[_arrayOfXMDict objectAtIndex:j] wordString]]) {
                [string appendFormat:@"%@|",[[_arrayOfXMDict objectAtIndex:j] codeString]];
            }
        }
        [[_arrayOfPYDict objectAtIndex:i] setXmCodeString:string];
    }
    _stringOfDictFile = [_dictStringTransformer stringFromMJDictArray:_arrayOfPYDict hasCode:YES hasWord:YES hasFreq:YES hasXMCode:YES];
    [_textView setString:_stringOfDictFile];
}


-(IBAction)saveDictFile:(id)sender {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:nil];
    [savePanel setTitle:@"Save Dict File"];
    if ([savePanel runModal] == NSModalResponseOK) {
        [_stringOfDictFile writeToFile:[savePanel filename] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
}

@end
