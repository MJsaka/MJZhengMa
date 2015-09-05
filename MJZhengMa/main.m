//
//  main.m
//  MJzhengma
//
//  Created by MJsaka on 15/2/5.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "MJAppDelegate.h"

IMKServer*          server;
const NSString*     kConnectionName = @"MJZheng_1_Connection";

int main(int argc, char *argv[])
{
    [NSApplication sharedApplication];
    NSArray* topLevelObjects;
    [[NSBundle mainBundle] loadNibNamed:@"MainMenu" owner:NSApp topLevelObjects:&topLevelObjects];
    
    NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
    server = [[IMKServer alloc] initWithName:(NSString*)kConnectionName bundleIdentifier:identifier];
    
    [NSApp run];
    return 0;
}