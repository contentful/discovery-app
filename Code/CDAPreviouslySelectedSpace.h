//
//  CDAPreviouslySelectedSpace.h
//  Discovery
//
//  Created by Boris Bügling on 26/08/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Realm/Realm.h>

@interface CDAPreviouslySelectedSpace : RLMObject

@property (nonatomic) NSString* accessToken;
@property (nonatomic) NSDate* lastAccessTime;
@property (nonatomic) NSString* name;
@property (nonatomic) int numberOfEntries;
@property (nonatomic) NSString* spaceKey;

+(instancetype)spaceWithAccessToken:(NSString*)accessToken
                               name:(NSString*)name
                    numberOfEntries:(int)numberOfEntries
                           spaceKey:(NSString*)spaceKey;

@end
