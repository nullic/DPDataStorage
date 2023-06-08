//
//  NSString+Extensions.m
//  DPDataStorage
//
//  Created by Yauheni Fiadotau on 8.06.23.
//  Copyright © 2023 dmitriy.petrusevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Extensions.h"

@implementation NSString (DateParsing)

- (NSDate *)parseDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0] ];
    [dateFormatter setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US_POSIX"]];
    NSDate *date = nil;
    
    // Define the date styles to try
    NSArray *dateStyles = @[
        @"yyyy-MM-dd'T'HH:mm:ss.SSSS",
        @"yyyy-MM-dd'T'HH:mm:ss",
        @"yyyy-MM-dd'T'HH:mm:ssZZZZZ",
        @"yyyy-MM-dd",
        @"yyyy-MM-dd'T'HH:mm:ss.SSSXXXX",
        @"MM/dd/yyyy HH:mm:ss"
    ];
    
    for (NSString *dateStyle in dateStyles) {
        [dateFormatter setDateFormat:dateStyle];
        date = [dateFormatter dateFromString:self];
        
        if (date) {
            break;
        }
    }
    
    return date;
}

@end
