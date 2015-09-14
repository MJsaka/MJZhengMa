//
//  DictProcess.h
//  MJZhengMa
//
//  Created by MJsaka on 15/2/13.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DictStringTransfer.h"
#import "MJCodeGenerator.h"

@interface DictProcess : NSObject
{
    DictStringTransfer* _dictStringTransformer;
    MJCodeGenerator* codeGenerator;
    IBOutlet id _textView;
    
    NSString* _stringOfTextFile;
    NSString* _stringOfDictFile;
    
    NSArray* _arrayOfXMDict;
    NSArray* _arrayOfPYDict;
    
}
-(IBAction)generateArrayOfXMDict:(id)sender;
-(IBAction)generateArrayOfPYDict:(id)sender;

-(IBAction)addCodeForXMDict:(id)sender;

-(IBAction)delDupForEngDict:(id)sender;

-(IBAction)sortXMDict:(id)sender;
-(IBAction)sortPYDict:(id)sender;

-(IBAction)addFreqForXMDict:(id)sender;
-(IBAction)addXMCodeForPY:(id)sender;

-(IBAction)selectTextFile:(id)sender;
-(IBAction)saveDictFile:(id)sender;
@end
