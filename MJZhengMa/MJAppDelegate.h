//
//  MJAppDelegate.h
//  MJZhengMa
//
//  Created by MJsaka on 15/3/4.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//
//#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "MJConversionEngine.h"
#import "MJCandidatesPanel.h"

@interface MJAppDelegate : NSObject <NSApplicationDelegate>
{
//    IBOutlet NSMenu* _menu;
    IBOutlet MJConversionEngine* _conversionEngine;
    IBOutlet MJCandidatesPanel *_candidatesPanel;
    MJUIStyle* _baseStyle;
}

-(MJConversionEngine*)conversionEngine;
-(MJCandidatesPanel*)candidatePanel;
//-(NSMenu*)menu;

-(void)updateUIStyle:(BOOL)initializing;
@end
