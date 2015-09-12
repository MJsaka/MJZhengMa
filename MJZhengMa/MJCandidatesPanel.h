//
//  MJCandidatesPanel.h
//  MJ郑码
//
//  Created by MJsaka on 15/3/12.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MJInputController.h"

@interface MJUIStyle : NSObject<NSCopying> {
}

@property (nonatomic, assign) BOOL horizontal;
@property (nonatomic, assign) BOOL inlinePreedit;


@property (nonatomic, copy) NSString* fontName;
@property (nonatomic, assign) int fontSize;

@property (nonatomic, assign) double alpha;
@property (nonatomic, assign) double cornerRadius;
@property (nonatomic, assign) double borderHeight;
@property (nonatomic, assign) double borderWidth;
@property (nonatomic, assign) double lineSpacing;
@property (nonatomic, assign) double spacing;

@property (nonatomic, copy) NSString *backgroundColor;
@property (nonatomic, copy) NSString *highlightedBackgroundColor;

@property (nonatomic, copy) NSString *textColor;
@property (nonatomic, copy) NSString *candidateTextColor;

@property (nonatomic, copy) NSString *highlightedTextColor;
@property (nonatomic, copy) NSString *highlightedCandidateTextColor;


@end

@class  MJCandidatesPanel;

@interface MJCandidatesView : NSView
{
    NSAttributedString* _content;
}
@property (nonatomic, retain) NSColor *backgroundColor;
@property (nonatomic, assign) double cornerRadius;
@property (nonatomic, assign) double borderHeight;
@property (nonatomic, assign) double borderWidth;

-(NSSize)contentSize;
-(void)setContent:(NSAttributedString*)content;

@end


@interface MJCandidatesPanel : NSObject {
    NSRect _positionRect;
    NSWindow *_window;
    MJCandidatesView *_view;
    
    NSMutableDictionary *_attrs;
    NSMutableDictionary *_highlightedAttrs;
    
    NSMutableDictionary *_labelAttrs;
    NSMutableDictionary *_labelHighlightedAttrs;
    
    NSMutableDictionary *_tipsAttrs;
    NSMutableDictionary *_tipsHighlightedAttrs;
    
    NSMutableDictionary *_preeditAttrs;
    NSMutableDictionary *_preeditHighlightedAttrs;
    
    NSParagraphStyle *_paragraphStyle;
    NSParagraphStyle *_preeditParagraphStyle;
    
    BOOL _horizontal;
    BOOL _inlinePreedit;
}

-(void)hide;
-(void)updateCandidates:(NSArray*)candidates withTips:(NSArray*)tips withClasses:(NSArray*)classes atPosition:(NSRect)position selectIndex:(NSInteger)index;

-(void)updateUIStyle:(MJUIStyle*)style;

@end