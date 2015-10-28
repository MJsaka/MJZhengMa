//
//  MJAppDelegate.m
//  MJZhengMa
//
//  Created by MJsaka on 15/3/4.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import "MJAppDelegate.h"
#import "MJCandidatesPanel.h"

@implementation MJAppDelegate

-(MJConversionEngine*)conversionEngine{
    return _conversionEngine;
}

-(MJCandidatesPanel*)candidatePanel{
    return _candidatesPanel;
}

- (void)updateUIStyle:(BOOL)initializing{
    MJUIStyle *style;
    if (initializing) {
        style = [[MJUIStyle alloc] init];
        
        style.horizontal = YES;
        style.inlinePreedit = NO;
        
        style.fontName = @"PingFang SC Light";

        style.fontSize = 24;
        
        style.alpha = 1.0;
        
        style.cornerRadius = 5;
        style.borderHeight = 5;
        style.borderWidth = 10;
        
        style.lineSpacing = 0;
        style.spacing = 0;
        
        style.backgroundColor = @"0xededed";
        style.textColor = @"0xe000e0";
        style.candidateTextColor = @"0x000000";
        
        
        style.highlightedBackgroundColor = @"0xededed";
        style.highlightedTextColor = @"0xe000e0";
        style.highlightedCandidateTextColor = @"0x4080ff";
    
        [_candidatesPanel updateUIStyle:style];
        _baseStyle = style;
    }
    else {
        style = [_baseStyle copy];
    }
}

/*
 
-(NSMenu*)menu{
    return _menu;
}
 
 */

-(void)awakeFromNib
{
    [self updateUIStyle:YES];
//    NSMenuItem*		preferences = [_menu itemWithTag:1];
//    
//    if ( preferences ) {
//        [preferences setAction:@selector(showPreferences:)];
//    }
}

@end
