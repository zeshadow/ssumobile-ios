//
//  NSString+html.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "NSString+html.h"
#import "SSULogging.h"

@implementation NSString (html)

- (NSString *)stringByDecodingXMLEntities {
    NSUInteger myLength = self.length;
    NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
    
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return self;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
    
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:self];
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if (scanner.atEnd) {
            return result;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&#39;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
            
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            if (gotNumber) {
                [result appendFormat:@"%u", charCode];
            }
            else {
                NSString *unknownEntity = @"";
                [scanner scanUpToString:@";" intoString:&unknownEntity];
                [result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                SSULogError(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
            }
            [scanner scanString:@";" intoString:NULL];
        }
        else {
            NSString *unknownEntity = @"";
            [scanner scanUpToString:@";" intoString:&unknownEntity];
            NSString *semicolon = @"";
            [scanner scanString:@";" intoString:&semicolon];
            [result appendFormat:@"%@%@", unknownEntity, semicolon];
            SSULogError(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
        }
    }
    while (!scanner.atEnd);
    
    return result;
}

@end
