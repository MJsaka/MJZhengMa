//
//  Dict_String.h
//  MJZhengMa
//
//  Created by MJsaka on 15/2/14.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#ifndef MJZhengMa_Dict_String_h
#define MJZhengMa_Dict_String_h

#import <Foundation/Foundation.h>
#import "MJDict.h"

NSComparator MJDictCompare;

NSMutableArray* dictArrayFromTextString(NSString* string);
NSMutableArray* dictArrayFromDictString(NSString* dictString);
NSString* stringFromDictArray(NSArray* array);



#endif
