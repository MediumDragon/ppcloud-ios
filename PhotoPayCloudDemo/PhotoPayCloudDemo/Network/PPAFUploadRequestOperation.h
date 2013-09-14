//
//  PPAFUploadRequestOperation.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/11/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "AFJSONRequestOperation.h"
#import <PhotoPayCloud/PhotoPayCloud.h>

@interface PPAFUploadRequestOperation : AFJSONRequestOperation <PPUploadRequestOperation>

/**
 Delegate is also requred. Could be nil.
 */
@property (nonatomic, weak) id<PPUploadRequestOperationDelegate> delegate;

/**
 Upload progess is stored in progress property
 */
@property (nonatomic, strong) NSNumber* progress;

/**
 Designated initializer
 */
- (id)initWithRequest:(NSURLRequest *)urlRequest;

@end
