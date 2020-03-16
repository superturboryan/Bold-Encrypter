//
//  NSAttributedString_Extension.m
//  Bold Encrypter
//
//  Created by Ryan David Forsyth on 2020-03-16.
//  Copyright © 2020 Ryan David Forsyth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@implementation NSString(extension)

static NSString *kBold = @"!!";
static NSString *kItalic = @"//";
static NSString *kBig = @"??";

-(NSAttributedString*)getStyledStringFromEncryptedString {
    
    NSAttributedString *decryptedString = [self checkForKeys:[self styleKeys] inEncryptedString: self];
    
    return decryptedString;
}

-(NSAttributedString*)checkForKeys:(NSArray<NSString*>*)keys inEncryptedString:(NSString*)input {
    
    NSMutableArray<NSArray*>* rangesToStyle = [NSMutableArray array]; // Initialize array of styles to apply after searching and removing keys from input
    
    for (NSString *key in keys) {
        
        while ([input containsString:key]) { // Find and remove all duplicates of keys, recording their ranges
            
            NSRange firstRange = [input rangeOfString:key]; // Find first key
            
            if (firstRange.length == 0) {
                NSLog(@"INVALID KEY COUNT IN INPUT, ABORTING STYLING");
                return [[NSAttributedString alloc] initWithString:@"Invalid key count in input!"];
            }
            
            NSMutableArray *otherKeys = [keys mutableCopy]; // Get all other keys
            [otherKeys removeObject:key]; // By removing current one
            
            NSUInteger otherKeysFoundBefore = 0, length = firstRange.location; // Count other keys found before current key
            
            for (NSString *otherKey in otherKeys) {
                NSRange range = NSMakeRange(0, length); // Search string for all occurrences before current key
                while (range.location != NSNotFound) {
                    range = [input rangeOfString:otherKey options:0 range:range];
                    if (range.location != NSNotFound) {
                        range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                        otherKeysFoundBefore++; // Key found, continue search after current find
                    }
                }
            }
            
            input = [input stringByReplacingCharactersInRange:firstRange withString:@""]; // Remove substring with first key
            
            NSRange secondRange = [input rangeOfString:key]; // Find second key
            
            if (secondRange.length == 0) {
                NSLog(@"INVALID KEY COUNT IN INPUT, ABORTING STYLING");
                return [[NSAttributedString alloc] initWithString:@"Invalid key count in input!"];
            }
            
            input = [input stringByReplacingCharactersInRange:secondRange withString:@""]; // Remove substring with second key
            
            NSRange styleRange = NSMakeRange(firstRange.location + 2,  secondRange.location - firstRange.location); // Create style range from two key ranges
            
            NSUInteger locationWithOtherKeysSubtracted = styleRange.location - 2 - (2*otherKeysFoundBefore); // Find true location to style by ignoring other keys
            
            [rangesToStyle addObject: @[@(locationWithOtherKeysSubtracted), @(styleRange.length), key]]; // Add custom range object with key to styling array
        }
    }
    
    NSMutableAttributedString *stringBuilder = [[NSMutableAttributedString alloc]initWithString:input];
    for (NSArray *range in rangesToStyle) {
        NSUInteger location = [range[0] unsignedIntegerValue];
        NSUInteger length = [range[1] unsignedIntegerValue];
        NSString *key = [NSString stringWithFormat:@"%@",range[2]];
        [stringBuilder addAttributes: [self getStyleForKey:key] range: NSMakeRange(location, length)];
    }
    
    return stringBuilder;
}

//MARK: Styles
-(NSArray<NSString*>*)styleKeys {
    return @[kBold,kItalic,kBig];
}

-(NSDictionary*)getStyleForKey:(NSString*)key {
    
    NSDictionary *style = @{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:18.0]}; // Default
    
    if ([key isEqualToString:kBold]) style = @{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:18.0]};
    
    if ([key isEqualToString:kItalic]) style = @{NSFontAttributeName: [UIFont italicSystemFontOfSize:18.0]};
    
    if ([key isEqualToString:kBig]) style = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:30.0]};
    
    return style;
}


@end
