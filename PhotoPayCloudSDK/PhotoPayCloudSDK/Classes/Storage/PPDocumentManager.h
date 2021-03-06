//
//  PPDocumentManager.h
//  PhotoPayCloudSDK
//
//  Created by Jurica Cerovec on 9/10/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPLocalDocument;

@interface PPDocumentManager : NSObject

/**
 The callback dispatch queue on success. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, assign) dispatch_queue_t successCallbackQueue;

/**
 The callback dispatch queue on failure. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, assign) dispatch_queue_t failureCallbackQueue;

/**
 Designated initializers
 */
- (id)init;

/**
 Returns an URL for a given filename. URL points to a location in applciation documents directoru
 */
+ (NSURL*)urlForFilename:(NSString*)filename;

/**
 Performs the saving of a local document to application documents folder
 */
- (void)saveDocument:(PPLocalDocument*)localDocument atUrl:(NSURL*)documentUrl
             success:(void(^)(PPLocalDocument*localDocument))success
             failure:(void(^)(PPLocalDocument*localDocument, NSError* error))failure;

/**
 Performs the deletion of a local document. Inverse to saveDocument function, except it
 work synchronously
 
 Returns true if successful.
 */
- (BOOL)deleteDocument:(PPLocalDocument*)localDocument
                 error:(NSError**)error;

@end
