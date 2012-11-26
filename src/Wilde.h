//
//  Wilde.h
//  Wilde
//
//  Created by Wess Cope on 11/26/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface Wilde : NSObject
@property (readonly, nonatomic) NSMutableAttributedString   *attributedString;
@property (readonly, nonatomic) NSMutableParagraphStyle     *paragraphStyle;
@property (readonly, nonatomic) NSDictionary                *attributes;
@property (strong, nonatomic)   UIFont                      *font;
@property (strong, nonatomic)   UIColor                     *foregroundColor;
@property (strong, nonatomic)   UIColor                     *strokeColor;
@property (nonatomic)           CGFloat                     strokeWidth;
@property (nonatomic)           BOOL                        underline;
@property (nonatomic)           BOOL                        strikethrough;
@property (nonatomic)           CGFloat                     lineHeight;
@property (nonatomic)           CGSize                      shadowOffset;
@property (nonatomic)           UIColor                     *shadowColor;
@property (nonatomic)           CGFloat                     shadowRadius;
@property (nonatomic)           NSTextAlignment             alignment;
@property (nonatomic)           NSLineBreakMode             linebreakMode;

- (void)appendStringWithFormat:(NSString *)string, ...;
- (void)appendImage:(UIImage *)image;
- (void)appendView:(UIView *)view;

- (CGSize)suggestedSizeConstrainedToSize:(CGSize)size;
- (CGFloat)suggestedHeightForWidth:(CGFloat)width;
- (CGFloat)suggestedWidthForHeight:(CGFloat)height;

- (void)drawAttributedStringWithFramesetter:(CTFramesetterRef)framesetter inFrame:(CGRect)frame;

@end
