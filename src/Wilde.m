//
//  Wilde.m
//  Wilde
//
//  Created by Wess Cope on 11/26/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//

#import "Wilde.h"

#pragma mark - Callback Functions for Image RunDelegate -
void ORFImageRunDelegateDeallocCallback(void *reference)
{
}

CGFloat ORFImageRunDelegateAscentCallback(void *reference)
{
    UIImage *image = (__bridge UIImage *)reference;
    return image.size.height;
}

CGFloat ORFImageDelegateDescentCallback(void *reference)
{
    return 0.0f;
}

CGFloat ORFImageRunDelegateWidthCallback(void *reference)
{
    UIImage *image = (__bridge UIImage *)reference;
    return image.size.width - 4.0f;
}

#pragma mark - Callback Functions for View RunDelegate -
void ORFViewRunDelegateDeallocCallback(void *reference)
{
}

CGFloat ORFViewRunDelegateAscentCallback(void *reference)
{
    UIImage *image = (__bridge UIImage *)reference;
    return image.size.height;
}

CGFloat ORFViewDelegateDescentCallback(void *reference)
{
    return 0.0f;
}

CGFloat ORFViewRunDelegateWidthCallback(void *reference)
{
    UIImage *image = (__bridge UIImage *)reference;
    return image.size.width - 4.0f;
}

static NSString *kORFImageAttributeName = @"kORFImageAttributeName";
static NSString *kORFViewAttributeName  = @"kORFViewAttributeName";

@interface Wilde()
- (void)drawImagesForFrame:(CTFrameRef)frame;
@end

@implementation Wilde

- (id)init
{
    self = [super init];
    if(self)
    {
        _attributedString   = [[NSMutableAttributedString alloc] init];
        _paragraphStyle     = [[NSMutableParagraphStyle alloc] init];
        _font               = [UIFont systemFontOfSize:12.0f];
        _lineHeight         = _font.pointSize * 1.5f;
        _foregroundColor    = [UIColor blackColor];
        _strokeWidth        = 0.0f;
        _strokeColor        = [UIColor clearColor];
        _shadowColor        = [UIColor clearColor];
        _shadowOffset       = CGSizeZero;
        _shadowRadius       = 0.0f;
    }
    return self;
}

- (NSDictionary *)attributes
{
    NSShadow *shadow        = [[NSShadow alloc] init];
    shadow.shadowColor      = self.shadowColor;
    shadow.shadowOffset     = self.shadowOffset;
    shadow.shadowBlurRadius = self.shadowRadius;

    self.paragraphStyle.lineSpacing     = _lineHeight;
    self.paragraphStyle.lineBreakMode   = self.linebreakMode;
    self.paragraphStyle.alignment       = self.alignment;
    
    return @{
        NSFontAttributeName                 : self.font,
        NSParagraphStyleAttributeName       : self.paragraphStyle,
        NSForegroundColorAttributeName      : self.foregroundColor,
        NSStrokeColorAttributeName          : self.strokeColor,
        NSStrokeWidthAttributeName          : @(self.strokeWidth),
        NSUnderlineStyleAttributeName       : @(self.underline),
        NSStrikethroughStyleAttributeName   : @(self.strikethrough),
        NSShadowAttributeName               : shadow
    };
}

- (void)appendStringWithFormat:(NSString *)string, ...
{
    if(!string)
        return;
    
    va_list args;
    va_start(args, string);
    NSString *output = [[NSString alloc] initWithFormat:string arguments:args];
    va_end(args);
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:output attributes:self.attributes];
    
    [self.attributedString appendAttributedString:attributedString];
}

- (void)appendImage:(UIImage *)image
{
    const CTRunDelegateCallbacks callbacks = {
        .version    = kCTRunDelegateVersion1,
        .dealloc    = ORFImageRunDelegateDeallocCallback,
        .getAscent  = ORFImageRunDelegateAscentCallback,
        .getDescent = ORFImageDelegateDescentCallback,
        .getWidth   = ORFImageRunDelegateWidthCallback
    };
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)image);
    NSDictionary *attributes = @{
        (__bridge id)kCTRunDelegateAttributeName: (__bridge id)delegate,
        kORFImageAttributeName: image
    };
    
    NSAttributedString *imageString = [[NSAttributedString alloc] initWithString:@"\uFFFC" attributes:attributes];
    CFRelease(delegate);
    
    [self.attributedString appendAttributedString:imageString];
}

