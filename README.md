# Wilde

> Wilde, named after the author Oscar Wilde, is a helper class that eases the pain of creating and drawing attributed strings.

## To-do: (Just starting development, much more to come)
* Some basic HTML helpers
* Text selection (copy/select/select all)
* And more...

## Setting up
> Setup is easy, just copy Wilde.h and Wilde.m into your project. Make sure you are also including CoreText.framework.

## Example usage.
> Create a new Wilde object and set the desired attributes.  You can change attributes and append strings, images, or views were needed.  Wilde will
do it's best to position images in views in relation to your text (where you append it in your stack). You can view the Example view (ORFTestView)
for a working example of building out your text stack.

```objectivec

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


```

## If you need me
* [Github](http://www.github.com/wess)
* [@WessCope](http://www.twitter.com/wesscope)

## License
Read LICENSE file for more info.

## What is this ORF prefix?
ORF is the prefix for an upcoming typesetting framework currently underdevelopment, called Orwell.  Once Orwell is in a place, this
class will be merged into it.