//
//  Wilde.h
//  Wilde
//
//  Created by Wess Cope on 11/26/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

static NSString *const kWildBulletCharacter = @"\u2022";
static NSString *kORFImageAttributeName = @"kORFImageAttributeName";
static NSString *kORFViewAttributeName  = @"kORFViewAttributeName";
static NSString *kORFLinkAttributeName  = @"kORFLineAttributeName";

@interface WildeLinkAttribute : NSObject
@property (readonly, nonatomic) NSString *text;
@property (readonly, nonatomic) NSString *urlString;
@property (readonly, nonatomic) NSURL *url;
@property (readonly, nonatomic) NSRange textRange;

+ (WildeLinkAttribute *)createLinkWithText:(NSString *)text urlString:(NSString *)urlString andRange:(NSRange)range;
- (id)initWithText:(NSString *)text urlString:(NSString *)urlString andRange:(NSRange)range;
@end

@interface Wilde : NSObject
@property (readonly, nonatomic) NSMutableAttributedString   *attributedString;
@property (readonly, nonatomic) NSMutableParagraphStyle     *paragraphStyle;
@property (readonly, nonatomic) NSDictionary                *attributes;
@property (strong, nonatomic)   UIFont                      *font;
@property (strong, nonatomic)   UIFont                      *boldFont;
@property (strong, nonatomic)   UIFont                      *italicFont;
@property (strong, nonatomic)   UIFont                      *headlineFont;
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
@property (copy, nonatomic)     NSString                    *listBulletCharacter;
@property (nonatomic)           NSInteger                    listItemIndent;
@property (nonatomic)           BOOL                        shouldDetectUrls;
@property (nonatomic)           BOOL                        shouldDetectPhoneNumbers;
@property (nonatomic)           BOOL                        shouldDetectEmailAddresses;
@property (assign)              BOOL                        canClickOnLinks;
@property (nonatomic, copy)     NSString                    *cssFile;

- (void)appendStringWithFormat:(NSString *)string, ...;
- (void)appendImage:(UIImage *)image;
- (void)appendView:(UIView *)view;

- (CGSize)suggestedSizeConstrainedToSize:(CGSize)size;
- (CGFloat)suggestedHeightForWidth:(CGFloat)width;
- (CGFloat)suggestedWidthForHeight:(CGFloat)height;

- (void)drawAttributedStringWithFramesetter:(CTFramesetterRef)framesetter inFrame:(CGRect)frame;
- (NSString *)urlStringForTextAtPoint:(CGPoint)point;
@end
