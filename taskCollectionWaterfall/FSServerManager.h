//
//  FSServerManager.h
//  taskCollectionWaterfall
//
//  Created by Elerman on 19.01.17.
//  Copyright © 2017 Elerman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSServerManager : NSObject

+ (FSServerManager *)sharedManager;

- (void) getPhotosWithOffset:(NSInteger)offset
                       count:(NSInteger) count
                    onSuccess:(void(^)(NSArray* photos)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
