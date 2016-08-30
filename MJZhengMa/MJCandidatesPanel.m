//
//  MJCandidatesPanel.m
//  MJ郑码
//
//  Created by MJsaka on 15/3/12.
//  Copyright (c) 2015年 MJsaka. All rights reserved.
//

#import "MJCandidatesPanel.h"

@implementation MJUIStyle

@synthesize horizontal = _horizontal;
@synthesize inlinePreedit = _inlinePreedit;


@synthesize fontName = _fontName;
@synthesize fontSize = _fontSize;

@synthesize alpha = _alpha;
@synthesize cornerRadius = _cornerRadius;
@synthesize borderHeight = _borderHeight;
@synthesize borderWidth = _borderWidth;
@synthesize lineSpacing = _lineSpacing;
@synthesize spacing = _spacing;

@synthesize backgroundColor = _backgroundColor;
@synthesize textColor = _textColor;
@synthesize candidateTextColor = _candidateTextColor;

@synthesize highlightedBackgroundColor = _highlightedBackgroundColor;
@synthesize highlightedTextColor = _highlightedTextColor;
@synthesize highlightedCandidateTextColor = _highlightedCandidateTextColor;




- (id)copyWithZone:(NSZone *)zone
{
    MJUIStyle* style = [[MJUIStyle allocWithZone:zone] init];
    
    style.horizontal = _horizontal;
    style.inlinePreedit = _inlinePreedit;
    
    
    style.fontName = _fontName;
    style.fontSize = _fontSize;
    
    style.alpha = _alpha;
    style.cornerRadius = _cornerRadius;
    style.borderHeight = _borderHeight;
    style.borderWidth = _borderWidth;
    style.lineSpacing = _lineSpacing;
    style.spacing = _spacing;
    
    style.backgroundColor = _backgroundColor;
    style.textColor = _textColor;
    style.candidateTextColor = _candidateTextColor;
    
    style.highlightedBackgroundColor = _highlightedBackgroundColor;
    style.highlightedTextColor = _highlightedTextColor;
    style.highlightedCandidateTextColor = _highlightedCandidateTextColor;
    
    
    return style;
}

@end


static const int kOffsetHeight = 5;
static const int kFontSize = 24;
static const double kAlpha = 1.0;


@implementation MJCandidatesView

@synthesize backgroundColor = _backgroundColor;
@synthesize horizontal = _horizontal;
@synthesize cornerRadius = _cornerRadius;
@synthesize borderHeight = _borderHeight;
@synthesize borderWidth = _borderWidth;

-(double)borderHeight
{
    return MAX(_borderHeight, _cornerRadius);
}

-(double)borderWidth
{
    return MAX(_borderWidth, _cornerRadius);
}

-(NSSize)contentSize
{
    if (!_content) {
        return NSMakeSize(0, 0);
    }
    return [_content size];
}

