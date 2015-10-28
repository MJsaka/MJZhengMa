//
//  MJConversionEngine.m
//  MJZhengMa
//
//  Created by MJsaka on 15/2/9.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "MJConversionEngine.h"
#import "MJDict.h"
#import "DictStringTransfer.h"
#import "MJCodeGenerator.h"


@implementation MJConversionEngine{
    NSMutableArray* _xmDictArray;
    NSArray* _pyDictArray;
    NSArray* _engDictArray;
    NSArray* _dictArray;
    const NSArray* _fullPunctuationOrSymbolArray;
    
    DictStringTransfer* _dictStringTransfer;
    MJCodeGenerator* _codeGenerator;
    MJDictIndexNodeType _dictIndex[3][26][27][27];
    MJDictIndexNodeType _currentIndex[3];
    BOOL _dictModified;
}

-(void)findIndexOfInputString:(NSString*)string{
    for (NSInteger i = 0; i < 3; ++i) {
        _currentIndex[i].startIndex = -1;
        _currentIndex[i].endIndex = -2;
    }
    NSInteger length = [string length];
    if (length >= 3) {
        NSInteger n = [string characterAtIndex:0] - 'a';
        NSInteger m = [string characterAtIndex:1] - 'a';
        NSInteger l = [string characterAtIndex:2] - 'a';
        for (NSInteger i = 0; i < 3; ++i) {
            _currentIndex[i] = _dictIndex[i][n][m][l];
        }
    }else if(length == 2){
        NSInteger n = [string characterAtIndex:0] - 'a';
        NSInteger m = [string characterAtIndex:1] - 'a';
        for (NSInteger i = 0; i < 3; ++i) {
            _currentIndex[i] = _dictIndex[i][n][m][26];
        }
    }else if (length == 1) {
        NSInteger n = [string characterAtIndex:0] - 'a';
        for (NSInteger i = 0; i < 3; ++i) {
            _currentIndex[i] = _dictIndex[i][n][26][26];
        }
    }
    if (length == 4 && _currentIndex[0].startIndex != -1) {
        Boolean findStartIndex = NO;
        Boolean findEndIndex = NO;
        while ([[[_xmDictArray objectAtIndex:_currentIndex[0].startIndex] codeString] length] < 4) {
            _currentIndex[0].startIndex++;
        }
        for (NSInteger i = _currentIndex[0].startIndex; i <= _currentIndex[0].endIndex && !findEndIndex; ++i) {
            NSString* str = [[_xmDictArray objectAtIndex:i] codeString];
            if (!findStartIndex && [str isEqualToString:string]) {
                findStartIndex = YES;
                _currentIndex[0].startIndex = i;
            }else if(findStartIndex && ![str isEqualToString:string]){
                findEndIndex = YES;
                _currentIndex[0].endIndex = i - 1;
            }
        }
        if (!findStartIndex) {
            _currentIndex[0].startIndex = -1;
            _currentIndex[0].endIndex = -2;
        }
    }else if (length > 4){
        _currentIndex[0].startIndex = -1;
        _currentIndex[0].endIndex = -2;
    }
    if(length > 0 && length < 7 && _currentIndex[1].startIndex != -1){ //PY
        Boolean findStartIndex = NO;
        Boolean findEndIndex = NO;

        while ([[[_pyDictArray objectAtIndex:_currentIndex[1].startIndex] codeString] length] < length) {
            _currentIndex[1].startIndex++;
        }

        for (NSInteger i = _currentIndex[1].startIndex; i <= _currentIndex[1].endIndex && !findEndIndex; ++i) {
            NSString* str = [[_pyDictArray objectAtIndex:i] codeString];
            if (!findStartIndex && [str isEqualToString:string]) {
                findStartIndex = YES;
                _currentIndex[1].startIndex = i;
            }else if(findStartIndex && ![str isEqualToString:string]){
                findEndIndex = YES;
                _currentIndex[1].endIndex = i - 1;
            }
        }
        if (!findStartIndex){
            for (NSInteger i = _currentIndex[1].startIndex; i <= _currentIndex[1].endIndex && !findEndIndex; ++i) {
                NSString* str = [[_pyDictArray objectAtIndex:i] codeString];
                if (!findStartIndex && [str hasPrefix:string]) {
                    findStartIndex = YES;
                    _currentIndex[1].startIndex = i;
                }else if(findStartIndex && ![str hasPrefix:string]){
                    findEndIndex = YES;
                    _currentIndex[1].endIndex = i - 1;
                }
            }
            if (!findStartIndex) {
                _currentIndex[1].startIndex = -1;
                _currentIndex[1].endIndex = -2;
            }
        }
    }else if (length >= 7){
        _currentIndex[1].startIndex = -1;
        _currentIndex[1].endIndex = -2;
    }
    if(length > 0 && _currentIndex[2].startIndex != -1){ //Eng
        Boolean findStartIndex = NO;
        Boolean findEndIndex = NO;
        while ([[[_engDictArray objectAtIndex:_currentIndex[2].startIndex] codeString] length] < length) {
            _currentIndex[2].startIndex++;
        }
        for (NSInteger i = _currentIndex[2].startIndex; i <= _currentIndex[2].endIndex && !findEndIndex; ++i) {
            NSString* str = [[_engDictArray objectAtIndex:i] codeString];
            if (!findStartIndex && [str hasPrefix:string]) {
                findStartIndex = YES;
                _currentIndex[2].startIndex = i;
            }else if(findStartIndex && ![str hasPrefix:string]){
                findEndIndex = YES;
                _currentIndex[2].endIndex = i - 1;
            }
        }
        if (!findStartIndex) {
            _currentIndex[2].startIndex = -1;
            _currentIndex[2].endIndex = -2;
        }
    }
}



