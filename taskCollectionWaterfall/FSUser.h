//
//  FSUser.h
//  taskCollectionWaterfall
//
//  Created by Elerman on 19.01.17.
//  Copyright © 2017 Elerman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface FSUser : NSObject

@property (strong, nonatomic) NSURL* photoUrl;
@property (assign, nonatomic) CGFloat aspectRatio;
@property (assign, nonatomic) NSString *photoWidth;
@property (assign, nonatomic) NSString *photoHeight;
-(id) initWithServerResponse:(NSDictionary*) responseObject;

@end
