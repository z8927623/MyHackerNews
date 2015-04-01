//
//  MAMHNComment.m
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-22.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "MAMHNComment.h"
#import "NSString+Additions.h"

@implementation MAMHNComment
{
    NSString *_commentStorage;
    UIColor *_commentColor;
    
    int _indentationLevel;
}

- (void)setComment:(NSString *)comment
{
    NSString *hexColor = [comment stringBetweenString:@"<font color=\"" andString:@"\">"];
    _commentColor = [self colorFromHexString:hexColor];
    
    NSString *commentString = [comment stringBetweenString:@"\">" andString:@"</font>"];
    
    NSMutableString *mutableComment = [commentString mutableCopy];
    [mutableComment replaceOccurrencesOfString:@"<p>" withString:@"\n\n" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"</p>" withString:@"" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"<i>" withString:@"" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"</i>" withString:@"" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"&#38" withString:@"&" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"&#62" withString:@">" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"&#60" withString:@"<" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"<pre><code>" withString:@"" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"</code></pre>" withString:@"" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"&gt;" withString:@"" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"&lt;" withString:@"" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"<p/> " withString:@"\n>" options:0 range:rg(mutableComment)];
    [mutableComment replaceOccurrencesOfString:@"<a href=\"" withString:@"" options:0 range:rg(mutableComment)];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\" rel=\"nofollow\">.*?</a>" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:mutableComment options:0 range:NSMakeRange(0, [mutableComment length]) withTemplate:@"$1"];
    
    _commentStorage = modifiedString;
}

NSRange rg(NSString *str)
{
    return NSMakeRange(0, str.length);
}

- (NSString *)comment
{
    return _commentStorage;
}

- (UIColor *)color
{
    return _commentColor;
}

- (void)setIndentationLevel:(int)level
{
    _indentationLevel = level;
}

- (int)indentationLevel
{
    return _indentationLevel;
}

- (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
