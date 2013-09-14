//
//  PPTableSection.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPTableSection.h"

static const int INITIAL_CAPACITY = 20;

@interface PPTableSection ()

@property (nonatomic, strong) NSMutableArray* mutableItems;

@end

@implementation PPTableSection

@synthesize sectionId;
@synthesize name;
@synthesize mutableItems;

- (id)initWithSectionId:(NSInteger)inSectionId name:(NSString*)inName {
    self = [super init];
    if (self) {
        sectionId = inSectionId;
        name = inName;
        mutableItems = [[NSMutableArray alloc] initWithCapacity:INITIAL_CAPACITY];
    }
    return self;
}

- (void)addItem:(id)item {
    [[self mutableItems] addObject:item];
}

- (NSArray *)items {
    return [[self mutableItems] copy];
}

- (NSInteger)itemCount {
    return [[self mutableItems] count];
}

@end