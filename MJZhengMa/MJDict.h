//
//  MJDict.h
//  MJZhengMa
//
//  Created by MJsaka on 15/2/6.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJDict : NSObject
-(NSString*)codeString;
-(NSString*)wordString;
-(double)wordFrequency;
-(void)setCodeString:(NSString*)string;
-(void)setWordString:(NSString*)string;
-(void)setWordFrequency:(double)freq;
@end

@interface MJDictIndexNodeType : NSObject
-(NSInteger)indexStart;
-(NSInteger)indexEnd;
-(NSInteger)indexCount;
-(NSInteger)indexLevel;
-(MJDictIndexNodeType*)nextLevelIndexNode:(NSInteger)index;
-(MJDictIndexNodeType*)initNextLevelIndexNode:(NSInteger)index;
-(void)setIndexStart:(NSInteger)start indexEnd:(NSInteger)end indexLevel:(NSInteger)level;
@end