- (void)appendView:(UIView *)view
{
    const CTRunDelegateCallbacks callbacks = {
        .version    = kCTRunDelegateVersion1,
        .dealloc    = ORFViewRunDelegateDeallocCallback,
        .getAscent  = ORFViewRunDelegateAscentCallback,
        .getDescent = ORFViewDelegateDescentCallback,
        .getWidth   = ORFViewRunDelegateWidthCallback
    };
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)view);
    NSDictionary *attributes = @{
        (__bridge id)kCTRunDelegateAttributeName: (__bridge id)delegate,
        kORFViewAttributeName: view
    };
    
    NSAttributedString *viewString = [[NSAttributedString alloc] initWithString:@"\uFFFC" attributes:attributes];
    CFRelease(delegate);
    
    [self.attributedString appendAttributedString:viewString];
}

#pragma mark - Size Methods -

- (CGSize)suggestedSizeConstrainedToSize:(CGSize)size;
{
    CTFramesetterRef framesetter    = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedString);
    CGSize suggestedSize            = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, size, NULL);
    
    CFRelease(framesetter);
    
    return suggestedSize;
}

- (CGFloat)suggestedHeightForWidth:(CGFloat)width
{
    return [self suggestedSizeConstrainedToSize:CGSizeMake(width, CGFLOAT_MAX)].height;
}

- (CGFloat)suggestedWidthForHeight:(CGFloat)height
{
    return [self suggestedSizeConstrainedToSize:CGSizeMake(CGFLOAT_MAX, height)].width;
}

#pragma mark - Drawing Methods -
- (void)drawImagesForFrame:(CTFrameRef)frame
{
    CGRect rect             = CGPathGetBoundingBox(CTFrameGetPath(frame));
    CFArrayRef lines        = CTFrameGetLines(frame);
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    [self.attributedString enumerateAttribute:(id)kORFImageAttributeName inRange:NSMakeRange(0, self.attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        UIImage *image      = (UIImage *)value;
        CGRect imageFrame   = CGRectMake(rect.origin.x, rect.origin.y, image.size.width, image.size.height);
        
        for(CFIndex i = 0; i < CFArrayGetCount(lines); i++)
        {
            CTLineRef line      = CFArrayGetValueAtIndex(lines, i);
            CFRange lineRange   = CTLineGetStringRange(line);
            
            int lineIndex = range.location - lineRange.location;
            if(lineIndex >= 0 && lineIndex < lineRange.length)
            {
                CGPoint lineOrigin;
                CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &lineOrigin);

                imageFrame.origin.x += CTLineGetOffsetForStringIndex(line, range.location, NULL);
                imageFrame.origin.y += lineOrigin.y - 2.0f;
                
                break;
            }
        }
        
        CGContextDrawImage(context, imageFrame, image.CGImage);
    }];
}

- (void)drawViewsForFrame:(CTFrameRef)frame
{
    CGRect rect             = CGPathGetBoundingBox(CTFrameGetPath(frame));
    CFArrayRef lines        = CTFrameGetLines(frame);
    
    [self.attributedString enumerateAttribute:(id)kORFViewAttributeName inRange:NSMakeRange(0, self.attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        UIView *view      = (UIView *)value;
        CGRect viewFrame   = CGRectMake(rect.origin.x, rect.origin.y, view.frame.size.width, view.frame.size.height);
        
        for(CFIndex i = 0; i < CFArrayGetCount(lines); i++)
        {
            CTLineRef line      = CFArrayGetValueAtIndex(lines, i);
            CFRange lineRange   = CTLineGetStringRange(line);
            
            int lineIndex = range.location - lineRange.location;
            if(lineIndex >= 0 && lineIndex < lineRange.length)
            {
                CGPoint lineOrigin;
                CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &lineOrigin);
                
                viewFrame.origin.x = CTLineGetOffsetForStringIndex(line, range.location, NULL) +  lineOrigin.x - 2.0f;
                viewFrame.origin.y = rect.size.height - (lineOrigin.y + viewFrame.size.height);
                
                break;
            }
        }
    
        view.frame = viewFrame;
    }];
}

- (void)drawAttributedStringWithFramesetter:(CTFramesetterRef)framesetter inFrame:(CGRect)frame
{
    CGRect rect             = frame;
    rect.origin.y           = 0.0f;
    CGPathRef path          = CGPathCreateWithRect(rect, NULL);
    CTFrameRef frameRef     = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextSaveGState(context);
    CGContextConcatCTM(context, CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, (rect.origin.y + rect.size.height)));

    [self drawImagesForFrame:frameRef];
    [self drawViewsForFrame:frameRef];
    
    CTFrameDraw(frameRef, context);
    CGContextRestoreGState(context);
    
    CFRelease(path);
    CFRelease(frameRef);
}

@end
