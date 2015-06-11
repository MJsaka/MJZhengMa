//
//  MJConversionEngine.h
//  MJZhengMa
//
//  Created by MJsaka on 15/2/9.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJDict.h"
#import "MJCodeGenerator.h"

@interface MJConversionEngine : NSObject

-(NSString*)wordAtDictIndex:(NSInteger)index;
-(NSString*)codeAtDictIndex:(NSInteger)index;
-(NSString*)fullPunctuationOrSymbolAtIndex:(NSInteger)index;
-(MJDictIndexNodeType*)topLevelIndex;

-(void)creatWord:(NSString*)word;
-(void)adjustFreqForWordAtIndex:(NSInteger)index startIndex:(NSInteger)start;

-(void)saveDictToFile;
@end