- (void)generateCandidates:(NSMutableArray*)candidates andTips:(NSMutableArray*)tips andCandidatesClass:(NSMutableArray *)candidatesClasses forOriginString:(NSString *)originString
{
    [self findIndexOfInputString:originString];
//    NSLog(@"xm...start:%ld,end:%ld\npy...start:%ld,end:%ld\neng...start:%ld,end:%ld",_currentIndex[0].startIndex,_currentIndex[0].endIndex,_currentIndex[1].startIndex,_currentIndex[1].endIndex,_currentIndex[2].startIndex,_currentIndex[2].endIndex);
    NSInteger xmStartIndex = _currentIndex[0].startIndex;
    if (_currentIndex[0].startIndex != -1){
        while(_currentIndex[0].startIndex <= _currentIndex[0].endIndex &&[[[_xmDictArray objectAtIndex:_currentIndex[0].startIndex] codeString] length] == [originString length]) {
            [candidates addObject:[[_xmDictArray objectAtIndex:_currentIndex[0].startIndex] wordString]];
            [tips addObject:@""];
            [candidatesClasses addObject:[MJXMDict class]];
            _currentIndex[0].startIndex++;
        }
    }
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = 0; i < 3; ++i) {
        if (_currentIndex[i].startIndex != -1) {
            for (NSInteger j = _currentIndex[i].startIndex; j <= _currentIndex[i].endIndex; ++j){
                [array addObject:[[_dictArray objectAtIndex:i] objectAtIndex:j]];
            }
        }
    }
    [array sortUsingComparator:[_dictStringTransfer MJFreqCompare]];
    for (NSInteger i = 0; i < [array count]; ++i) {
        [candidates addObject:[[array objectAtIndex:i] wordString]];
        if ([[array objectAtIndex:i] class] == [MJXMDict class]) {
            [candidatesClasses addObject:[MJXMDict class]];
            if ([originString length] < 4) {
                [tips addObject:[[[array objectAtIndex:i] codeString] substringFromIndex:[originString length]]];
            }
        }else if ([[array objectAtIndex:i] class] == [MJENDict class]){
            [candidatesClasses addObject:[MJENDict class]];
            [tips addObject:@""];
        }else{
            [candidatesClasses addObject:[MJPYDict class]];
            [tips addObject:[NSString stringWithFormat:@"[%@]",[[array objectAtIndex:i] xmCodeString]]];
        }
    }
    _currentIndex[0].startIndex = xmStartIndex;
}

