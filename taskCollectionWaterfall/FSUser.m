//
//  FSUser.m
//  taskCollectionWaterfall
//
//  Created by Elerman on 19.01.17.
//  Copyright © 2017 Elerman. All rights reserved.
//

#import "FSUser.h"

@implementation FSUser

-(id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super init];
    if (self) {
              
        NSString* urlString_photo = [responseObject objectForKey:@"src_big"];
        if(urlString_photo){
            self.photoUrl = [NSURL URLWithString:urlString_photo];
        }
        self.photoWidth = [responseObject objectForKey:@"width"];
        self.photoHeight = [responseObject objectForKey:@"height"];
        
        self.aspectRatio = [self.photoWidth floatValue] / [self.photoHeight floatValue];
        
    }
    return self;
}



@end
