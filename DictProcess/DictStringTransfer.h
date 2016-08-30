//
//  DictStringTransfer.h
//  MJZhengMa
//
//  Created by MJsaka on 15/2/14.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MJDict.h"

@interface DictStringTransfer : NSObject

-(NSComparator)MJDictCompare;
-(NSComparator)MJFreqCompare;

-(NSMutableArray*)xmDictArrayFromString:(NSString*)dictString hasCode:(Boolean)hasCode hasWord:(Boolean)hasWord hasFreq:(Boolean)hasFreq;
-(NSMutableArray*)engDictArrayFromString:(NSString*)dictString hasCode:(Boolean)hasCode hasWord:(Boolean)hasWord hasFreq:(Boolean)hasFreq;
-(NSMutableArray*)pyDictArrayFromString:(NSString*)dictString hasCode:(Boolean)hasCode hasWord:(Boolean)hasWord hasFreq:(Boolean)hasFreq hasXMCode:(Boolean)hasXMCode;

-(NSString*)stringFromMJDictArray:(NSArray*)array hasCode:(Boolean)hasCode hasWord:(Boolean)hasWord hasFreq:(Boolean)hasFreq hasXMCode:(Boolean)hasXMCode;

@end