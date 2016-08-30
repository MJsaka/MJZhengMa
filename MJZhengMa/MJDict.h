//
//  MJDict.h
//  MJZhengMa
//
//  Created by MJsaka on 15/2/6.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJXMDict : NSObject
@property (nonatomic,copy) NSString* codeString;
@property (nonatomic,copy) NSString* wordString;
@property (nonatomic,assign) double wordFrequency;
@end

@interface MJENDict : NSObject
@property (nonatomic,copy) NSString* codeString;
@property (nonatomic,copy) NSString* wordString;
@property (nonatomic,assign) double wordFrequency;
@end

@interface MJPYDict : MJXMDict

@property (nonatomic,copy) NSString* xmCodeString;
@end



