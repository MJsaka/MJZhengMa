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


@implementation MJInputController{
    
    NSMutableString*                _originalBuffer;
    NSMutableString*                _wordBuffer;
    
    NSInteger                       _originalCount;
    NSInteger                       _wordCount;
    
    MJConversionEngine*             _conversionEngine;
    MJCandidatesPanel*              _candidatesPanel;
    
    NSMutableArray*                 _candidates;
    NSMutableArray*                 _candidatesTips;
    NSMutableArray*                 _candidatesClasses;
    
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



-(id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self) {
        _originalBuffer  = [NSMutableString stringWithString:@""];
        _originalCount = 0;
        _wordBuffer  = [NSMutableString stringWithString:@""];
        _wordCount = 0;
        
        _conversionEngine = [[NSApp delegate] conversionEngine];
        _candidatesPanel = [[NSApp delegate] candidatePanel];
        
        _candidates = nil;
        _candidatesTips = nil;
        
        
        _hasKeyDownBetweenModifier= YES;
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
    return NSKeyDownMask | NSFlagsChangedMask | NSMouseMovedMask;
}

-(BOOL)handleEvent:(NSEvent*)event client:(id)sender{
    BOOL handled = NO;
    NSUInteger modifiers = [event modifierFlags];
    NSInteger keyCode = [event keyCode];
    switch ([event type]) {
        case NSFlagsChanged:
        {
            if (_lastModifier == OSX_SHIFT_MASK && modifiers == 0 && !_hasKeyDownBetweenModifier)
            {
                _isEnglishMode = _isEnglishMode?NO:YES;
                _hasKeyDownBetweenModifier = YES;
                if (_isEnglishMode) {
                    [_currentClient insertText:_originalBuffer replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
                    [self resetCreatWordState];
                    [self resetTransformState];
                }
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
                break;
            }
            if (modifiers & NSCommandKeyMask ||
                modifiers & NSControlKeyMask ||
                modifiers & NSAlternateKeyMask ||
                modifiers & NSAlphaShiftKeyMask)
            {
                [self resetTransformState];
                break;
            }
            if ( modifiers == NSShiftKeyMask && keyCode == OSX_VK_SPACE && _originalCount == 0) {
                [self triggerCreatWord];
                handled = YES;
                break;
            }
            if( keyCode == OSX_VK_BACK_SPACE )
            {
                handled = [self deleteBackward];
                break;
            }
            if( keyCode == OSX_VK_ENTER )
            {
                if (_isCreatWordMode && _originalCount == 0) {
                    [self triggerCreatWord];
                    handled = YES;
                } else if (_originalCount != 0){
                    [_currentClient insertText:_originalBuffer replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
                    [self resetTransformState];
                    handled = YES;
                }
                break;
            }
            if ( keyCode == OSX_VK_ESCAPE && _originalCount != 0){
                [self resetTransformState];
                break;
            }
            if (_candidatesCount != 0){
                if (keyCode == OSX_VK_PAGE_UP || keyCode == OSX_VK_LEFT || keyCode == OSX_VK_MINUS){
                    [self MJcandidateSelectionChanged:PAGE_PRE];
                    handled = YES;
                    break;
                }else if (keyCode == OSX_VK_PAGE_DOWN || keyCode == OSX_VK_RIGHT || keyCode == OSX_VK_EQUALS){
                    [self MJcandidateSelectionChanged:PAGE_NEXT];
                    handled = YES;
                    break;
                }else if (keyCode == OSX_VK_UP){
                    [self MJcandidateSelectionChanged:SELECTION_PRE];
                    handled = YES;
                    break;
                }else if (keyCode == OSX_VK_DOWN){
                    [self MJcandidateSelectionChanged:SELECTION_NEXT];
                    handled = YES;
                    break;
                }
            }
            NSString* keyChars = [event charactersIgnoringModifiers];
            NSScanner* scanner = [NSScanner scannerWithString:keyChars];

            if ([scanner scanCharactersFromSet:[NSCharacterSet lowercaseLetterCharacterSet] intoString:nil])
            {//小写字母
                [self originalBufferAppend:keyChars];
                if (_candidatesCount == 0 && _originalCount != 1) {
                    [self updateMarkedText];
                }else{
                    [self updateCandidatesForNew:YES];
                }
                handled = YES;
            }else if(keyCode == OSX_VK_SPACE)
            {//空格
                if(_originalCount != 0)
                {
                    if (_candidatesCount != 0) {
                        if (_isCreatWordMode) {
                            [self wordBufferAppend:[_candidates objectAtIndex:_candidatesSelectedIndex]];
                        } else {
                            [_currentClient insertText:[_candidates objectAtIndex:_candidatesSelectedIndex] replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
                        }
                    }
                    [self resetTransformState];
                    handled = YES;
                }
            }else if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil]){//数字键
                
                unichar achar = [keyChars characterAtIndex:0];
                NSUInteger count = MIN(_candidatesCount,9);
                if (_originalCount != 0) {
                    if (_candidatesCount != 0 && achar >= '1' && achar <= '0' + count){
                        [self MJcandidateSelected:(achar - '1')];
                    }
                    handled = YES;
                }
            }else if ( [scanner scanCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:nil] ||
                      [scanner scanCharactersFromSet:[NSCharacterSet symbolCharacterSet] intoString:nil])
            {//标点符号
                if (_originalCount == 0) {
                    NSInteger index;
                    if ( modifiers & NSShiftKeyMask){
                        index = keyCode - 18;
                    }else{
                        index = keyCode + 9;
                    }
                    NSString* puncOrSymbol = [_conversionEngine fullPunctuationOrSymbolAtIndex:index];
                    if (![puncOrSymbol isEqualToString:@"0"]) {
                        [_currentClient insertText:puncOrSymbol replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
                    }
                }
                handled = YES;
            }else{
                [self resetTransformState];
                handled = NO;
            }
            break;
        }
        case NSMouseMoved:{
            _hasKeyDownBetweenModifier = YES;
            break;
        }
        default:
            handled = NO;
            break;
    }
    _lastModifier = modifiers;
    return handled;
}

-(void)triggerCreatWord
{
    if (_isCreatWordMode) {
        NSString* word = [self wordBuffer];
        [_currentClient insertText:word replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        if ( ![word isEqualToString:@""] ) {
            [_conversionEngine creatWord:word];
        }
        [self resetCreatWordState];
        [self resetTransformState];
    }else{
        [self resetTransformState];
        _isCreatWordMode = YES;
    }
}

-(NSMutableString*)originalBuffer{
    return _originalBuffer;
}
-(void)setOriginalBuffer:(NSString*)string{
    [_originalBuffer setString:string];
    _originalCount = [_originalBuffer length];
}
-(void)originalBufferAppend:(NSString*)string{
    [_originalBuffer appendString: string];
    _originalCount = [_originalBuffer length];
}

-(NSMutableString*)wordBuffer{
    return _wordBuffer;
}
-(void)setWordBuffer:(NSString*)string{
    [_wordBuffer setString:string];
    _wordCount = [_wordBuffer length];
}
-(void)wordBufferAppend:(NSString*)string{
    [_wordBuffer appendString: string];
    _wordCount = [_wordBuffer length];
}

- (BOOL)deleteBackward
{
    if (_originalCount > 0) {
        [_originalBuffer deleteCharactersInRange:NSMakeRange(_originalCount-1,1)];
        _originalCount --;
        if (_originalCount == 0){
            [self resetTransformState];
        }else{
            [self updateCandidatesForNew:YES];
        }
        return YES;
    }else if( _wordCount > 0 ){
        [_wordBuffer deleteCharactersInRange:NSMakeRange(_wordCount-1,1)];
        _wordCount--;
        [self updateMarkedText];
        return YES;
    }
    return NO;
}

-(void)updateMarkedText{
    NSMutableString* text = [NSMutableString stringWithString:@""];
    if(_isCreatWordMode){
        [text appendString:_wordBuffer];
    }
    [text appendString:_originalBuffer];
    [_currentClient setMarkedText:text selectionRange:NSMakeRange(NSNotFound,NSNotFound) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
}

-(void)resetTransformState{
    [self setOriginalBuffer:@""];
    
    _candidates = nil;
    _candidatesTips = nil;
    
    _lastModifier = 0;
    
    _candidatesCount = 0;
    _candidatesShowIndex = 0;
    _candidatesSelectedIndex = 0;
    
    [_candidatesPanel hide];
    [self updateMarkedText];
}

-(void)resetCreatWordState{
    [self setWordBuffer:@""];
    _isCreatWordMode = NO;
}


- (void)updateCandidatesForNew:(Boolean)generateNewCandidates{
    if (generateNewCandidates) {
        [self updateMarkedText];
        _candidatesTips = [NSMutableArray arrayWithCapacity:0];
        _candidates = [NSMutableArray arrayWithCapacity:0];
        _candidatesClasses = [NSMutableArray arrayWithCapacity:0];
        [_conversionEngine generateCandidates:_candidates andTips:_candidatesTips andCandidatesClass:_candidatesClasses forOriginString:_originalBuffer];
        _candidatesSelectedIndex = 0;
        _candidatesShowIndex = 0;
        _candidatesCount = [_candidates count];
    }
    if (_candidatesCount == 0) {
        [_candidatesPanel hide];
        return;
    }else if (_candidatesCount == 1 && _originalCount == 4){
        if (_isCreatWordMode) {
            [self wordBufferAppend:[_candidates objectAtIndex:_candidatesSelectedIndex]];
        } else {
            [_currentClient insertText:[_candidates objectAtIndex:_candidatesSelectedIndex] replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        }
        [self resetTransformState];
        return;
    }
    [_currentClient attributesForCharacterIndex:0 lineHeightRectangle:&_inputPos] ;
    NSArray* candidates = [_candidates subarrayWithRange:NSMakeRange(_candidatesShowIndex, MIN(_candidatesCount - _candidatesShowIndex,9))];
    NSArray* tips = [_candidatesTips subarrayWithRange:NSMakeRange(_candidatesShowIndex, MIN(_candidatesCount - _candidatesShowIndex,9))];
    NSArray* classes = [_candidatesClasses subarrayWithRange:NSMakeRange(_candidatesShowIndex, MIN(_candidatesCount - _candidatesShowIndex,9))];

    [_candidatesPanel updateCandidates:candidates withTips:tips withClasses:classes atPosition:_inputPos selectIndex:_candidatesSelectedIndex - _candidatesShowIndex];
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
        [self updateCandidatesForNew:NO];
    }
}
-(void)MJcandidateSelected:(NSUInteger)index{
    _candidatesSelectedIndex = _candidatesShowIndex + index;
    NSString* candidateString = [_candidates objectAtIndex:_candidatesSelectedIndex];
    if (_isCreatWordMode) {
        [self wordBufferAppend:candidateString];
    } else {
        [_currentClient insertText:candidateString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
    if (_originalCount > 2 && _originalCount < 5 && [_candidatesClasses objectAtIndex:_candidatesSelectedIndex] == [MJXMDict class]) {
        [_conversionEngine adjustFreqForWord:candidateString originString:_originalBuffer];
    }
    [self resetTransformState];
}

- (void)activateServer:(id)sender
{
    _currentClient = sender;
    [self resetTransformState];
}
- (void)deactivateServer:(id)sender
{
    [self resetTransformState];
    [_conversionEngine saveDictToFile];
}
@end
