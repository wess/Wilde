# Wilde

> Wilde, named after the author Oscar Wilde, is a helper class that eases the pain of creating and drawing attributed strings.

## Getting started:
> Currently, to use Wilde, you will need to follow the following steps and copy the requested files into your project.
There are plans to move Wilde to static library before a 1.0 release.

* First grab the Wilde repository:
``` git submodule add git://github.com:wess/Wilde.git ```

* The grab Wilde's submodules:
``` git submodule update --init --recursive ```

* Add CoreText.framework to your project

* Add src/Wilde.[hm] to your project. Make sure they are added to your build.

* Add Archimedes/Archimedes/Archimedes.h and CGGeometry+MEDConvenienceAdditions.[hm] to your project. Make sure they are added to your build.

* Add hpple/TFHpple.[hm], hpple/TFHppleElement.[hm] and hpple/XPathQuery.[hm] to your project. Make sure they are added to your build.




## Wilde now offers support for basic HTML tagging:

_Currently available tags._
<table>
<tr>
    <td valign="top" width=120>&lt;b&gt; and &lt;strong&gt;</td>
    <td valign="top">Bold text. Wilde defaults to the bold system font unless you set the boldFont property.</td>
</tr>
<tr>
    <td valign="top">&lt;i&gt; and &lt;em&gt;</td>
    <td valign="top">Italic text. (As with bold, defaults to italic system font unless you set italicFont propery).</td>
</tr>
<tr>
    <td valign="top">&lt;ul&gt;</td>
    <td valign="top">Starts a list. Inserts a new line for first list item.</td>
</tr>
<tr>
    <td valign="top">&lt;li&gt;</td>
    <td valign="top">Inserts a 'bullet' character, set listBulletCharacter to any string value for a bullet also set listItemIndent to an integer for indenting list items</td>
</tr>
<tr>
    <td valign="top">&lt;p&gt;</td>
    <td valign="top">Inserts \r\n at the end of paragraph block.</td>
</tr>
<tr>
    <td valign="top">&lt;br&gt;</td>
    <td valign="top">Replaced in-text with carriage return (\n)</td>
</tr>
<tr>
    <td valign="top">&lt;a href&gt;</td>
    <td valign="top">Will be parsed, and Wilde will store a reference to the link's text and url. In order to retrieve the url from link copy from the parsed attributed string, you call the method: -urlStringForTextAtPoint: with a point in the view.
For this feature to work you must use Wilde's text drawing method, to ensure that proper frames and references are setup.  Below, touchEnds method has been added
to show how to get a link from the draw text. When the method is called, Wilde will test the point you pass to it against the frame it used to draw the text with,
if a url is present it will then pass it back, otherwise nil is returned.</td>
</tr>
</table>

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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];

    NSString *link = [attrString urlStringForTextAtPoint:location];
    if(link)
        NSLog(@"LINK: %@", link);

}

```

## Contact Developer:
* [Github](http://www.github.com/wess)
* [@WessCope](http://www.twitter.com/wesscope)

## License?
Read LICENSE file for more info.


## Special Thanks:
* Thanks to [Jeremy Tregunna](https://github.com/jeremytregunna) for helping with CoreText for a while now, and proof reading all the things.
* Thanks to [Erica Sadun](http://www.amazon.com/Core-Developers-Cookbook-Edition-Library/dp/0321884213) for writing awesome books and helping me out with getting CoreText under control.

## To-do: (Just starting development, much more to come)
* Add support for HTML tags
* Add support for CSS styling
* Add text selection (copy/select/select all)
* And more...

## What is this ORF prefix?
ORF is the prefix for an upcoming typesetting framework currently underdevelopment, called Orwell. Wilde will be merged into the Orwell framework at a later date.
