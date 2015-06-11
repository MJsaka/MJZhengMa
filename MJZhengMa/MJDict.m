//
//  MJDict.m
//  MJZhengMa
//
//  Created by MJsaka on 15/2/6.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MJDict.h"

@interface MJDict() {
    NSMutableString*   _codeString;
    NSMutableString*   _wordString;
    double   _wordFrequency;
}
@end

@implementation MJDict

-(id)init{
    self = [super init];
    if (self) {
        _wordString = [NSMutableString string];
        _codeString = [NSMutableString string];
        _wordFrequency = 0;
    }
    return self;
}
-(NSString*)codeString{
    return _codeString;
}
-(NSString*)wordString{
    return _wordString;
}
-(double)wordFrequency{
    return _wordFrequency;
}
-(void)setCodeString:(NSString*)string{
    [_codeString setString:string];
}
-(void)setWordString:(NSString*)string{
    [_wordString setString:string];
}
-(void)setWordFrequency:(double)freq{
    _wordFrequency = freq;
}

@end


@interface MJDictIndexNodeType(){
    NSInteger _indexStart;
    NSInteger _indexEnd;
    NSInteger _indexCount;
    NSInteger _indexLevel;
    MJDictIndexNodeType* _nextLevelIndexNode[26];
}
@end

@implementation MJDictIndexNodeType

-(id)init{
    self = [super init];
    if (self){
        _indexStart = 0;
        _indexEnd = 0;
        _indexCount = 0;
        _indexLevel = 0;
    }
    return self;
}
-(NSInteger)indexStart{
    return _indexStart;
}
-(NSInteger)indexEnd{
    return _indexEnd;
}
-(NSInteger)indexCount{
    return _indexCount;
}
-(NSInteger)indexLevel{
    return _indexLevel;
}

-(MJDictIndexNodeType*)nextLevelIndexNode:(NSInteger)index{
    return _nextLevelIndexNode[index];
}

-(MJDictIndexNodeType*)initNextLevelIndexNode:(NSInteger)index{
    if ( _nextLevelIndexNode[index] == nil ) {
        _nextLevelIndexNode[index] = [[MJDictIndexNodeType alloc] init];
    }
    return _nextLevelIndexNode[index];
}

-(void)setIndexStart:(NSInteger)start indexEnd:(NSInteger)end indexLevel:(NSInteger)level{
    _indexStart = start;
    _indexEnd = end;
    _indexCount = end - start + 1;
    _indexLevel = level;
}

@end
