//
//  Wilde.m
//  Wilde
//
//  Created by Wess Cope on 11/26/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//

#import "Wilde.h"
#import "TFHpple.h"
#import "CSSParser.h"
#import "Archimedes.h"

@implementation WildeLinkAttribute
- (id)initWithText:(NSString *)text urlString:(NSString *)urlString andRange:(NSRange)range
{
    self = [super init];
    if(self)
    {
        _text       = [text copy];
        _urlString  = [urlString copy];
        _url        = [NSURL URLWithString:_urlString];
        _textRange  = range;
        
    }
    return self;
}
+ (WildeLinkAttribute *)createLinkWithText:(NSString *)text urlString:(NSString *)urlString andRange:(NSRange)range
{
    WildeLinkAttribute *this = [[WildeLinkAttribute alloc] initWithText:text urlString:urlString andRange:range];
    return this;
}

@end

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


static NSString *stringByStrippingHTML(NSString *string)
{
    NSScanner *thescanner   = [NSScanner scannerWithString:string];
    NSString *text          = nil;
    
    while (![thescanner isAtEnd])
    {
		[thescanner scanUpToString:@"<" intoString:NULL];
		[thescanner scanUpToString:@">" intoString:&text];
		
        string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@" "];
    }
	return string;
}

@interface Wilde()
{
    CTFrameRef      _drawingFrameRef;
    NSDataDetector *_dataDetector;
}
@property (readwrite, nonatomic) CGRect             drawingFrame;
@property (strong, nonatomic) NSMutableDictionary   *mutableLinks;
@property (strong, nonatomic) NSMutableArray        *lines;
@property (strong, nonatomic) NSDictionary          *cssRules;

- (NSAttributedString *)attributedStringByAppendingString:(NSString *)string;
- (void)drawImagesForFrame:(CTFrameRef)frame;
@end

@implementation Wilde

- (id)init
{
    self = [super init];
    if(self)
    {
        self.mutableLinks   = [[NSMutableDictionary alloc] init];
        self.lines          = [[NSMutableArray alloc] init];
        
        _dataDetector           = [[NSDataDetector alloc] initWithTypes:(NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink | NSTextCheckingTypeDate | NSTextCheckingTypeAddress) error:nil];
        _drawingFrameRef        = NULL;
        _attributedString       = [[NSMutableAttributedString alloc] init];
        _paragraphStyle         = [[NSMutableParagraphStyle alloc] init];
        _font                   = [UIFont systemFontOfSize:12.0f];
        _boldFont               = [UIFont boldSystemFontOfSize:12.0f];
        _italicFont             = [UIFont fontWithName:@"Helvetica-Oblique" size:12.0f];
        _headlineFont           = [UIFont boldSystemFontOfSize:16.0f];
        _lineHeight             = _font.pointSize * 1.5f;
        _foregroundColor        = [UIColor blackColor];
        _strokeWidth            = 0.0f;
        _strokeColor            = [UIColor clearColor];
        _shadowColor            = [UIColor clearColor];
        _shadowOffset           = CGSizeZero;
        _shadowRadius           = 0.0f;
        _listBulletCharacter    = kWildBulletCharacter;
        _listItemIndent         = 4;
    }
    return self;
}

