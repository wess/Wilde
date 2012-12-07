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

@interface ORFTestView()
{
    CTFramesetterRef _framesetter;
    Wilde *attrString;
}
@end

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
    attrString                  = [Wilde new];
    attrString.font             = [UIFont boldSystemFontOfSize:16.0f];
    attrString.foregroundColor  = [UIColor redColor];
    attrString.linebreakMode    = NSLineBreakByWordWrapping;
    attrString.lineHeight       = 0.0f;
    attrString.underline        = YES;
    attrString.shadowColor      = [UIColor blueColor];
    attrString.shadowOffset     = CGSizeMake(0.0f, 4.0f);
    attrString.shadowRadius     = 4.0f;
    attrString.alignment        = NSTextAlignmentLeft;
    
    [attrString appendStringWithFormat:@"<p>This is a <a href=\"http://www.google.com\">little</a> String</p>"];
    
    attrString.foregroundColor  = [UIColor purpleColor];
    attrString.font             = [UIFont systemFontOfSize:20.0f];
    attrString.underline        = NO;
    [attrString appendStringWithFormat:@"Here is the <strong>end</strong> of said string<br>"];
    
    attrString.font             = [UIFont systemFontOfSize:12.0f];
    attrString.foregroundColor  = [UIColor greenColor];
    [attrString appendStringWithFormat:@"this is more text<br>after the image"];

    [attrString appendStringWithFormat:@"<p><em>Here is a view <br/>that is embedded</em></p>"];
    
    [attrString appendStringWithFormat:@"some string <b>format</b> love %@<br>", @"here"];
    
    attrString.foregroundColor = [UIColor blackColor];
    [attrString appendStringWithFormat:@"<ul><li> list item one</li><li> list item two</li><li> list <a href=\"mailto:you@me.com\">item</a> three</li></ul>"];
    
    
    _framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrString.attributedString);
    [attrString drawAttributedStringWithFramesetter:_framesetter inFrame:rect];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];

    NSString *link = [attrString urlStringForTextAtPoint:location];
    if(link)
        NSLog(@"LINK: %@", link);

}

@end