-(void)setContent:(NSAttributedString*)content
{
    _content = content;
    [self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)rect
{
    if (!_content) {
        return;
    }
    
    if ([self backgroundColor]) {
        [[self backgroundColor] setFill];
    }
    else {
        [[NSColor windowBackgroundColor] setFill];
    }
    
    [[NSBezierPath bezierPathWithRoundedRect:rect xRadius:_cornerRadius yRadius:_cornerRadius] fill];
    NSPoint point = rect.origin;
    point.x += self.borderWidth;
    point.y += self.borderHeight;
    [_content drawAtPoint:point];
}

@end


@implementation MJCandidatesPanel

-(id)init
{
    
    _positionRect = NSMakeRect(0, 0, 0, 0);
    _window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0)
                                          styleMask:NSBorderlessWindowMask
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
    [_window setAlphaValue:kAlpha];
    [_window setLevel:NSScreenSaverWindowLevel + 1];
    [_window setHasShadow:YES];
    [_window setOpaque:NO];
    [_window setBackgroundColor:[NSColor clearColor]];
    
    _view = [[MJCandidatesView alloc] initWithFrame:[[_window contentView] frame]];
    [_window setContentView:_view];
    
    _attrs = [[NSMutableDictionary alloc] init];
    [_attrs setObject:[NSColor controlTextColor] forKey:NSForegroundColorAttributeName];
    [_attrs setObject:[NSFont userFontOfSize:kFontSize] forKey:NSFontAttributeName];
    

    _highlightedAttrs = [[NSMutableDictionary alloc] init];
    [_highlightedAttrs setObject:[NSColor selectedControlTextColor] forKey:NSForegroundColorAttributeName];
    [_highlightedAttrs setObject:[NSColor selectedTextBackgroundColor] forKey:NSBackgroundColorAttributeName];
    [_highlightedAttrs setObject:[NSFont userFontOfSize:kFontSize] forKey:NSFontAttributeName];
    
    _labelAttrs = _attrs;
    _tipsAttrs = _attrs;
    
    _preeditAttrs = [[NSMutableDictionary alloc] init];
    [_preeditAttrs setObject:[NSColor disabledControlTextColor] forKey:NSForegroundColorAttributeName];
    [_preeditAttrs setObject:[NSFont userFontOfSize:kFontSize] forKey:NSFontAttributeName];
    
    _preeditHighlightedAttrs = [[NSMutableDictionary alloc] init];
    [_preeditHighlightedAttrs setObject:[NSColor controlTextColor] forKey:NSForegroundColorAttributeName];
    [_preeditHighlightedAttrs setObject:[NSFont userFontOfSize:kFontSize] forKey:NSFontAttributeName];
    
    _horizontal = NO;
    _inlinePreedit = NO;
    _paragraphStyle = [NSParagraphStyle defaultParagraphStyle];
    _preeditParagraphStyle = [NSParagraphStyle defaultParagraphStyle];
    
    return self;
}

-(BOOL)horizontal
{
    return _horizontal;
}

-(BOOL)inlinePreedit
{
    return _inlinePreedit;
}

-(void)show
{
    
    NSRect window_rect = NSMakeRect(0, 0, 0, 0);
    // resize frame
    NSSize content_size = [_view contentSize];
    window_rect.size.height = content_size.height + [_view borderHeight]*2;
    window_rect.size.width = content_size.width + [_view borderWidth] * 2;
    if (window_rect.size.width < 200) {
        window_rect.size.width = 200;
    }
    // reposition window
    window_rect.origin.x = NSMinX(_positionRect);
    window_rect.origin.y = NSMinY(_positionRect) - kOffsetHeight - NSHeight(window_rect);
    // fit in current screen
    NSRect screen_rect = [[NSScreen mainScreen] frame];
    NSArray* screens = [NSScreen screens];
    NSUInteger i;
    for (i = 0; i < [screens count]; ++i) {
        NSRect rect = [[screens objectAtIndex:i] frame];
        if (NSPointInRect(_positionRect.origin, rect)) {
            screen_rect = rect;
            break;
        }
    }
    if (NSMaxX(window_rect) > NSMaxX(screen_rect)) {
        window_rect.origin.x = NSMaxX(screen_rect) - NSWidth(window_rect);
    }
    if (NSMinX(window_rect) < NSMinX(screen_rect)) {
        window_rect.origin.x = NSMinX(screen_rect);
    }
    if (NSMinY(window_rect) < NSMinY(screen_rect)) {
        window_rect.origin.y = NSMaxY(_positionRect) + kOffsetHeight;
    }
    if (NSMaxY(window_rect) > NSMaxY(screen_rect)) {
        window_rect.origin.y = NSMaxY(_positionRect) - NSHeight(window_rect);
    }
    if (NSMinY(window_rect) < NSMinY(screen_rect)) {
        window_rect.origin.y = NSMinY(_positionRect);
    }
    // voila !
    [_window setFrame:window_rect display:YES];
    [_window orderFront:nil];
}

-(void)hide
{
    [_window orderOut:nil];
}