-(void)adjustFreqForWord:(NSString*)string originString:(NSString *)originString{
    NSInteger index = -1;
    for (NSInteger i = _currentIndex[0].startIndex; i <= _currentIndex[0].endIndex; ++i){
        if ([[[_xmDictArray objectAtIndex:i] wordString] isEqualToString:string] && [[[_xmDictArray objectAtIndex:i] codeString] isEqualToString:originString]){
            index = i;
        }
        if ([[[_xmDictArray objectAtIndex:i] codeString] length] > [originString length]) {
            break;
        }
    }
    if (index != -1) {
        [self adjustFreqForWordAtIndex:index startIndex:_currentIndex[0].startIndex];
    }
}

-(void)adjustFreqForWordAtIndex:(NSInteger)index startIndex:(NSInteger)start{
    double startDictFreq = [[_xmDictArray objectAtIndex:start] wordFrequency];
    double indexDictFreq = [[_xmDictArray objectAtIndex:index] wordFrequency];
    indexDictFreq = indexDictFreq * (1.01 + log(startDictFreq/indexDictFreq));
    [[_xmDictArray objectAtIndex:index] setWordFrequency:indexDictFreq];
    NSInteger insetIndex = index - 1;
    while (insetIndex >= start && indexDictFreq > [[_xmDictArray objectAtIndex:insetIndex] wordFrequency] )
    {
        --insetIndex;
    }
    for (NSInteger i=index-1; i>insetIndex ; --i) {
        [_xmDictArray exchangeObjectAtIndex:i withObjectAtIndex:i+1];
    }
    _dictModified = YES;
}

-(BOOL)isWordExist:(MJXMDict*)dict{
    NSString* code = [dict codeString];
    NSString* word = [dict wordString];
    NSInteger length = [code length];
    [self findIndexOfInputString:code];
    if (_currentIndex[0].startIndex != -1) {
        for (NSInteger index = _currentIndex[0].startIndex; index <= _currentIndex[0].endIndex; ++index) {
            NSString* wordString = [[_xmDictArray objectAtIndex:index] wordString];
            if ([word isEqualToString:wordString]) {
                return YES;
            }
        }
    }
    return NO;
}
-(void)creatWord:(NSString*)word{
    MJXMDict* dict = [[MJXMDict alloc] init];
    dict.wordString = word;
    dict.wordFrequency = 100;
    if ( ![_codeGenerator generateCodeForDictElement:dict] ) return;
    //判断该词是否存在
    if ([self isWordExist:dict]) return;
    //找到该词的插入点
    [self findIndexOfInputString:[[dict codeString] substringToIndex:2]];
    NSInteger index = [_xmDictArray indexOfObject:dict inSortedRange:NSMakeRange(_currentIndex[0].startIndex,_currentIndex[0].endIndex - _currentIndex[0].startIndex) options:NSBinarySearchingInsertionIndex | NSBinarySearchingLastEqual usingComparator:[_dictStringTransfer MJDictCompare]];
    [_xmDictArray insertObject:dict atIndex:index];
    _dictModified = YES;
    [self initIndex];
}

-(NSString*)fullPunctuationOrSymbolAtIndex:(NSInteger)index{
    return [_fullPunctuationOrSymbolArray objectAtIndex:index];
}



