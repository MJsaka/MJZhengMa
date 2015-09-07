//
//  MJDict.h
//  MJZhengMa
//
//  Created by MJsaka on 15/2/6.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJXMDict : NSObject
@property (strong) NSString* codeString;
@property (strong) NSString* wordString;
@property (assign) double wordFrequency;
@end

@interface MJPYDict : MJXMDict

@property (strong) NSString* xmCodeString;
@end

@interface MJDictIndexNodeType : NSObject
@property (assign) NSInteger indexStart;
@property (assign) NSInteger indexEnd;
@end


