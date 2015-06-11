//
//  DictProcess.h
//  MJZhengMa
//
//  Created by MJsaka on 15/2/13.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MJCodeGenerator.h"

@interface DictProcess : NSObject
{
    IBOutlet id _textView;
    NSString* _stringOfTextFile;
    NSString* _stringOfDictFile;
    MJCodeGenerator* codeGenerator;
}
- (IBAction)selectTextFile:(id)sender;
- (IBAction)selectDictFile:(id)sender;
- (IBAction)establishDict:(id)sender;
- (IBAction)regenerateDict:(id)sender;
- (IBAction)removeDuplicate:(id)sender;
- (IBAction)saveDictFile:(id)sender;

@end