-(void)initDictArray{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSString* pathOfBaseDict;
    if ([fileManager isReadableFileAtPath:[@"~/.config/MJZhengMa/Base.txt" stringByExpandingTildeInPath]]) {
        pathOfBaseDict = [@"~/.config/MJZhengMa/Base.txt" stringByExpandingTildeInPath];
    }else{
        NSBundle* _bundle = [NSBundle mainBundle];
        pathOfBaseDict = [_bundle pathForResource:@"Base" ofType:@"txt"];
    }
    NSString* baseDictFileString = [NSString stringWithContentsOfFile:pathOfBaseDict encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray* _xmDict = [_dictStringTransfer xmDictArrayFromString:baseDictFileString hasCode:YES hasWord:YES hasFreq:YES];
    _xmDictArray = _xmDict;
    
    
    NSString* pathOfPYDict;
    if ([fileManager isReadableFileAtPath:[@"~/.config/MJZhengMa/PYDict.txt" stringByExpandingTildeInPath]]) {
        pathOfPYDict = [@"~/.config/MJZhengMa/PYDict.txt" stringByExpandingTildeInPath];
    }else{
        NSBundle* _bundle = [NSBundle mainBundle];
        pathOfPYDict = [_bundle pathForResource:@"PYDict" ofType:@"txt"];
    }
    NSString* pyDictFileString = [NSString stringWithContentsOfFile:pathOfPYDict encoding:NSUTF8StringEncoding error:nil];
    _pyDictArray = [_dictStringTransfer pyDictArrayFromString:pyDictFileString hasCode:YES hasWord:YES hasFreq:YES hasXMCode:YES];
    
    
    NSString* pathOfEngDict;
    if ([fileManager isReadableFileAtPath:[@"~/.config/MJZhengMa/EngDict.txt" stringByExpandingTildeInPath]]) {
        pathOfEngDict = [@"~/.config/MJZhengMa/EngDict.txt" stringByExpandingTildeInPath];
    }else{
        NSBundle* _bundle = [NSBundle mainBundle];
        pathOfEngDict = [_bundle pathForResource:@"EngDict" ofType:@"txt"];
    }
    NSString* engDictFileString = [NSString stringWithContentsOfFile:pathOfEngDict encoding:NSUTF8StringEncoding error:nil];
    _engDictArray = [_dictStringTransfer engDictArrayFromString:engDictFileString hasCode:YES hasWord:YES hasFreq:YES];
    
    _dictArray = [NSArray arrayWithObjects:_xmDictArray,_pyDictArray,_engDictArray,nil];
}



-(void)initIndex{
    for (NSInteger d = 0; d < 3; ++d) {
        for (NSInteger i = 0; i < 26; ++i) {
            for (NSInteger j = 0; j < 27; ++j) {
                for(NSInteger k = 0; k < 27; ++k) {
                    _dictIndex[d][i][j][k].startIndex = -1;
                    _dictIndex[d][i][j][k].endIndex = -2;
                }
            }
        }
    }
    for (NSInteger d = 0; d < 3; ++d) {
        //level 1
        NSInteger iStart = 0;
        NSInteger iEnd = [[_dictArray objectAtIndex:d] count] - 1;
        NSInteger iindex = [[[[_dictArray objectAtIndex:d] objectAtIndex:iStart] codeString] characterAtIndex:0] - 'a';
        _dictIndex[d][iindex][26][26].startIndex = iStart;
        for (NSInteger iitr = iStart; iitr <= iEnd; ++iitr) {
            NSInteger ic = [[[[_dictArray objectAtIndex:d] objectAtIndex:iitr] codeString] characterAtIndex:0] - 'a';
            if (iindex != ic){
                _dictIndex[d][iindex][26][26].endIndex = iitr - 1;
                iindex = ic;
                _dictIndex[d][iindex][26][26].startIndex = iitr;
            }
        }
        _dictIndex[d][iindex][26][26].endIndex = iEnd;
        
        
        //level 2
        for (NSInteger i = 0; i < 26; ++i) {
            NSInteger jStart = _dictIndex[d][i][26][26].startIndex;
            NSInteger jEnd = _dictIndex[d][i][26][26].endIndex;
            if (jStart == -1) {
                continue;
            }
            while ([[[[_dictArray objectAtIndex:d] objectAtIndex:jStart] codeString] length] < 2) {
                jStart++;
            }
            NSInteger jindex = [[[[_dictArray objectAtIndex:d] objectAtIndex:jStart] codeString] characterAtIndex:1] - 'a';
            _dictIndex[d][i][jindex][26].startIndex = jStart;
            for (NSInteger jitr = jStart; jitr <= jEnd; ++jitr) {
                NSInteger jc = [[[[_dictArray objectAtIndex:d] objectAtIndex:jitr] codeString] characterAtIndex:1] - 'a';
                if (jindex != jc){
                    _dictIndex[d][i][jindex][26].endIndex = jitr - 1;
                    jindex = jc;
                    _dictIndex[d][i][jindex][26].startIndex = jitr;
                }
            }
            _dictIndex[d][i][jindex][26].endIndex = jEnd;
            
            
            //level 3
            for (NSInteger j = 0; j < 26; ++j) {
                NSInteger kStart = _dictIndex[d][i][j][26].startIndex;
                NSInteger kEnd = _dictIndex[d][i][j][26].endIndex;
                if (kStart == -1) {
                    continue;
                }
                while ([[[[_dictArray objectAtIndex:d] objectAtIndex:kStart] codeString] length] < 3) {
                    kStart++;
                }
                NSInteger kindex = [[[[_dictArray objectAtIndex:d] objectAtIndex:kStart] codeString] characterAtIndex:2] - 'a';
                _dictIndex[d][i][j][kindex].startIndex = kStart;
                for (NSInteger kitr = kStart; kitr <= kEnd; ++kitr) {
                    NSInteger kc = [[[[_dictArray objectAtIndex:d] objectAtIndex:kitr] codeString] characterAtIndex:2] - 'a';
                    if (kindex != kc){
                        _dictIndex[d][i][j][kindex].endIndex = kitr - 1;
                        kindex = kc;
                        _dictIndex[d][i][j][kindex].startIndex = kitr;
                    }
                }
                _dictIndex[d][i][j][kindex].endIndex = kEnd;
            }//k
        }//j
    }//i
}
-(void)initPunctuationArray{
    _fullPunctuationOrSymbolArray = [NSArray arrayWithObjects:
                                     @"！",      @"@",      @"＃",     @"¥",    @"……",
                                     @"％",      @"＋",      @"（",    @"&",     @"——",
                                     @"＊",      @"）",      @"｝",      @"0" ,    @"0"  ,
                                     @"｛",       @"0"   ,    @"0"   ,   @"0"  ,   @"0"   ,
                                     @"0"   ,    @"“”",      @"0"   ,   @"：" ,    @"｜",
                                     @"《",      @"？",      @"0"   ,   @"0"   ,   @"》",
                                     @"0"   ,    @"0"   ,    @"～",     @"＝" ,     @"0"   ,
                                     @"0"   ,    @"－",      @"0"   ,   @"0"   ,    @"］",
                                     @"0"   ,    @"0"   ,    @"［",     @"0"   ,    @"0"   ,
                                     @"0"   ,    @"0"   ,    @"0"   ,   @"‘’",     @"0"   ,
                                     @"；",      @"、",      @"，",      @"／",     @"0"   ,
                                     @"0"   ,    @"。",      @"0"   ,    @"0" ,     @"｀",    nil];

}
-(id)init{
    self = [super init];
    if (self) {
        _codeGenerator = [[MJCodeGenerator alloc] init];
        _dictStringTransfer = [[DictStringTransfer alloc] init];
        [self initDictArray];
        [self initIndex];
        [self initPunctuationArray];
        _dictModified = NO;
    }
    return self;
}

-(void)saveDictToFile {
    if (_dictModified) {
        NSString  *pathOfBaseDict = [@"~/.config/MJZhengMa/Base.txt" stringByExpandingTildeInPath];
        NSString* _stringOfXMDictFile = [_dictStringTransfer stringFromMJDictArray:_xmDictArray hasCode:YES hasWord:YES hasFreq:YES hasXMCode:NO];
        [_stringOfXMDictFile writeToFile:pathOfBaseDict atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        _dictModified = NO;
    }
}

@end

/*
 shift:{keycode-18}
 array:keycode:half:full
 0    18   1    ！
 1    19   2    @
 2    20   3    ＃
 3    21   4    ¥
 4    22   6    ……
 5    23   5    ％
 6    24   =    ＋
 7    25   9    （
 8    26   7    &
 9    27   -    ——
 10   28   8    ＊
 11   29   0    ）
 12   30   ]    ｝
 13
 14
 15   33   [   ｛
 16
 17
 18
 19
 20
 21   39   ‘    “”
 22
 23   41   ;    ：
 24   42   \    ｜
 25   43   ,   《
 26   44   /    ？
 27
 28
 29   47   .    》
 30
 31
 32   50   `    ～
 no shift:{keycode+9}
 array:keycode:half:full
 33   24   =    ＝
 34
 35
 36   27   -    －
 37
 38
 39   30   ]    ］
 40
 41
 42   33   [   ［
 43
 44
 45
 46
 47
 48   39   ‘    ‘’
 49
 50   41   ;    ；
 51   42   \    、
 52   43   ,    ，
 53   44   /    ／
 54
 55
 56   47   .    。
 57
 58
 59   50   `   ｀
*/