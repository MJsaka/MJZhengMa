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

typedef struct MJDictIndexNode{
    NSInteger startIndex;
    NSInteger endIndex;
}MJDictIndexNodeType;

@interface MJConversionEngine : NSObject

-(NSString*)fullPunctuationOrSymbolAtIndex:(NSInteger)index;

-(void)creatWord:(NSString*)word;

-(void)adjustFreqForWord:(NSString*)string originString:(NSString*)originString;

- (void)generateCandidates:(NSMutableArray*)candidates andTips:(NSMutableArray*)tips forOriginString:(NSString*)originString;
-(void)saveDictToFile;
@end