-(void)updateCandidates:(NSArray*)candidates withTips:(NSArray *)tips withClasses:(NSArray *)classes atPosition:(NSRect)position selectIndex:(NSInteger)index{
    _positionRect = position;
    NSInteger _numCandidates = [candidates count];
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] init];
    
    for (NSInteger i = 0; i < _numCandidates; ++i) {
        NSMutableAttributedString *line = [[NSMutableAttributedString alloc] init];
        char label_character = i % 9 + '1';
        NSDictionary *attrs = _attrs, *labelAttrs = _labelAttrs , *tipAttrs = _tipsAttrs;
        
        if (i == index) {
            attrs = _highlightedAttrs;
            labelAttrs = _labelHighlightedAttrs;
            tipAttrs = _tipsHighlightedAttrs;
        }
        
        [line appendAttributedString:
         [[NSAttributedString alloc] initWithString:
          [NSString stringWithFormat:@"%c.", label_character] attributes:labelAttrs]];
        
        [line appendAttributedString:
         [[NSAttributedString alloc] initWithString:
          [candidates objectAtIndex:i] attributes:attrs]];
        
        [line appendAttributedString:
         [[NSAttributedString alloc] initWithString:
          [tips objectAtIndex:i] attributes:tipAttrs]];
        if (i < 8){
            [line appendAttributedString:[[NSAttributedString alloc] initWithString:(_horizontal ? @" " : @"\n") attributes:_attrs]];
        }
        [text appendAttributedString:line];
    }
    for (NSInteger i = _numCandidates; i < 9; ++i) {
        NSMutableAttributedString *line;
        if (i < 8) {
            line = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:_attrs];
        }else {
            line = [[NSMutableAttributedString alloc] initWithString:@" " attributes:_attrs];
        }
        [text appendAttributedString:line];
    }
    [text addAttribute:NSParagraphStyleAttributeName value:(id)_paragraphStyle range:NSMakeRange(0, [text length])];
    
    [_view setContent:text];
    [self show];
}

-(NSColor *)colorFromString:(NSString *)string
{
    if (string == nil) {
        return nil;
    }
    
    int r = 0, g = 0, b =0, a = 0xff;
    if ([string length] == 10) {
        // 0xffccbbaa
        sscanf([string UTF8String], "0x%02x%02x%02x%02x", &r, &g, &b, &a);
    }
    else if ([string length] == 8) {
        // 0xccbbaa
        sscanf([string UTF8String], "0x%02x%02x%02x", &r, &g, &b);
    }
    
    return [NSColor colorWithDeviceRed:(CGFloat)r / 255. green:(CGFloat)g / 255. blue:(CGFloat)b / 255. alpha:(CGFloat)a / 255.];
}

static NSFontDescriptor* getFontDescriptor(NSString *fullname)
{
    if (fullname == nil) {
        return nil;
    }
    
    NSArray *fontNames = [fullname componentsSeparatedByString:@","];
    NSMutableArray *validFontDescriptors = [NSMutableArray arrayWithCapacity:[fontNames count]];
    for (__strong NSString *fontName in fontNames) {
        fontName = [fontName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([NSFont fontWithName:fontName size:0.0] != nil) {
            [validFontDescriptors addObject:[NSFontDescriptor fontDescriptorWithName:fontName size:0.0]];
        }
    }
    
    if ([validFontDescriptors count] == 0) {
        return nil;
    }
    else if ([validFontDescriptors count] == 1) {
        return [validFontDescriptors objectAtIndex:0];
    }
    
    NSFontDescriptor *initialFontDescriptor = [validFontDescriptors objectAtIndex:0];
    NSArray *fallbackDescriptors = [validFontDescriptors subarrayWithRange:NSMakeRange(1, [validFontDescriptors count] - 1)];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:fallbackDescriptors forKey:NSFontCascadeListAttribute];
    return [initialFontDescriptor fontDescriptorByAddingAttributes:attributes];
}

