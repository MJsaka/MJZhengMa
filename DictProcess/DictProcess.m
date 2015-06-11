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
        _stringOfDictFile = [NSString stringWithContentsOfFile:theFileName encoding:NSUTF8StringEncoding error:NULL];
        [_textView setString:_stringOfDictFile];
    }
}

-(IBAction)establishDict:(id)sender{
    NSMutableArray* array = dictArrayFromTextString(_stringOfTextFile);
    for (NSInteger i = 0; i < [array count]; ++i) {
        if ( ![codeGenerator generateCodeForDictElement:[array objectAtIndex:i]] ) {
            [array removeObjectAtIndex:i];
            --i;
        }
    }
    _stringOfDictFile = stringFromDictArray(array);
    [_textView setString:_stringOfDictFile];
    _stringOfTextFile = [NSString string];
}

-(IBAction)regenerateDict:(id)sender{
    ///*
    NSMutableArray* array = dictArrayFromDictString(_stringOfDictFile);
    /*
    for (NSInteger i = 0; i < [array count]; ++i) {
        [codeGenerator generateCodeForDictElement:[array objectAtIndex:i]];
    }
     */
    NSMutableArray* sArray = [NSMutableArray arrayWithArray: [array sortedArrayUsingComparator:MJDictCompare]];
    _stringOfTextFile = stringFromDictArray(sArray);
    _stringOfDictFile = _stringOfTextFile;
    [_textView setString:_stringOfDictFile];
    _stringOfTextFile = [NSString string];
    //*/
    //////////去除7个以上的重码//////////////////////////////////////
    //NSMutableArray* array = dictArrayFromDictString(_stringOfDictFile);
    
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
    _stringOfTextFile = stringFromDictArray(sArray);
    _stringOfDictFile = _stringOfTextFile;
    [_textView setString:_stringOfDictFile];
    ///////////////////////////////////////////////////////////////////
}

-(IBAction)removeDuplicate:(id)sender{
    NSMutableArray* array = dictArrayFromDictString(_stringOfDictFile);
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
    _stringOfDictFile = stringFromDictArray(array);
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
