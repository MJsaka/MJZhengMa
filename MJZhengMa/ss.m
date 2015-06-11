//
//  ss.m
//  MJ郑码
//
//  Created by MJsaka on 15/3/12.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Foundation/Foundation.h>

// SecProtocol
@protocol SecProtocol
-(void)payoff;
-(void)tel;
@end

// Sec
#import "SecProtocol.h"
@interface Sec : NSObject
@end

@implementation Sec
-(void)payoff{
}
-(void)tel{
}
@end

// Boss
#import "SecProtocol.h"
@interface Boss : NSObject
@property(nonatomic,retain) id detegate;
-(void)manage;
-(void)teach;
@end

@implementation Boss
@synthesize detegate=_detegate;
-(void)manage{
}
-(void)teach{
}
-(void)payoff{
    [_detegate payoff];
}
-(void)tel{
    [_detegate tel];
}
@end

// main.m
#import "Boss.h"
#import "Sec.h"
int main (int argc, const char * argv[])
{
    Boss *boss=[[[Boss alloc] init] autorelease];
    Sec *sec=[[[Sec alloc] init] autorelease];
    boss.detegate=sec;
}