-(void)updateUIStyle:(MJUIStyle *)style
{
    _horizontal = style.horizontal;
    _inlinePreedit = style.inlinePreedit;
    
    if (style.fontSize == 0) {  // default size
        style.fontSize = kFontSize;
    }
    
    NSFontDescriptor* fontDescriptor = nil;
    NSFont* font = nil;
    if (style.fontName != nil) {
        fontDescriptor = getFontDescriptor(style.fontName);
        if (fontDescriptor != nil) {
            font = [NSFont fontWithDescriptor:fontDescriptor size:style.fontSize];
        }
    }
    if (font == nil) {
        // use default font
        font = [NSFont userFontOfSize:style.fontSize];
    }

    
    [_attrs setObject:font forKey:NSFontAttributeName];
    [_highlightedAttrs setObject:font forKey:NSFontAttributeName];
    
    
    [_preeditAttrs setObject:font forKey:NSFontAttributeName];
    [_preeditHighlightedAttrs setObject:font forKey:NSFontAttributeName];
    
    [_tipsAttrs setObject:font forKey:NSFontAttributeName];
    [_preeditHighlightedAttrs setObject:font forKey:NSFontAttributeName];
    
    
    if (style.candidateTextColor != nil) {
        NSColor *color = [self colorFromString:style.candidateTextColor];
        [_attrs setObject:color forKey:NSForegroundColorAttributeName];
    }
    else {
        [_attrs setObject:[NSColor controlTextColor] forKey:NSForegroundColorAttributeName];
    }
    _labelAttrs = _attrs;
    
    
    
    
    if (style.highlightedCandidateTextColor != nil) {
        NSColor *color = [self colorFromString:style.highlightedCandidateTextColor];
        [_highlightedAttrs setObject:color forKey:NSForegroundColorAttributeName];
    }
    else {
        [_highlightedAttrs setObject:[NSColor selectedControlTextColor] forKey:NSForegroundColorAttributeName];
    }
    if (style.highlightedBackgroundColor != nil) {
        NSColor *color = [self colorFromString:style.highlightedBackgroundColor];
        [_highlightedAttrs setObject:color forKey:NSBackgroundColorAttributeName];
    }
    else {
        [_highlightedAttrs setObject:[NSColor selectedTextBackgroundColor] forKey:NSBackgroundColorAttributeName];
    }
    _labelHighlightedAttrs = _highlightedAttrs;
    
    
    
    if (style.textColor != nil) {
        NSColor *color = [self colorFromString:style.textColor];
        [_preeditAttrs setObject:color forKey:NSForegroundColorAttributeName];
    }
    else {
        [_preeditAttrs setObject:[NSColor disabledControlTextColor] forKey:NSForegroundColorAttributeName];
    }
    _tipsAttrs = _preeditAttrs;
    
    
    
    if (style.highlightedTextColor != nil) {
        NSColor *color = [self colorFromString:style.highlightedTextColor];
        [_preeditHighlightedAttrs setObject:color forKey:NSForegroundColorAttributeName];
    }
    else {
        [_preeditHighlightedAttrs setObject:[NSColor controlTextColor] forKey:NSForegroundColorAttributeName];
    }
    
    if (style.highlightedBackgroundColor != nil) {
        NSColor *color = [self colorFromString:style.highlightedBackgroundColor];
        [_preeditHighlightedAttrs setObject:color forKey:NSBackgroundColorAttributeName];
    }
    else {
        [_preeditHighlightedAttrs removeObjectForKey:NSBackgroundColorAttributeName];
    }
    _tipsHighlightedAttrs = _preeditHighlightedAttrs;
    
    if (style.backgroundColor != nil) {
        NSColor *color = [self colorFromString:style.backgroundColor];
        [_view setBackgroundColor:(color)];
    }
    else {
        // default color
        [_view setBackgroundColor:nil];
    }
    
    [_view setHorizontal:style.horizontal];
    [_view setCornerRadius:style.cornerRadius];
    [_view setBorderHeight:style.borderHeight];
    [_view setBorderWidth:style.borderWidth];
    
    if (style.alpha == 0.0) {
        style.alpha = 1.0;
    }
    [_window setAlphaValue:style.alpha];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.paragraphSpacing = style.spacing;
    _paragraphStyle = paragraphStyle;
    
    paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.paragraphSpacing = style.spacing;
    _preeditParagraphStyle = paragraphStyle;
}

@end
