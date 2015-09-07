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

-(NSMutableString*)composedBuffer;
-(void)setComposedBuffer:(NSString*)string;
-(void)composedBufferAppend:(NSString*)string;

-(NSMutableString*)originalBuffer;
-(void)setOriginalBuffer:(NSString*)string;
-(void)originalBufferAppend:(NSString*)string;

-(NSMutableString*)wordBuffer;
-(void)setWordBuffer:(NSString*)string;
-(void)wordBufferAppend:(NSString*)string;

-(void)resetTransformState:(id)sender;
-(void)resetCreatWordState:(id)sender;

-(void)updateMarkedText:(id)sender;

-(BOOL)deleteBackward:(id)sender;
-(void)transform:(id)sender;
-(void)triggerCreatWord:(id)sender;

@end