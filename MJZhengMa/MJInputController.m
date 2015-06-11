//
//  MJInputController.m
//  MJZhengMa
//
//  Created by MJsaka on 15/2/5.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MJInputController.h"
#import "MJAppDelegate.h"
#import "MJConversionEngine.h"

extern IMKCandidates*		candidates;

@interface MJInputController (){
    NSMutableString*                _composedBuffer;
    NSMutableString*                _originalBuffer;
    NSMutableString*                _wordBuffer;
    NSInteger                       _composedCount;
    NSInteger                       _transformedCount;
    MJConversionEngine*             _conversionEngine;
    MJDictIndexNodeType*            _currentIndexNode;
    id                              _currentClient;
    BOOL                            _isCreatWordMode;
}
@end

@implementation MJInputController

-(id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self) {
        _composedBuffer = [NSMutableString stringWithString:@""];
        _originalBuffer  = [NSMutableString stringWithString:@""];
        _wordBuffer  = [NSMutableString stringWithString:@""];
        _composedCount = 0;
        _transformedCount = 0;
        id appDelegate = [NSApp delegate];
        _conversionEngine = [appDelegate conversionEngine];
        _currentIndexNode = [_conversionEngine topLevelIndex];
        _isCreatWordMode = NO;
    }
    return self;
}
-(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender;
{//    NSLog(@"string:%@,keycode:%ld,modifiers:%ld",string,keyCode,flags);
    if ( flags & NSShiftKeyMask && keyCode == 49 ) {
        [self triggerCreatWord:sender];
        return YES;
    }
    if (flags & NSCommandKeyMask || flags & NSControlKeyMask || flags & NSAlternateKeyMask){
        [self resetTransformState:sender];
        return NO;
    }
    if( keyCode == 51 )
    {//BackSpace NSLog(@"BackSpace key");
       return [self deleteBackward:sender];
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:string];
    
    if ([scanner scanCharactersFromSet:[NSCharacterSet lowercaseLetterCharacterSet] intoString:nil])
    {//小写字母 NSLog(@"lowercaseLetter");
        [self originalBufferAppend:string];
        [self transform:sender];
        return YES;
    }else if( [string isEqual: @" "] )
    {//空格
        if ( [[self originalBuffer] isEqual: @""])
        {
            return NO;
        }else
        {
            [self commitComposition:_currentClient];
            return YES;
        }
    }else if ( [scanner scanCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:nil] ||
              [scanner scanCharactersFromSet:[NSCharacterSet symbolCharacterSet] intoString:nil])
    {//标点符号 NSLog(@"punctuation");
        [self commitComposition:_currentClient];
        if (!(flags & NSAlphaShiftKeyMask))
        {
            NSInteger index;
            if ( flags & NSShiftKeyMask){
                index = keyCode - 18;
            }else{
                index = keyCode + 9;
            }
            NSString* puncOrSymbol = [_conversionEngine fullPunctuationOrSymbolAtIndex:index];
            if ([puncOrSymbol isNotEqualTo:@"0"]) {
                [sender insertText:puncOrSymbol replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
                return YES;
            }
            return NO;
        }
        return NO;
    }else if ( [scanner scanCharactersFromSet:[NSCharacterSet uppercaseLetterCharacterSet] intoString:nil] )
    {//大写字母：CapsLock按下时为英文模式，但接收到的全是大写字母
        [self commitComposition:_currentClient];
         if ((flags & NSAlphaShiftKeyMask) && (! (flags & NSShiftKeyMask) ) )
        {//Shift键未按下时应转为小写字母 NSLog(@"upper caps");
            unichar achar = [string characterAtIndex:0];
            unichar bchar ;
            bchar = (unichar)(achar + 32);
            NSString* bstring = [NSString stringWithFormat:@"%c",bchar];
            [sender insertText:bstring replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
            return YES;
        }
        return NO;
    }else
    {//    NSLog(@"no entry");
        [self resetTransformState:sender];
        return NO;
    }
}

-(void)commitComposition:(id)sender
{
    if (_currentIndexNode != [_conversionEngine topLevelIndex])
    {
        [self composedBufferAppend:[[[[candidates selectedCandidateString] string]componentsSeparatedByString:@":"] objectAtIndex:0]];
    }
    NSString* text = [self composedBuffer];
    if ( ![text isEqualToString:@""] ){
        [sender insertText:text replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        if (_isCreatWordMode) {
            [self wordBufferAppend:text];
        }
        [self resetTransformState:sender];
    }
}

-(void)triggerCreatWord:(id)sender
{
    if (_isCreatWordMode) {
        [self commitComposition:sender];
        NSString* word = [self wordBuffer];
        if ( ![word isEqualToString:@""] ) {
            [_conversionEngine creatWord:word];
        }
        [self resetCreatWordState:sender];
        [self resetTransformState:sender];
    }else{
        [self resetTransformState:sender];
        _isCreatWordMode = YES;
    }
}

-(NSMutableString*)composedBuffer;{
    return _composedBuffer;
}
-(void)setComposedBuffer:(NSString*)string{
    [[self composedBuffer] setString:string];
}
-(void)composedBufferAppend:(NSString*)string{
    [[self composedBuffer] appendString: string];
}


-(NSMutableString*)originalBuffer{
    return _originalBuffer;
}
-(void)setOriginalBuffer:(NSString*)string{
    [[self originalBuffer] setString:string];
}
-(void)originalBufferAppend:(NSString*)string{
    [[self originalBuffer] appendString: string];
}

-(NSMutableString*)wordBuffer{
    return _wordBuffer;
}
-(void)setWordBuffer:(NSString*)string{
    [[self wordBuffer] setString:string];
}
-(void)wordBufferAppend:(NSString*)string{
    [[self wordBuffer] appendString: string];
}

- (BOOL)deleteBackward:(id)sender
{
    NSMutableString*        originalText = [self originalBuffer];
    NSInteger   orgLength = [originalText length];
    
    if (orgLength > 0) {
        [originalText deleteCharactersInRange:NSMakeRange(orgLength-1,1)];
        [self setComposedBuffer:@""];
        _transformedCount = 0;
        _composedCount = 0;
        _currentIndexNode = [_conversionEngine topLevelIndex];
        if (orgLength == 1){
            [candidates hide];
            [sender setMarkedText:@"" selectionRange:NSMakeRange(0,0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
        }else
            [self transform:sender];
        return YES;
    }else {
        NSMutableString* wordText = [self wordBuffer];
        NSInteger wordLength = [wordText length];
        if( wordLength > 0 )
            [wordText deleteCharactersInRange:NSMakeRange(wordLength-1,1)];
        return NO;
    }
}

-(void)updateMarkedText:(id)sender{
    NSString*        composedText = [self composedBuffer];
    NSString*        originalText = [self originalBuffer];
    NSString*        text = [NSString stringWithFormat:@"%@%@",composedText,[originalText substringFromIndex:_composedCount],nil];
    [sender setMarkedText:text selectionRange:NSMakeRange(NSNotFound,NSNotFound) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
}
-(void)resetTransformState:(id)sender{
    [self setComposedBuffer:@""];
    [self setOriginalBuffer:@""];
    _composedCount = 0;
    _transformedCount = 0;
    _currentIndexNode = [_conversionEngine topLevelIndex];
    _currentClient = sender;
    [self updateMarkedText:sender];
    [candidates hide];
}
-(void)resetCreatWordState:(id)sender{
    [self setWordBuffer:@""];
    _isCreatWordMode = NO;
}

-(void)transform:(id)sender{
    NSString*   originalText = [self originalBuffer];
    NSInteger   orgLength = [originalText length];
    while ( _transformedCount < orgLength )
    {
        unichar achar = [originalText characterAtIndex:_transformedCount];
        MJDictIndexNodeType* nextIndexNode = [_currentIndexNode nextLevelIndexNode:achar - 'a'];
        if ( [nextIndexNode indexCount]  == 1 )
        {//NSLog(@"uniq compose");
            [self composedBufferAppend:[_conversionEngine wordAtDictIndex:[nextIndexNode indexStart]]];
            _currentIndexNode = [_conversionEngine topLevelIndex];
            _composedCount = _transformedCount + 1;
        }else if( nextIndexNode == nil )
        {//NSLog(@"auto compose");
            [self composedBufferAppend:[_conversionEngine wordAtDictIndex:[_currentIndexNode indexStart]]];
            _composedCount = _transformedCount;
            _currentIndexNode = [_conversionEngine topLevelIndex];
            _transformedCount --;
        }else
        {//NSLog(@"normal key");
            _currentIndexNode = nextIndexNode;
        }
        _transformedCount ++;
    }
    [self updateMarkedText:_currentClient];
    if (_composedCount == _transformedCount){
        //All composed, hide candidatesWindow
        [candidates hide];
    }else{
        [candidates updateCandidates];
        [candidates show:kIMKLocateCandidatesBelowHint];
    }
}

- (NSArray*)candidates:(id)sender
{
    NSMutableArray* theCandidates = [NSMutableArray arrayWithCapacity:0];
    NSInteger level = [_currentIndexNode indexLevel];
    NSInteger begin = [_currentIndexNode indexStart];
    NSInteger end = [_currentIndexNode indexEnd];
    if (level == 4)
    {
        for (NSInteger i=begin ; i<=end ; ++i)
        {
            [theCandidates addObject:[_conversionEngine wordAtDictIndex:i]];
        }
    }else
    {
        for (NSInteger i=begin ; i<=end ; ++i)
        {
            if ([[_conversionEngine codeAtDictIndex:i] length] == level) {
                [theCandidates addObject:[_conversionEngine wordAtDictIndex:i]];
            }else
                break;
        }
        for (NSInteger i=0 ; i<26 ; ++i)
        {
            if ([_currentIndexNode nextLevelIndexNode:i] != nil) {
                NSInteger index = [[_currentIndexNode nextLevelIndexNode:i] indexStart];
                NSString* string = [NSString stringWithFormat:@"%@:%@",[_conversionEngine wordAtDictIndex:index],[[_conversionEngine codeAtDictIndex:index]substringWithRange:NSMakeRange(level, 1)]];
                [theCandidates addObject:string];
            }
        }
    }
    return theCandidates;
}
- (void)candidateSelectionChanged:(NSAttributedString*)candidateString
{
}

- (void)candidateSelected:(NSAttributedString*)candidateString
{
    NSString* string = [[[candidateString string] componentsSeparatedByString:@":"] objectAtIndex:0];
    NSInteger start = [_currentIndexNode indexStart];
    NSInteger end = [_currentIndexNode indexEnd];
    NSInteger level = [_currentIndexNode indexLevel];
    NSInteger i = start;
    while( i < end )
    {
        if([[_conversionEngine wordAtDictIndex:i] isEqual:string]){
            break;
        }
        if([[_conversionEngine codeAtDictIndex:i] length] > level){
            break;
        }
        ++i;
    }
    if ( [[_conversionEngine wordAtDictIndex:i] isEqualToString:string]
        && [[_conversionEngine codeAtDictIndex:i] length] == level )
    {
        [_conversionEngine adjustFreqForWordAtIndex:i startIndex:start];
    }
    [self commitComposition:_currentClient];
}

- (void)activateServer:(id)sender
{
    [self resetTransformState:sender];
}
- (void)deactivateServer:(id)sender
{
    [self resetTransformState:sender];
    [_conversionEngine saveDictToFile];
}
@end
