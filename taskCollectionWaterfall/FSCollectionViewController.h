//
//  FSCollectionViewController.h
//  taskCollectionWaterfall
//
//  Created by Elerman on 19.01.17.
//  Copyright © 2017 Elerman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"

@interface FSCollectionViewController : UICollectionViewController <CHTCollectionViewDelegateWaterfallLayout>
@property (weak, nonatomic) IBOutlet UIStepper *stepColCount;

@end
