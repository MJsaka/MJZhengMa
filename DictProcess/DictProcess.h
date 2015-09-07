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
    NSString* _stringOfXMDictFile;
    NSArray* _arrayOfXMDZDict;
    NSArray* _arrayOfPYDict;
    NSString* _stringOfPYDict;
    MJCodeGenerator* codeGenerator;
}
- (IBAction)selectTextFile:(id)sender;
- (IBAction)selectDictFile:(id)sender;
- (IBAction)establishDict:(id)sender;
- (IBAction)regenerateDict:(id)sender;
- (IBAction)removeDuplicate:(id)sender;
- (IBAction)saveDictFile:(id)sender;
-(IBAction)appendZMCodeForPinYin:(id)sender;
-(IBAction)selectXMDZDictFile:(id)sender;
-(IBAction)selectPYDictFile:(id)sender ;
- (IBAction)appendFreq:(id)sender;
@end
