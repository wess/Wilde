//
//  ORFTestView.m
//  Wilde
//
//  Created by Wess Cope on 11/26/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//

#import "ORFTestView.h"
#import <CoreText/CoreText.h>
#import "Wilde.h"

@implementation ORFTestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    Wilde *attrString = [Wilde new];
    attrString.font             = [UIFont boldSystemFontOfSize:16.0f];
    attrString.foregroundColor  = [UIColor redColor];
    attrString.linebreakMode    = NSLineBreakByWordWrapping;
    attrString.lineHeight       = 0.0f;
    attrString.underline        = YES;
    attrString.shadowColor      = [UIColor blueColor];
    attrString.shadowOffset     = CGSizeMake(0.0f, 4.0f);
    attrString.shadowRadius     = 4.0f;
    attrString.alignment        = NSTextAlignmentCenter;
    
    [attrString appendStringWithFormat:@"This is a little String "];
    [attrString appendImage:[UIImage imageNamed:@"09-chat-2"]];
    
    attrString.foregroundColor  = [UIColor purpleColor];
    attrString.font             = [UIFont systemFontOfSize:40.0f];
    attrString.underline        = NO;
    [attrString appendStringWithFormat:@" Here is the end of said string    "];
    
    attrString.font             = [UIFont systemFontOfSize:12.0f];
    attrString.foregroundColor  = [UIColor greenColor];
    [attrString appendImage:[UIImage imageNamed:@"92-test-tube"]];
    [attrString appendStringWithFormat:@"  this is more text after the image"];

    [attrString appendStringWithFormat:@"Here is a view that is embedded "];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    view.backgroundColor = [UIColor orangeColor];
    [self addSubview:view];

    [attrString appendView:view];
    [attrString appendStringWithFormat:@" some string format love %@", @"here"];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrString.attributedString);
    [attrString drawAttributedStringWithFramesetter:framesetter inFrame:rect];
    
}



@end
