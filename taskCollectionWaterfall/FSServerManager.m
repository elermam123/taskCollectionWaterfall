//
//  FSServerManager.m
//  taskCollectionWaterfall
//
//  Created by Elerman on 19.01.17.
//  Copyright © 2017 Elerman. All rights reserved.
//

#import "FSServerManager.h"

#import "AFNetworking.h"
#import "FSUser.h"

@interface FSServerManager ()

@property (strong,nonatomic) AFHTTPSessionManager *requestOperationManager;

@end

@implementation FSServerManager

+ (FSServerManager *)sharedManager {
    
    static FSServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[FSServerManager alloc]init];
        
    });
    
    return manager;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self = [super init];
        if(self){
            
            NSURL* url = [NSURL URLWithString:@"https://api.vk.com/method/"];
            
            self.requestOperationManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        }
        
        return self;        
    }
    return self;
}

- (void) getPhotosWithOffset:(NSInteger) offset
                       count:(NSInteger) count
                    onSuccess:(void(^)(NSArray* photos)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"5787951",    @"user_id",
     @(count),      @"count",
     @(offset),     @"offset",
     @"240745377",  @"album_id", nil];
    
    
    [self.requestOperationManager
     GET:@"photos.get"
     parameters:params
     progress:nil
     success:^(NSURLSessionTask *task, id responseObject) {
         //NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         for(NSDictionary* dict in dictsArray){
             FSUser* user = [[FSUser alloc] initWithServerResponse:dict];
             [objectsArray addObject:user];
         }
         
         
         if(success){
             success(objectsArray);
         }
         
         
     } failure:^(NSURLSessionTask *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if(failure){
             //failure(error, operation.);
         }
         
     }];
    
    
    
}



@end
