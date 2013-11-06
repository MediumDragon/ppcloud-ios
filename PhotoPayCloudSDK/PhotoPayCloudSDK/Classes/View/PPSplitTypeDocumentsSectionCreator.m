//
//  PPSplitTypeDocumentsSectionCreator.m
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 05/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPSplitTypeDocumentsSectionCreator.h"
#import "PPTableSection.h"
#import "PPDocument.h"
#import "PPLocalDocument.h"
#import "PPRemoteDocument.h"
#import <UIKit/UIKit.h>

@interface PPSplitTypeDocumentsSectionCreator ()

@property (nonatomic, strong) NSMutableArray* sections;

@end

@implementation PPSplitTypeDocumentsSectionCreator

@synthesize sections;

- (id)init {
    self = [super init];
    if (self) {
        sections = [[NSMutableArray alloc] init];
        
        PPTableSection *section = [[PPTableSection alloc] initWithSectionId:0 name:@"My invoices"];
        
        [sections addObject:section];
    }
    return self;
}

- (NSIndexPath*)insertLocalDocument:(PPLocalDocument*)localDocument {
    if ([sections count] == 1) {
        PPTableSection *section = [[PPTableSection alloc] initWithSectionId:0 name:@"Uploading"];
        [sections insertObject:section atIndex:0];
    }
    
    NSUInteger sectionIndex = 0;
    
    PPTableSection *section = [[self sections] objectAtIndex:sectionIndex];
    
    int i = 0;
    for (; i < [section itemCount]; i++) {
        
        NSObject *obj = [[section items] objectAtIndex:i];
        PPLocalDocument *document = (PPLocalDocument *)obj; // safe, because we add only local documents
        
        if ([[document creationDate] compare:[localDocument creationDate]] == NSOrderedDescending) {
            break;
        }
    }
    
    [section addItem:localDocument atIndex:i];
    
    return [NSIndexPath indexPathForRow:i inSection:sectionIndex];
}

- (NSIndexPath*)insertRemoteDocument:(PPRemoteDocument*)remoteDocument {
    NSUInteger sectionIndex = [sections count] - 1;
    
    PPTableSection *section = [[self sections] objectAtIndex:sectionIndex];
    
    int i = 0;
    for (; i < [section itemCount]; i++) {
        
        NSObject *obj = [[section items] objectAtIndex:i];
        PPRemoteDocument *document = (PPRemoteDocument *)obj; // safe, because we add only remote documents

        if ([[document creationDate] compare:[remoteDocument creationDate]] == NSOrderedAscending) {
            break;
        }
    }
    
    [section addItem:remoteDocument atIndex:i];
    
    return [NSIndexPath indexPathForRow:i inSection:sectionIndex];
}

- (NSIndexPath*)insertItem:(id)item {
    
    PPDocument *insertingDocument = nil;
    if ([item isKindOfClass:[PPDocument class]]) {
        insertingDocument = (PPDocument *)item;
    } else {
        return nil;
    }
    
    PPLocalDocument* localDocument = [insertingDocument localDocument];
    PPRemoteDocument* remoteDocument = [insertingDocument remoteDocument];
    
    if (localDocument != nil) {
        return [self insertLocalDocument:localDocument];
    } else if (remoteDocument != nil) {
        return [self insertRemoteDocument:remoteDocument];
    } else {
        return nil;
    }
}

- (NSIndexPath*)removeLocalDocument:(PPLocalDocument*)localDocument {
    // local document is in section with index 0
    NSUInteger sectionIndex = 0;
    
    PPTableSection *section = [[self sections] objectAtIndex:sectionIndex];
    
    NSUInteger row = [section removeItem:localDocument];
    
    if ([section itemCount] == 0) {
         [sections removeObjectAtIndex:sectionIndex];
    }
    
    if (row != NSNotFound) {
        return [NSIndexPath indexPathForRow:row inSection:sectionIndex];
    }
    
    return nil;
}

- (NSIndexPath*)removeRemoteDocument:(PPRemoteDocument*)remoteDocument {
    // local document is in section with index [sections count] - 1
    NSUInteger sectionIndex = [sections count] - 1;
    
    PPTableSection *section = [[self sections] objectAtIndex:sectionIndex];
    
    NSUInteger row = [section removeItem:remoteDocument];
    
    if (row != NSNotFound) {
        return [NSIndexPath indexPathForRow:row inSection:sectionIndex];
    }
    
    return nil;
}

- (NSIndexPath*)removeItem:(id)item {
    PPDocument *document = nil;
    if ([item isKindOfClass:[PPDocument class]]) {
        document = (PPDocument *)item;
    } else {
        return nil;
    }
    
    PPLocalDocument* localDocument = [document localDocument];
    PPRemoteDocument* remoteDocument = [document remoteDocument];
    
    if (localDocument != nil) {
        return [self removeLocalDocument:localDocument];
    } else if (remoteDocument != nil) {
        return [self removeRemoteDocument:remoteDocument];
    } else {
        return nil;
    }
}

- (NSIndexPath*)reloadItem:(id)item withItem:(id)other {
    if (![item isEqual:other]) {
        return nil;
    }
    for (int i = 0; i < [[self sections] count]; i++) {
        PPTableSection *section = [[self sections] objectAtIndex:i];
        
        NSUInteger row = [section reloadItem:item withItem:other];
        
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:i];
        }
    }
    return nil;
}

@end
