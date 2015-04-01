//
//  DTCSandboxURL.m
//  HackerBooks
//
//  Created by David de Tena on 01/04/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import "DTCSandboxURL.h"

@implementation DTCSandboxURL

#pragma mark - Class methods
/*
+ (instancetype) sandboxURLWithString: (NSString *) URLString{
    return [[self alloc] initWithString:URLString];
}

+ (instancetype) sandboxURLWithFilename: (NSString *) aFilename{
    return [[self alloc] initWithFilename:aFilename];
}
 */

+ (NSURL *) urlToDocumentsFolder: (NSString *) aFilename{
    NSURL *url = [self URLToFolder:@"docs"];
    url = [url URLByAppendingPathComponent:aFilename];
    return url;
}

+ (NSURL *) urlToCacheFolder: (NSString *) aFilename{
    NSURL *url = [self URLToFolder:@"cache"];
    url = [url URLByAppendingPathComponent:aFilename];
    return url;
}

+ (NSURL *) URLToFolder: (NSString *) aFolder{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = nil;
    if ([aFolder isEqualToString:@"cache"]) {
        url = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    }
    else{
        // URL to /Documents by defaults
        url = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    }
    return url;
}

/*
#pragma mark - Init
- (id) initWithString: (NSString *) aString{
    if (self = [super initWithString:aString]) {
        NSURL *url = [NSURL URLWithString:aString];
        NSString *fileName = [url lastPathComponent];
        _filename = fileName;
    }
    return self;
}

- (id) initWithFilename: (NSString *) aFilename{
    if (self = [super init]) {
        _filename = aFilename;
    }
    return self;
}
*/


@end