- (void)setCssFile:(NSString *)cssFile
{
    _cssFile    = [cssFile copy];
    _cssRules   = [CSSParser attributesForCSSFile:_cssFile];
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

- (NSAttributedString *)attributedStringByAppendingString:(NSString *)string
{
    NSString *content                                   = [string copy];
    NSMutableAttributedString *mutableAttributedString  = [[NSMutableAttributedString alloc] initWithString:content attributes:self.attributes];
    TFHpple *doc                                        = [[TFHpple alloc] initWithHTMLData:[[[content copy] lowercaseString] dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray *elements                                   = [doc searchWithXPathQuery:@"//span | //p | //b | //strong | //i | //em | //ul | //li | //a"];
    
    [elements enumerateObjectsUsingBlock:^(TFHppleElement *element, NSUInteger idx, BOOL *stop) {
        NSString *tagName = [element.tagName lowercaseString];

        if(element.text)
        {
            NSRange textRange = [[content lowercaseString] rangeOfString:[element.text lowercaseString]];
    
            if([tagName isEqualToString:@"b"] || [tagName isEqualToString:@"strong"])
            {
                [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.boldFont.fontName size:self.font.pointSize] range:textRange];
            }
            else if([tagName isEqualToString:@"i"] || [tagName isEqualToString:@"em"])
            {
                [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.italicFont.fontName size:self.font.pointSize] range:textRange];
            }
            else if([tagName isEqualToString:@"a"])
            {
                WildeLinkAttribute *linkAttribute = [WildeLinkAttribute createLinkWithText:element.text urlString:element.attributes[@"href"] andRange:textRange];
                [self.mutableLinks setObject:linkAttribute forKey:element.text];
                
                [mutableAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(1) range:textRange];
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:textRange];
                [mutableAttributedString addAttribute:kORFLinkAttributeName value:element.attributes[@"href"] range:textRange];
            }

            if([element.attributes objectForKey:@"id"])
            {
                NSDictionary *elementAttributes = [self.cssRules objectForKey:[NSString stringWithFormat:@"#%@", [element.attributes objectForKey:@"id"]]];
                NSLog(@"Attr: %@", elementAttributes);
                [mutableAttributedString addAttributes:elementAttributes range:textRange];
            }

            if([element.attributes objectForKey:@"class"])
            {
                NSDictionary *elementAttributes = [self.cssRules objectForKey:[NSString stringWithFormat:@".%@", [element.attributes objectForKey:@"class"]]];
                [mutableAttributedString addAttributes:elementAttributes range:textRange];
            }
        }

    }];

    NSScanner *thescanner   = [NSScanner scannerWithString:mutableAttributedString.mutableString];
    NSString *text          = nil;
    
    while (![thescanner isAtEnd])
    {
		[thescanner scanUpToString:@"<" intoString:NULL];
		[thescanner scanUpToString:@">" intoString:&text];

        NSString *replaceString = [NSString stringWithFormat:@"%@>", text];
        
        if(([[text lowercaseString] rangeOfString:@"br"].location != NSNotFound) ||
           ([[text lowercaseString] rangeOfString:@"ul"].location != NSNotFound) ||
           ([[text lowercaseString] rangeOfString:@"/li"].location != NSNotFound))
        {
            [mutableAttributedString.mutableString replaceOccurrencesOfString:replaceString withString:@"\n" options:0 range:NSMakeRange(0, mutableAttributedString.mutableString.length)];
        }
        else if([[text lowercaseString] rangeOfString:@"<p"].location != NSNotFound)
        {
            [mutableAttributedString.mutableString replaceOccurrencesOfString:replaceString withString:@"\r" options:0 range:NSMakeRange(0, mutableAttributedString.mutableString.length)];            
        }
        else if([[text lowercaseString] rangeOfString:@"/p"].location != NSNotFound)
        {
            [mutableAttributedString.mutableString replaceOccurrencesOfString:replaceString withString:@"\r\n" options:0 range:NSMakeRange(0, mutableAttributedString.mutableString.length)];
        }
        if([[text lowercaseString] rangeOfString:@"<li"].location != NSNotFound)
        {
            NSString *listBullet = [[@"" stringByPaddingToLength:(self.listItemIndent * (@" ").length) withString:@" " startingAtIndex:0] stringByAppendingString:kWildBulletCharacter];
            [mutableAttributedString.mutableString replaceOccurrencesOfString:replaceString withString:listBullet options:0 range:NSMakeRange(0, mutableAttributedString.mutableString.length)];
        }
        
        
        [mutableAttributedString.mutableString replaceOccurrencesOfString:replaceString withString:@"" options:0 range:NSMakeRange(0, mutableAttributedString.mutableString.length)];
    }

    if(_shouldDetectEmailAddresses || _shouldDetectPhoneNumbers || _shouldDetectUrls)
    {
        [_dataDetector enumerateMatchesInString:mutableAttributedString.string options:0 range:NSMakeRange(0, mutableAttributedString.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSRange textRange = result.range;
            
            switch (result.resultType)
            {
                case NSTextCheckingTypeLink:
                {
                    [mutableAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(1) range:textRange];
                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:textRange];
                    [mutableAttributedString addAttribute:kORFLinkAttributeName value:[result URL] range:textRange];
                }
                break;
                    
                default:
                    break;
            }
        }];
    }
    
    
    return [mutableAttributedString copy];
}


