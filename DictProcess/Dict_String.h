//
//  Dict_String.h
//  MJZhengMa
//
//  Created by MJsaka on 15/2/14.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#ifndef MJZhengMa_Dict_String_h
#define MJZhengMa_Dict_String_h

#import <Cocoa/Cocoa.h>
#import "MJDict.h"

NSComparator MJXMDictCompare;

NSMutableArray* xmDictArrayFromWordFreqString(NSString* string);
NSMutableArray* xmDictArrayFromDictString(NSString* dictString);
NSString* stringFromXMDictArray(NSArray* array);
NSMutableArray* xmDictArrayFromCodeWordString(NSString* string);
NSMutableArray* pyDictArrayFromCodeWordFreqString(NSString* dictString);
NSString* stringFromPYDictArray(NSArray* array);


#endif
