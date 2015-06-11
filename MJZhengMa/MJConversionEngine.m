//
//  MJConversionEngine.m
//  MJZhengMa
//
//  Created by MJsaka on 15/2/9.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MJConversionEngine.h"
#import "MJDict.h"
#import "Dict_String.h"
#import "MJCodeGenerator.h"
#import <math.h>

@interface MJConversionEngine(){
    MJCodeGenerator* codeGenerator;
    NSMutableArray* _transformDictionary;
    MJDictIndexNodeType* _topLevelIndex;
    const NSArray* _fullPunctuationOrSymbolArray;
    BOOL _dictModified;
}
-(void)initTransformDictionary;
-(void)initPunctuationArray;
-(void)initIndex;
-(void)establishIndexForNode:(MJDictIndexNodeType*)indexNode;

-(BOOL)isWordExist:(MJDict*)dict;
@end

@implementation MJConversionEngine

-(NSString*)wordAtDictIndex:(NSInteger)index{
    return [[_transformDictionary objectAtIndex:index] wordString];
}
-(NSString*)codeAtDictIndex:(NSInteger)index{
    return [[_transformDictionary objectAtIndex:index] codeString];
}
-(MJDictIndexNodeType*)topLevelIndex{
    return _topLevelIndex;
}

-(BOOL)isWordExist:(MJDict*)dict{
    NSString* code = [dict codeString];
    NSString* word = [dict wordString];
    MJDictIndexNodeType* node = _topLevelIndex;
    NSInteger length = [code length];
    NSInteger i = 0;
    while (i<length) {
        NSInteger next = [[dict codeString] characterAtIndex:i] - 'a';
        if ([node nextLevelIndexNode:next] != nil) {
            node = [node nextLevelIndexNode:next];
            ++i;
        }else
            break;
    }
    if (i == length) {
        for (NSInteger index=[node indexStart]; index <= [node indexEnd]; ++index) {
            NSString* wordString = [self wordAtDictIndex:index];
            if ([word isEqualToString:wordString]) {
                return YES;
            }
        }
    }
    return NO;
}
-(void)adjustFreqForWordAtIndex:(NSInteger)index startIndex:(NSInteger)start{
    double startDictFreq = [[_transformDictionary objectAtIndex:start] wordFrequency];
    double indexDictFreq = [[_transformDictionary objectAtIndex:index] wordFrequency];
    indexDictFreq = indexDictFreq * (1.01 + log(startDictFreq/indexDictFreq));
    [[_transformDictionary objectAtIndex:index] setWordFrequency:indexDictFreq];
    NSInteger insetIndex = index - 1;
    while (insetIndex >= start && indexDictFreq > [[_transformDictionary objectAtIndex:insetIndex] wordFrequency] )
    {
        --insetIndex;
    }
    for (NSInteger i=index-1; i>insetIndex ; --i) {
        [_transformDictionary exchangeObjectAtIndex:i withObjectAtIndex:i+1];
    }
    _dictModified = YES;
}

-(void)creatWord:(NSString*)word{
    MJDict* dict = [[MJDict alloc] init];
    [dict setWordString:word];
    [dict setWordFrequency:100];
    if ( ![codeGenerator generateCodeForDictElement:dict] ) return;
    //判断该词是否存在
    if ([self isWordExist:dict]) return;
    //找到该词的插入点
    MJDictIndexNodeType* node = _topLevelIndex;
    NSInteger i = 0;
    while (i<2) {
        NSInteger next = [[dict codeString] characterAtIndex:i] - 'a';
        node = [node nextLevelIndexNode:next];
        ++i;
    }
    NSInteger index = [_transformDictionary indexOfObject:dict inSortedRange:NSMakeRange([node indexStart],[node indexCount]) options:NSBinarySearchingInsertionIndex | NSBinarySearchingLastEqual usingComparator:MJDictCompare];
    [_transformDictionary insertObject:dict atIndex:index];
    _dictModified = YES;
    [self initIndex];
}

-(NSString*)fullPunctuationOrSymbolAtIndex:(NSInteger)index{
    return [_fullPunctuationOrSymbolArray objectAtIndex:index];
}
-(void)establishIndexForNode:(MJDictIndexNodeType *)indexNode
{
    NSInteger start = [indexNode indexStart];
    NSInteger end = [indexNode indexEnd];
    NSInteger level = [indexNode indexLevel];
    NSInteger index = start;
    NSInteger i = 0;
    while (index <= end) {
        if (level >= [[self codeAtDictIndex:index] length])
        {   //level等于当前索引级别code长度。
            //为当前索引级别建立下一级索引[a-z]，故code长度应大于当前级别。
            index ++;
            start ++;
        }else if ([[self codeAtDictIndex:index] characterAtIndex:level] - 'a' == i){
            index ++;
        }else if ( index == start ){
            i = [[self codeAtDictIndex:index] characterAtIndex:level] - 'a';
        }else{
            [[indexNode initNextLevelIndexNode:i] setIndexStart:start indexEnd:index-1 indexLevel:level + 1];
            if ( level < 3 ) {
                //当前level为2时，3级索引在本次循环结束时建立完成。
                //递归为3级建立4级索引。
                [self establishIndexForNode:[indexNode nextLevelIndexNode:i]];
            }
            start = index;
            i = [[self codeAtDictIndex:index] characterAtIndex:level] - 'a';
        }
    }
    if (index != start)
    {   //当前level无任何[a-z]下一级索引时，index == start == end + 1。
        [[indexNode initNextLevelIndexNode:i] setIndexStart:start indexEnd:end indexLevel:level + 1];
        if ( level < 3 ) {
            [self establishIndexForNode:[indexNode nextLevelIndexNode:i]];
        }
    }
}

-(void)initTransformDictionary{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* pathOfBaseDict;
    if ([fileManager isReadableFileAtPath:[@"~/.config/MJZhengMa" stringByExpandingTildeInPath]]) {
        pathOfBaseDict = [@"~/.config/MJZhengMa/Base.txt" stringByExpandingTildeInPath];
    }else{
        NSBundle* _bundle = [NSBundle mainBundle];
        pathOfBaseDict = [_bundle pathForResource:@"Base" ofType:@"txt"];
    }
    NSString* baseDictFileString = [NSString stringWithContentsOfFile:pathOfBaseDict encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray* _originalDictionary = dictArrayFromDictString(baseDictFileString);
    _transformDictionary = _originalDictionary;
}
-(void)initIndex{
    _topLevelIndex = [[MJDictIndexNodeType alloc] init];
    [_topLevelIndex setIndexStart:0 indexEnd:[_transformDictionary count]-1 indexLevel:0];
    [self establishIndexForNode:_topLevelIndex];

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
        codeGenerator = [[MJCodeGenerator alloc] init];
        [self initTransformDictionary];
        [self initIndex];
        [self initPunctuationArray];
        _dictModified = NO;
    }
    return self;
}

-(void)saveDictToFile {
    if (_dictModified) {
        NSString  *pathOfBaseDict = [@"~/.config/MJZhengMa/Base.txt" stringByExpandingTildeInPath];
        NSString* _stringOfDictFile = stringFromDictArray(_transformDictionary);
        [_stringOfDictFile writeToFile:pathOfBaseDict atomically:YES encoding:NSUTF8StringEncoding error:NULL];
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