- (void)appendStringWithFormat:(NSString *)string, ...
{
    if(!string)
        return;
    
    va_list args;
    va_start(args, string);
    NSString *output = [[NSString alloc] initWithFormat:string arguments:args];
    va_end(args);
    
    NSAttributedString *attributedString = [self attributedStringByAppendingString:output];
    
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

    CGRect frameBoundingBox = CGPathGetBoundingBox(path);
    CFArrayRef lines        = CTFrameGetLines(frameRef);

    CGPoint origins[CFArrayGetCount(lines)];                              // the origins of each line at the baseline
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    
    CFIndex linesCount = CFArrayGetCount(lines);
    
    for (int lineIdx = 0; lineIdx < linesCount; lineIdx++)
    {
        CGContextSetTextPosition(context, origins[lineIdx].x + frameBoundingBox.origin.x, frameBoundingBox.origin.y + origins[lineIdx].y);

        CTLineRef line      = (CTLineRef)CFArrayGetValueAtIndex(lines, lineIdx);
        CGRect lineBounds   = CTLineGetImageBounds(line, context);
        
        lineBounds.origin.y = rect.size.height - origins[lineIdx].y - lineBounds.size.height;
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for(int r = 0; r < CFArrayGetCount(runs); r++)
        {
            CTRunRef run        = CFArrayGetValueAtIndex(runs, r);
            CFRange runRange    = CTRunGetStringRange(run);

            CGFloat ascent, descent;
            CGFloat width   = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            CGFloat height  = ascent + descent + 2.0f;
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, runRange.location, NULL);
            CGFloat yOffset = origins[lineIdx].y - descent;
            CGRect bounds   = CGRectMake(xOffset, yOffset, width, height);
  
            bounds = CGRectInvert(frame, bounds);
            
            [self.lines addObject:@{
                @"Range": NSStringFromRange(NSMakeRange(runRange.location, runRange.length)),
                @"Bounds": NSStringFromCGRect(bounds)
             }];            
        }
    }
    
    CTFrameDraw(frameRef, context);

}

- (NSString *)urlStringForTextAtPoint:(CGPoint)point
{
    __block NSString *link = nil;

    [self.lines enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        NSString *boundsString  = [item objectForKey:@"Bounds"];
        NSString *rangeString   = [item objectForKey:@"Range"];
        CGRect bounds           = CGRectFromString(boundsString);
        NSRange range           = NSRangeFromString(rangeString);


        if(CGRectContainsPoint(bounds, point))
        {
            NSRange longRange;
            NSInteger count = range.location + range.length;
            for(int i = range.location; i < count; i++)
            {
                NSDictionary *attributes    = [self.attributedString attributesAtIndex:i longestEffectiveRange:&longRange inRange:NSMakeRange(i, 1)];

                if([attributes objectForKey:kORFLinkAttributeName])
                {
                    link = [[attributes objectForKey:kORFLinkAttributeName] copy];
                    *stop = YES;
                }
            }
        }
    }];
    
    return link;

}

@end

















