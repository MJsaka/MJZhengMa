//
//  MJMJCodeGenerator.h
//  MJ郑码
//
//  Created by MJsaka on 15/3/7.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MJDict.h"

@interface MJCodeGenerator : NSObject

-(BOOL)generateCodeForDictElement:(MJXMDict*)dict;
-(Boolean)apendWordFrequency:(MJXMDict*)dict;
@end
