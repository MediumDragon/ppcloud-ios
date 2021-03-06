//
//  PPDocumentsDataSource.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPDocumentsDataSource.h"
#import "PPDocumentTableViewCell.h"
#import "PPDocumentTableViewCell+Local.h"
#import "PPDocumentTableViewCell+Uploading.h"
#import "PPDocumentTableViewCell+Processing.h"
#import "PPDocumentTableViewCell+Processed.h"

@interface PPDocumentsDataSource ()

+ (PPDocumentTableViewCell *)cellForDocumentStateLocal:(PPLocalDocument*)document
                                             tableView:(UITableView*)tableView;

+ (PPDocumentTableViewCell *)cellForDocumentStateUploading:(PPLocalDocument*)documentUploading
                                             tableView:(UITableView*)tableView;

+ (PPDocumentTableViewCell *)cellForDocumentStateProcessing:(PPRemoteDocument*)document
                                                  tableView:(UITableView*)tableView;

@end

@implementation PPDocumentsDataSource

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Obtain document object for given index path
    PPDocument *document = [self itemForIndexPath:indexPath];
    
    PPDocumentTableViewCell *cell = nil;
    
    switch ([document state]) {
        case PPDocumentStateCreated:
        case PPDocumentStateStored: {
            DDLogVerbose(@"Document at %d %d is waiting for upload %@", (int)[indexPath section], (int)[indexPath row], [PPDocument objectForDocumentState:[document state]]);
            cell = [PPDocumentsDataSource cellForDocumentStateLocal:[document localDocument]
                                                          tableView:tableView];
            cell.mediumLabel.text = _(@"PhotoPayHomeDocumentWaitingForUploadLabel");
            break;
        }
        case PPDocumentStateUploading: {
            DDLogVerbose(@"Document at %d %d is uploading %@", (int)[indexPath section], (int)[indexPath row], [PPDocument objectForDocumentState:[document state]]);
            cell = [PPDocumentsDataSource cellForDocumentStateUploading:[document localDocument]
                                                              tableView:tableView];
            break;
        }
        case PPDocumentStateUploadFailed: {
            DDLogVerbose(@"Document at %d %d failed to upload %@", (int)[indexPath section], (int)[indexPath row], [PPDocument objectForDocumentState:[document state]]);
            cell = [PPDocumentsDataSource cellForDocumentStateLocal:[document localDocument]
                                                          tableView:tableView];
            cell.mediumLabel.text = _(@"PhotoPayHomeDocumentUploadFailedLabel");
            break;
        }
        case PPDocumentStatePaid:
        case PPDocumentStateProcessed: {
            DDLogVerbose(@"Document at %d %d processed or paid %@", (int)[indexPath section], (int)[indexPath row], [PPDocument objectForDocumentState:[document state]]);
            cell = [PPDocumentsDataSource cellForDocumentStateProcessed:[document remoteDocument]
                                                              tableView:tableView];
            break;
        }
        default: {
            DDLogVerbose(@"Document at %d %d default %@", (int)[indexPath section], (int)[indexPath row], [PPDocument objectForDocumentState:[document state]]);
            cell = [PPDocumentsDataSource cellForDocumentStateProcessing:[document remoteDocument]
                                                               tableView:tableView];
            break;
        }
    }
    
    return cell;
}

+ (PPDocumentTableViewCell *)cellForDocumentStateLocal:(PPLocalDocument*)document
                                           tableView:(UITableView*)tableView {
   
    PPDocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PPDocumentTableViewCell defaultXibName]];
    if (cell == nil) {
        cell = [PPDocumentTableViewCell allocWithNibName:[PPDocumentTableViewCell defaultXibName]];
    }
    [cell refreshWithLocalDocument:document];
    
    return cell;
}


+ (PPDocumentTableViewCell *)cellForDocumentStateUploading:(PPLocalDocument*)documentUploading
                                                 tableView:(UITableView*)tableView {
    PPDocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PPDocumentTableViewCell defaultXibName]];
    if (cell == nil) {
        cell = [PPDocumentTableViewCell allocWithNibName:[PPDocumentTableViewCell defaultXibName]];
    }
    
    [cell refreshWithUploadingDocument:documentUploading];
    
    return cell;
}

+ (PPDocumentTableViewCell *)cellForDocumentStateProcessing:(PPRemoteDocument*)document
                                                  tableView:(UITableView*)tableView {
    PPDocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PPDocumentTableViewCell defaultXibName]];
    if (cell == nil) {
        cell = [PPDocumentTableViewCell allocWithNibName:[PPDocumentTableViewCell defaultXibName]];
    }
    
    [cell refreshWithDocumentInProcessing:document];
    
    return cell;
}

+ (PPDocumentTableViewCell *)cellForDocumentStateProcessed:(PPRemoteDocument*)document
                                                 tableView:(UITableView*)tableView {
    PPDocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PPDocumentTableViewCell defaultXibName]];
    if (cell == nil) {
        cell = [PPDocumentTableViewCell allocWithNibName:[PPDocumentTableViewCell defaultXibName]];
    }
    
    [cell refreshWithProcessedDocument:document];
    
    return cell;
}

// Editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Moving/reordering
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
