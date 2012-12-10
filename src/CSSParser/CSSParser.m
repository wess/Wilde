//
//  CSSParser.m
//  Wilde
//
//  Created by Wess Cope on 11/26/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//
// Taken from Sam Stewart (https://github.com/veritech/CSSApply)
// Updated By Wess Cope.
//

#import "CSSTokens.h"
#import "css.h"
#import "CSSParser.h"
#import "UIColor+CSS.h"

UIColor *colorFromCSSColor(NSString *cssColor)
{
    if([cssColor rangeOfString:@"rgba"].location != NSNotFound)
    {
        cssColor = [cssColor stringByReplacingOccurrencesOfString:@"rgba(" withString:@""];
        cssColor = [cssColor stringByReplacingOccurrencesOfString:@")" withString:@""];
        cssColor = [cssColor stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSArray *components = [cssColor componentsSeparatedByString:@","];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        CGFloat red     = [[formatter numberFromString:components[0]] floatValue];
        CGFloat green   = [[formatter numberFromString:components[0]] floatValue];
        CGFloat blue    = [[formatter numberFromString:components[0]] floatValue];
        CGFloat alpha   = [[formatter numberFromString:components[0]] floatValue];

        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    else if([cssColor rangeOfString:@"rgb"].location != NSNotFound)
    {
        cssColor = [cssColor stringByReplacingOccurrencesOfString:@"rgb(" withString:@""];
        cssColor = [cssColor stringByReplacingOccurrencesOfString:@")" withString:@""];
        cssColor = [cssColor stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSArray *components = [cssColor componentsSeparatedByString:@","];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        CGFloat red     = [[formatter numberFromString:components[0]] floatValue];
        CGFloat green   = [[formatter numberFromString:components[0]] floatValue];
        CGFloat blue    = [[formatter numberFromString:components[0]] floatValue];
        CGFloat alpha   = [[formatter numberFromString:components[0]] floatValue];
        
        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];        
    }
    else if([cssColor rangeOfString:@"#"].location != NSNotFound)
    {
        return [UIColor fromHexString:cssColor];
    }
    
    return [UIColor colorWithCSSName:cssColor];
}

typedef enum {
    None,
    
} ParserStates;

CSSParser* gActiveParser = nil;

@interface CSSParser()

- (void)consumeToken:(int)token text:(char*)text;

@end


int cssConsume(char* text, int token) {
    [gActiveParser consumeToken:token text:text];
    
    return 0;
}


@implementation CSSParser
- (id)init {
	self = [super init];
    if (self) {
        _ruleSets           = [[NSMutableDictionary alloc] init];
        _activeCssSelectors = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (void)consumeToken:(int)token text:(char*)text {
    NSString* string = [[NSString stringWithCString: text
                                           encoding: NSUTF8StringEncoding] lowercaseString];
//    NSLog(@" %x : %@",token,string);
    
    switch (token) {
        case CSSHASH:
        case CSSIDENT: {
            if (_state.Flags.InsideDefinition) {
                
                // If we're inside a definition then we ignore hashes.
                if (CSSHASH != token && !_state.Flags.InsideProperty) {
                    _activePropertyName = nil;
                    _activePropertyName = [string copy];
                    
                    NSMutableArray* values = [[NSMutableArray alloc] init];
                    [_activeRuleSet setObject:values forKey:_activePropertyName];
                    
                } else {
                    // This is a value, so add it to the active property.
                    //TTDASSERT(nil != _activePropertyName);
                    
                    if (nil != _activePropertyName) {
                        NSMutableArray* values = [_activeRuleSet objectForKey:_activePropertyName];
                        [values addObject:string];
                    }
                }
                
            } else {
                if (_lastToken == CSSUNKNOWN && [_lastTokenText isEqualToString:@"."]) {
                    string = [_lastTokenText stringByAppendingString:string];
                }
                [_activeCssSelectors addObject:string];
                _activePropertyName = nil;
            }
            break;
        }
            
        case CSSFUNCTION: {
            if (_state.Flags.InsideProperty) {
                _state.Flags.InsideFunction = YES;
                
                if (nil != _activePropertyName) {
                    NSMutableArray* values = [_activeRuleSet objectForKey:_activePropertyName];
                    [values addObject:string];
                }
            }
            break;
        }
            
        case CSSSTRING:
        case CSSEMS:
        case CSSEXS:
        case CSSLENGTH:
        case CSSANGLE:
        case CSSTIME:
        case CSSFREQ:
        case CSSDIMEN:
        case CSSPERCENTAGE:
        case CSSNUMBER:
        case CSSURI: {
            // (nil != _activePropertyName);
            
            if (nil != _activePropertyName) {
                NSMutableArray* values = [_activeRuleSet objectForKey:_activePropertyName];
                [values addObject:string];
            }
            break;
        }
            
        case CSSUNKNOWN: {
            switch (text[0]) {
                case '{': {
                    _state.Flags.InsideDefinition = YES;
                    _state.Flags.InsideFunction = NO;
                    _activeRuleSet = nil;
                    _activeRuleSet = [[NSMutableDictionary alloc] init];
                    break;
                }
                    
                case '}': {
                    for (NSString* name in _activeCssSelectors) {
                        NSMutableDictionary* existingProperties = [_ruleSets objectForKey:name];
                        if (nil != existingProperties) {
                            // Overwrite the properties, instead!
                            
                            NSDictionary* iteratorProperties = [_activeRuleSet copy];
                            for (NSString* key in iteratorProperties) {
                                [existingProperties setObject:[_activeRuleSet objectForKey:key] forKey:key];
                            }
                            
                        } else {
                            NSMutableDictionary* ruleSet = [_activeRuleSet mutableCopy];
                            [_ruleSets setObject:ruleSet forKey:name];
                        }
                    }
                    _activeRuleSet = nil;
                    [_activeCssSelectors removeAllObjects];
                    _state.Flags.InsideDefinition = NO;
                    _state.Flags.InsideProperty = NO;
                    _state.Flags.InsideFunction = NO;
                    break;
                }
                    
                case ':': {
                    if (_state.Flags.InsideDefinition) {
                        _state.Flags.InsideProperty = YES;
                    }
                    break;
                }
                    
                case ')': {
                    if (_state.Flags.InsideFunction && nil != _activePropertyName) {
                        NSMutableArray* values = [_activeRuleSet objectForKey:_activePropertyName];
                        [values addObject:string];
                    }
                    _state.Flags.InsideFunction = NO;
                    break;
                }
                    
                case ';': {
                    if (_state.Flags.InsideDefinition) {
                        _state.Flags.InsideProperty = NO;
                    }
                    break;
                }
                    
            }
            break;
        }
    }
    
    _lastTokenText = [string copy];
    _lastToken = token;
}

#pragma mark -
#pragma mark Public



- (NSDictionary*)parseFilename:(NSString*)filename {
    gActiveParser = self;
    
    [_ruleSets removeAllObjects];
    [_activeCssSelectors removeAllObjects];

    _activeRuleSet          = nil;
    _activePropertyName     = nil;
    _lastTokenText          = nil;
    NSBundle *mainBundle    = [NSBundle mainBundle];
    NSString *pathForFile   = [mainBundle pathForResource:filename ofType:@""];

    cssin = fopen([pathForFile UTF8String], "r");
    
    csslex();
    
    fclose(cssin);
    
    NSDictionary* result = [_ruleSets copy];
    _ruleSets = nil;
    
    return result;
}

+ (NSDictionary*)parseFilename:(NSString*)filename
{
    CSSParser  *parser = [[CSSParser alloc] init];
    return [parser parseFilename:filename];
}

+ (NSDictionary *)attributesForCSSFile:(NSString *)filename
{
    __block NSMutableDictionary *attributes = [NSMutableDictionary new];
    NSDictionary *cssAttributes     = [CSSParser parseFilename:filename];
    
    [cssAttributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *property, BOOL *stop) {
        
        __block NSMutableDictionary *properties = [NSMutableDictionary new];
        __block UIFont *font                    = nil;
        __block CGFloat fontSize                = 9.0;
        
        [property enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL *stop) {
            NSString *cssKey = [key lowercaseString];
            
            if([cssKey isEqualToString:@"color"])
            {
                NSString *colorString = [obj componentsJoinedByString:@","];
                colorString = [colorString stringByReplacingOccurrencesOfString:@"(," withString:@"("];
                colorString = [colorString stringByReplacingOccurrencesOfString:@",)" withString:@")"];
                
                [properties setObject:colorFromCSSColor(colorString) forKey:NSForegroundColorAttributeName];
            }
            else if([cssKey isEqualToString:@"font-family"])
            {
                
                NSString *fontName = [obj lastObject];
                font = [UIFont fontWithName:fontName size:fontSize];
            }
            else if([cssKey isEqualToString:@"font-size"])
            {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle        = NSNumberFormatterDecimalStyle;
                
                fontSize    = [[formatter numberFromString:[obj lastObject]] floatValue];
                font        = [UIFont fontWithName:font.fontName size:fontSize];
            }

            if(font)
            {
                [properties setObject:font forKey:[font copy]];
                font = nil;
            }
            
        }];
        
        [attributes setObject:[properties copy] forKey:[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        properties = nil;
        
    }];
    
    return [attributes copy];
}

@end
