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
#import "MJCandidatesPanel.h"
#import "MacOS_KeyCode.h"


@interface MJInputController (){
    NSMutableString*                _composedBuffer;
    NSMutableString*                _originalBuffer;
    NSMutableString*                _wordBuffer;
    
    NSInteger                       _composedCount;
    NSInteger                       _transformedCount;
    
    MJConversionEngine*             _conversionEngine;
    MJCandidatesPanel*              _candidatesPanel;
    MJDictIndexNodeType*            _currentIndexNode;
    NSMutableArray*                 _candidates;
    NSMutableArray*                 _candidatesTips;
    
    id                              _currentClient;
    NSRect                          _inputPos;
    
    Boolean                         _hasKeyDownBetweenModifier;
    NSUInteger                      _lastModifier;
    Boolean                         _isCreatWordMode;
    Boolean                         _isEnglishMode;
    
    NSUInteger                       _candidatesCount;
    NSUInteger                       _candidatesShowIndex;
    NSUInteger                       _candidatesSelectedIndex;
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
        
        _conversionEngine = [[NSApp delegate] conversionEngine];
        _candidatesPanel = [[NSApp delegate] candidatePanel];
        _currentIndexNode = [_conversionEngine topLevelIndex];
        
        _candidates = nil;
        _candidatesTips = nil;
        
        _hasKeyDownBetweenModifier= NO;
        _isCreatWordMode = NO;
        _isEnglishMode = NO;
        
        _candidatesCount = 0;
        _candidatesShowIndex = 0;
        _candidatesSelectedIndex = 0;
    }
    return self;
}

-(NSUInteger)recognizedEvents:(id)sender
{
    return NSKeyDownMask | NSFlagsChangedMask;
}

-(BOOL)handleEvent:(NSEvent*)event client:(id)sender{
    BOOL handled = NO;
    NSUInteger modifiers = [event modifierFlags];
    NSInteger keyCode = [event keyCode];
    switch ([event type]) {
        case NSFlagsChanged:
        {
            NSUInteger changes = modifiers ^ _lastModifier;
            if (changes == OSX_SHIFT_MASK && !_hasKeyDownBetweenModifier)
            {
                _isEnglishMode = _isEnglishMode?NO:YES;
                _hasKeyDownBetweenModifier = YES;
                [self commitOrigin:sender];
                handled = YES;
                break;
            }
            _hasKeyDownBetweenModifier = NO;
            break;
        }
        case NSKeyDown:
        {
            _hasKeyDownBetweenModifier = YES;
            if (_isEnglishMode) {
                handled = NO;
                break;
            }
            if (modifiers & NSCommandKeyMask ||
                modifiers & NSControlKeyMask ||
                modifiers & NSAlternateKeyMask ||
                modifiers & NSAlphaShiftKeyMask)
            {
                [self resetTransformState:sender];
                handled = NO;
                break;
            }
            if ( modifiers == NSShiftKeyMask && keyCode == OSX_VK_SPACE ) {
                [self triggerCreatWord:sender];
                handled = YES;
                break;
            }
            if( keyCode == OSX_VK_BACK_SPACE )
            {
                handled = [self deleteBackward:sender];
                break;
            }
            if( keyCode == OSX_VK_ENTER )
            {
                if (_transformedCount == 0) {
                    handled = NO;
                }else{
                    [self commitOrigin:sender];
                    handled = YES;
                }
                break;
            }
            NSString* keyChars = [event charactersIgnoringModifiers];
            NSScanner* scanner = [NSScanner scannerWithString:keyChars];

            if ([scanner scanCharactersFromSet:[NSCharacterSet lowercaseLetterCharacterSet] intoString:nil])
            {//小写字母
                if (modifiers == NSShiftKeyMask) {
                    _isEnglishMode = YES;
                    if (_transformedCount != 0) {
                        [self commitComposition:sender];
                    }
                    handled = NO;
                }else{
                    [self originalBufferAppend:keyChars];
                    [self transform:sender];
                    handled = YES;
                }
                break;
            }else if ( [scanner scanCharactersFromSet:[NSCharacterSet uppercaseLetterCharacterSet] intoString:nil] )
            {//大写字母：进入英文模式
                _isEnglishMode = YES;
                if (_transformedCount != 0) {
                    [self commitComposition:sender];
                }
                handled = NO;
                break;
            }else if( [keyChars isEqual: @" "] )
            {//空格
                if ( _transformedCount == 0 )
                {
                    handled = NO;
                    break;
                }else
                {
                    [self commitComposition:_currentClient];
                    handled = YES;
                    break;
                }
            }else if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil]){//数字键
                
                unichar achar = [keyChars characterAtIndex:0];
                NSUInteger count = MIN(_candidatesCount - _candidatesShowIndex,9);
                if (_transformedCount != 0 && achar >= '1' && achar <= '0' + count){
                    [self MJcandidateSelected:(achar - '1')];
                    handled = YES;
                    break;
                }else{
                    handled = NO;
                    break;
                }
            }else if ( [scanner scanCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:nil] ||
                      [scanner scanCharactersFromSet:[NSCharacterSet symbolCharacterSet] intoString:nil])
            {//标点符号
                unichar achar = [keyChars characterAtIndex:0];
                if (_transformedCount != 0 && achar == '-'){
                    [self MJcandidateSelectionChanged:PAGE_PRE];
                    handled = YES;
                    break;
                }else if (_transformedCount != 0 && achar == '='){
                    [self MJcandidateSelectionChanged:PAGE_NEXT];
                    handled = YES;
                    break;
                }else{
                    [self commitComposition:_currentClient];
                    NSInteger index;
                    if ( modifiers & NSShiftKeyMask){
                        index = keyCode - 18;
                    }else{
                        index = keyCode + 9;
                    }
                    NSString* puncOrSymbol = [_conversionEngine fullPunctuationOrSymbolAtIndex:index];
                    if ([puncOrSymbol isNotEqualTo:@"0"]) {
                        [sender insertText:puncOrSymbol replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
                        handled = YES;
                        break;
                    }
                    handled = NO;
                    break;
                }
            }else{
                [self resetTransformState:sender];
                handled = NO;
                break;
            }
        }
        default:
            handled = NO;
            break;
    }
    _lastModifier = modifiers;
    return handled;
}

