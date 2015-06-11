//
//  MJMJCodeGenerator.h
//  MJ郑码
//
//  Created by MJsaka on 15/3/7.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJDict.h"

@interface MJCodeGenerator : NSObject

-(BOOL)generateCodeForDictElement:(MJDict*)dict;

@end
