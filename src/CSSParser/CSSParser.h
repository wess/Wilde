//
//  CSSParser.h
//  Wilde
//
//  Created by Wess Cope on 11/26/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//
// Taken from Sam Stewart (https://github.com/veritech/CSSApply)
// Updated By Wess Cope.
//

#import <Foundation/Foundation.h>

@interface CSSParser : NSObject {
@private
    NSMutableDictionary*  _ruleSets;
    NSMutableArray*       _activeCssSelectors;
    NSMutableDictionary*  _activeRuleSet;
    NSString*             _activePropertyName;
    
    NSString*             _lastTokenText;
    int                   _lastToken;
    
    union {
        struct {
            int InsideDefinition : 1;
            int InsideProperty : 1;
            int InsideFunction : 1;
        } Flags;
        int _data;
    } _state;
}

- (NSDictionary*)parseFilename:(NSString*)filename;
+ (NSDictionary*)parseFilename:(NSString*)filename;
+ (NSDictionary *)attributesForCSSFile:(NSString *)filename;
@end
