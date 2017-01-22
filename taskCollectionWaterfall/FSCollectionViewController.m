//
//  FSCollectionViewController.m
//  taskCollectionWaterfall
//
//  Created by Elerman on 19.01.17.
//  Copyright © 2017 Elerman. All rights reserved.
//

#import "FSCollectionViewController.h"
#import "FSServerManager.h"
#import "FSUser.h"
#import "UIImageView+AFNetworking.h"
#import "FSCollectionViewCell.h"




@interface FSCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *photosArray;
@property (assign,nonatomic) BOOL loadingData;
@property (assign, nonatomic) CGFloat scale;
@property (strong, nonatomic) CHTCollectionViewWaterfallLayout* waterfallLayout;

@end


@implementation FSCollectionViewController 


static CGFloat MinImageCellWidth = 60;
static CGFloat SizeW = 120.0;
static CGFloat SizeH = 120.0;

static NSInteger ColumnCountWaterfallMax = 3;
static NSInteger ColumnCountWaterfallMin = 1;

static CGFloat MinimumColumnSpacing = 5;
static CGFloat MinimumInteritemSpacing = 5;

static NSString * const reuseIdentifier = @"CollectionCell";
static NSInteger photosInRequest = 16;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.scale = 1;
    self.stepColCount.minimumValue = ColumnCountWaterfallMin;
    self.stepColCount.maximumValue = ColumnCountWaterfallMax;
    
    
    [self setupLayout];
    UIPinchGestureRecognizer * pinchRecogniser = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
    
    [self.collectionView addGestureRecognizer:pinchRecogniser];
    
    self.photosArray = [NSMutableArray array];
    self.loadingData = YES;
    [self getImagesFromServer];
    
}

-(void) setupLayout{
    self.waterfallLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    self.waterfallLayout.minimumColumnSpacing = MinimumColumnSpacing;
    self.waterfallLayout.minimumInteritemSpacing = MinimumInteritemSpacing;
    
    
    [self.collectionView setCollectionViewLayout:self.waterfallLayout animated:YES];
}


-(void) zoom:(UIPinchGestureRecognizer*) gesture{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        NSLog(@"zoom ------:");
        self.scale *= gesture.scale;
        
        gesture.scale = 1.0;
    
    }
}

-(void) setScale:(CGFloat)scale{
    _scale = scale;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void) getImagesFromServer{

    [[FSServerManager sharedManager]
     getPhotosWithOffset:[self.photosArray count]
     count:photosInRequest
     onSuccess:^(NSArray *photos) {
         [self.photosArray addObjectsFromArray:photos];
         
         NSMutableArray *newPaths = [NSMutableArray array];
         NSLog(@"photos count  = %ld  self photos array count = %ld photosInRequest = %ld", [photos count], [self.photosArray count], photosInRequest);
         for(int i = (int)[self.photosArray count] - (int)[photos count]; i < [self.photosArray count]; i++){
             [newPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
         }
         if([photos count] > 0){
             [self.collectionView insertItemsAtIndexPaths:newPaths];
             self.loadingData = NO;
         }

     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         //NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
     }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [self.photosArray count];
    
}



-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FSUser* user = [self.photosArray objectAtIndex:indexPath.row ];
    
    NSInteger newColumnNumber = round(self.waterfallLayout.columnCount / self.scale) ;
    
    if(newColumnNumber>=ColumnCountWaterfallMin && newColumnNumber<=ColumnCountWaterfallMax){
        NSLog(@"scale = %f", self.scale);
        if(newColumnNumber == self.waterfallLayout.columnCount +1){
            self.scale = 1;
        }
        NSLog(@"newColumnNumber = %ld", newColumnNumber);
        self.waterfallLayout.columnCount =fmin (fmax (newColumnNumber, ColumnCountWaterfallMin), ColumnCountWaterfallMax);
        
        //self.waterfallLayout.columnCount = newColumnNumber < 1 ? 1 :newColumnNumber;
        [self.stepColCount setValue:newColumnNumber];
        
    }
    
    CGFloat ratio = user.aspectRatio;
    //NSLog(@"ratio = %f", ratio);
    CGFloat maxCellWidth = collectionView.bounds.size.width - MinimumInteritemSpacing * 2.0 -
    self.waterfallLayout.sectionInset.right * 2.0;
   
    CGSize sizeSetting = CGSizeMake(SizeW, SizeH);
    
    
    CGSize size = CGSizeMake(sizeSetting.width * self.scale, sizeSetting.height * self.scale);
    if( ratio > 1.0){
        size.height /= ratio;
    } else{
        size.width *= ratio;
    }
    if (size.width > maxCellWidth){
        size.width = maxCellWidth;
        size.height = size.width / ratio;
    }
    CGFloat cellWidth = fmin(fmax(size.width, MinImageCellWidth), maxCellWidth);
    
    return CGSizeMake(cellWidth, cellWidth/ratio);

}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(!cell){
        cell = [[FSCollectionViewCell alloc] init];
    }
    
    cell.cellImage.image = nil;
    
    FSUser* photo = [self.photosArray objectAtIndex:indexPath.row];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:photo.photoUrl];
    
    __weak FSCollectionViewCell *weakCell = cell;
    
    
    [cell.cellImage
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse *  response, UIImage *  image) {
         //weakCell.cellImage.image = image;
         [UIView transitionWithView:weakCell.cellImage
                           duration:0.3f
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             weakCell.cellImage.image = image;
                         } completion:NULL];
         //[weakCell layoutSubviews];

     }failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
         
     }];
        
    

    return cell;
}


#pragma mark - optional TASKS!!!111 :)
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getImagesFromServer];
        }
    }
}
- (IBAction)changeColCount:(UIStepper*)sender {
    NSLog(@"sender.value = %f",sender.value);
    NSInteger colCount = sender.value;
    self.waterfallLayout.columnCount = colCount;
    self.scale = 1;
    
}







@end
