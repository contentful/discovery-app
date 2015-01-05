//
//  CDAPreviouslySelectedSpace.m
//  Discovery
//
//  Created by Boris Bügling on 26/08/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "CDAPreviouslySelectedSpace.h"

@implementation CDAPreviouslySelectedSpace

+(instancetype)spaceForKey:(NSString*)spaceKey {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"spaceKey = %@", spaceKey];
    RLMResults *spaces = [CDAPreviouslySelectedSpace objectsWithPredicate:pred];
    return spaces.count > 0 ? spaces[0] : nil;
}

+(instancetype)spaceWithAccessToken:(NSString*)accessToken
                               name:(NSString*)name
                    numberOfEntries:(int)numberOfEntries
                           spaceKey:(NSString*)spaceKey {
    RLMRealm *realm = [RLMRealm defaultRealm];

    CDAPreviouslySelectedSpace* space = [self spaceForKey:spaceKey];
    
    if (space) {
        [realm beginWriteTransaction];
        space.lastAccessTime = [NSDate new];
        [realm commitWriteTransaction];
        return space;
    }

    space = [CDAPreviouslySelectedSpace new];
    space.accessToken = accessToken;
    space.lastAccessTime = [NSDate new];
    space.name = name;
    space.numberOfEntries = numberOfEntries;
    space.spaceKey = spaceKey;

    [realm beginWriteTransaction];
    [realm addObject:space];
    [realm commitWriteTransaction];

    return space;
}

@end
