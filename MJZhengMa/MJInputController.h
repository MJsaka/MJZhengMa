//
//  MJInputController.h
//  MJZhengMa
//
//  Created by MJsaka on 15/2/5.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "MJDict.h"

typedef enum CandidatesSelectControl{
    PAGE_NEXT = 0,
    PAGE_PRE = 1,
    SELECTION_NEXT = 2,
    SELECTION_PRE = 3
} CandidatesSelectChangeType;


@interface MJInputController : IMKInputController
- (void)activateServer:(id)sender;
- (void)deactivateServer:(id)sender;

@end