-(void)commitOrigin:(id)sender{

    NSString* text = [self originalBuffer];
    if ( ![text isEqualToString:@""] ){
        [sender insertText:text replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        if (_isCreatWordMode) {
            [self resetCreatWordState:sender];
        }
        [self resetTransformState:sender];
    }
}
    
-(void)commitComposition:(id)sender
{

    if (_currentIndexNode != [_conversionEngine topLevelIndex]){
        [self composedBufferAppend:[_candidates objectAtIndex:_candidatesSelectedIndex]];
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
            [_candidatesPanel hide];
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
    
    _candidates = nil;
    _candidatesTips = nil;
    
    _lastModifier = 0;
    
    _candidatesCount = 0;
    _candidatesShowIndex = 0;
    _candidatesSelectedIndex = 0;
    
    [self updateMarkedText:sender];
    [_candidatesPanel hide];
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
        {
            [self composedBufferAppend:[_conversionEngine wordAtDictIndex:[nextIndexNode indexStart]]];
            _currentIndexNode = [_conversionEngine topLevelIndex];
            _composedCount = _transformedCount + 1;
        }else if( nextIndexNode == nil )
        {
            [self composedBufferAppend:[_conversionEngine wordAtDictIndex:[_currentIndexNode indexStart]]];
            _composedCount = _transformedCount;
            _currentIndexNode = [_conversionEngine topLevelIndex];
            _transformedCount --;
        }else
        {
            _currentIndexNode = nextIndexNode;
        }
        _transformedCount ++;
    }
    [self updateMarkedText:_currentClient];
    if (_composedCount == _transformedCount){
        //All composed, hide candidatesWindow
        [_candidatesPanel hide];
    }else{
        [self updateCandidates:YES];
    }
}
- (void)updateCandidates:(Boolean)generateNewCandidates{
    if (generateNewCandidates) {
        _candidatesTips = [NSMutableArray arrayWithCapacity:0];
        _candidates = [NSMutableArray arrayWithCapacity:0];
        [self generateCandidates:_candidates andTips:_candidatesTips];
        _candidatesSelectedIndex = 0;
        _candidatesShowIndex = 0;
    }
    [_currentClient attributesForCharacterIndex:0 lineHeightRectangle:&_inputPos] ;
    NSArray* candidates = [_candidates subarrayWithRange:NSMakeRange(_candidatesShowIndex, MIN(_candidatesCount - _candidatesShowIndex,9))];
    NSArray* tips = [_candidatesTips subarrayWithRange:NSMakeRange(_candidatesShowIndex, MIN(_candidatesCount - _candidatesShowIndex,9))];

    [_candidatesPanel updateCandidates:candidates withTips:tips atPosition:_inputPos selectIndex:_candidatesSelectedIndex - _candidatesShowIndex];
}
- (void)generateCandidates:(NSMutableArray*)candidates andTips:(NSMutableArray*)tips
{
    NSInteger level = [_currentIndexNode indexLevel];
    NSInteger begin = [_currentIndexNode indexStart];
    NSInteger end = [_currentIndexNode indexEnd];
    if(level == 1 ){
        for (NSInteger i=begin ; i<=end ; ++i)
        {
            if ([[_conversionEngine codeAtDictIndex:i] length] == level) {
                [candidates addObject:[_conversionEngine wordAtDictIndex:i]];
                [tips addObject:@""];
            }else{
                break;
            }
        }
        for (NSInteger i=0 ; i<26 ; ++i)
        {
            if ([_currentIndexNode nextLevelIndexNode:i] != nil) {
                NSInteger index = [[_currentIndexNode nextLevelIndexNode:i] indexStart];
                [candidates addObject:[_conversionEngine wordAtDictIndex:index]];
                [tips addObject:[NSString stringWithFormat:@"[%@]",[[_conversionEngine codeAtDictIndex:index]substringWithRange:NSMakeRange(level, 1)]]];
            }
        }
    }else{
        for (NSInteger i=begin ; i<=end ; ++i)
        {
            [candidates addObject:[_conversionEngine wordAtDictIndex:i]];
            if ([[_conversionEngine codeAtDictIndex:i] length] == level) {
                [tips addObject:@""];
            }else{
                [tips addObject:[NSString stringWithFormat:@"[%@]",[[_conversionEngine codeAtDictIndex:i]substringWithRange:NSMakeRange(level, 1)]]];
            }
        }
    }
    _candidatesCount = [candidates count];


}

-(void)MJcandidateSelectionChanged:(CandidatesSelectChangeType)control{
    NSInteger currentShowIndex = _candidatesShowIndex;
    NSInteger currentSelectIndex = _candidatesSelectedIndex;
    switch (control) {
        case PAGE_NEXT:
            if(_candidatesShowIndex + 9 < _candidatesCount){
                _candidatesShowIndex += 9;
                _candidatesSelectedIndex = _candidatesShowIndex;
            }
            break;
        case PAGE_PRE:
            if (_candidatesShowIndex >= 9){
                _candidatesShowIndex -= 9;
            }else{
                _candidatesShowIndex = 0;
            }
            _candidatesSelectedIndex = _candidatesShowIndex;
            break;
        case SELECTION_NEXT:
            if(_candidatesSelectedIndex + 1 < _candidatesCount){
                _candidatesSelectedIndex += 1;
                if (_candidatesSelectedIndex == _candidatesShowIndex + 9) {
                    _candidatesShowIndex += 9;
                }
            }
            break;
        case SELECTION_PRE:
            if (_candidatesSelectedIndex > 0) {
                _candidatesSelectedIndex -= 1;
                if (_candidatesSelectedIndex < _candidatesShowIndex) {
                    if (_candidatesShowIndex >= 9){
                        _candidatesShowIndex -= 9;
                    }else{
                        _candidatesShowIndex = 0;
                    }
                }
            }
            break;
        default:
            break;
    }

    if (currentShowIndex != _candidatesShowIndex || currentSelectIndex != _candidatesSelectedIndex) {
        [self updateCandidates:NO];
    }
}
-(void)MJcandidateSelected:(NSUInteger)index{
    _candidatesSelectedIndex = _candidatesShowIndex + index;

    NSString* candidateString = [_candidates objectAtIndex:_candidatesSelectedIndex];
    NSInteger start = [_currentIndexNode indexStart];
    NSInteger end = [_currentIndexNode indexEnd];
    NSInteger level = [_currentIndexNode indexLevel];
    NSInteger i = start;
    while( i < end )
    {
        if([[_conversionEngine wordAtDictIndex:i] isEqual:candidateString]){
            break;
        }
        if([[_conversionEngine codeAtDictIndex:i] length] > level){
            break;
        }
        ++i;
    }
    if ( [[_conversionEngine wordAtDictIndex:i] isEqualToString:candidateString]
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
