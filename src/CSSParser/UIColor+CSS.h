//
//  UIColor+CSS.h
//  Wilde
//
//  Created by Thomas Davie on 30/12/2011.
//  Copyright (c) 2011 Thomas Davie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CSS)
+ (id)colorWithCSSName:(NSString *)colorName;
+ (UIColor *)fromHexString:(NSString *)hexString;
@end