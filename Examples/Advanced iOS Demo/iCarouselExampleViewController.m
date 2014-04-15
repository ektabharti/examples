//
//  iCarouselExampleViewController.m
//  iCarouselExample
//
//  Created by Nick Lockwood on 03/04/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "iCarouselExampleViewController.h"


@interface iCarouselExampleViewController () <UIActionSheetDelegate>
{
    UIView *selectedView;
}
@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic,strong) NSMutableArray *arrayOfViews;

@end


@implementation iCarouselExampleViewController

@synthesize carousel;
@synthesize navItem;
@synthesize orientationBarItem;
@synthesize wrapBarItem;
@synthesize wrap;
@synthesize items;

- (void)setUp
{
    //set up data
    wrap = YES;
    self.items = [NSMutableArray array];
    for (int i = 0; i < 1000; i++)
    {
        [items addObject:@(i)];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)dealloc
{
    //it's a good idea to set these to nil here to avoid
    //sending messages to a deallocated viewcontroller
    carousel.delegate = nil;
    carousel.dataSource = nil;
    
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.arrayOfViews= [[NSMutableArray alloc]init];
    
    //configure carousel
    carousel.type = iCarouselTypeCoverFlow2;
    navItem.title = @"CoverFlow2";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.carousel = nil;
    self.navItem = nil;
    self.orientationBarItem = nil;
    self.wrapBarItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)switchCarouselType
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select Carousel Type"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Linear", @"Rotary", @"Inverted Rotary", @"Cylinder", @"Inverted Cylinder", @"Wheel", @"Inverted Wheel", @"CoverFlow", @"CoverFlow2", @"Time Machine", @"Inverted Time Machine", @"Custom", nil];
    [sheet showInView:self.view];
}

- (IBAction)toggleOrientation
{
    //carousel orientation can be animated
    [UIView beginAnimations:nil context:nil];
    carousel.vertical = !carousel.vertical;
    [UIView commitAnimations];
    
    //update button
    orientationBarItem.title = carousel.vertical? @"Vertical": @"Horizontal";
}

- (IBAction)toggleWrap
{
    wrap = !wrap;
    wrapBarItem.title = wrap? @"Wrap: ON": @"Wrap: OFF";
    [carousel reloadData];
}

- (IBAction)insertItem
{
    NSInteger index = MAX(0, carousel.currentItemIndex);
    [items insertObject:@(carousel.numberOfItems) atIndex:index];
    [carousel insertItemAtIndex:index animated:YES];
}

- (IBAction)removeItem
{
    if (carousel.numberOfItems > 0)
    {
        NSInteger index = carousel.currentItemIndex;
        [items removeObjectAtIndex:index];
        [carousel removeItemAtIndex:index animated:YES];
    }
}

#pragma mark -
#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= 0)
    {
        //map button index to carousel type
        iCarouselType type = buttonIndex;
        
        //carousel can smoothly animate between types
        [UIView beginAnimations:nil context:nil];
        carousel.type = type;
        [UIView commitAnimations];
        
        //update title
        navItem.title = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        view.contentMode = UIViewContentModeCenter;
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [label.font fontWithSize:50];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = [items[index] stringValue];
    
    [self.arrayOfViews addObject:view];
    return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        view.contentMode = UIViewContentModeCenter;
        
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [label.font fontWithSize:50.0f];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = (index == 0)? @"[": @"]";
    view.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:view action:@selector(handlePanGesture:)];
    [view addGestureRecognizer:panGesture];
    return view;
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}

-(void)handlePanGesture:(UIPanGestureRecognizer *)recognizer{
//    CGPoint translate = [recognizer translationInView:self.view];
    if(recognizer.state == UIGestureRecognizerStateBegan){
        
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor),
                                         recognizer.view.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.center = finalPoint;
        } completion:nil];
        
    }
    return;
}

//+(void)takeScreenshotAndUpdateBackgroundImage:(UIView*)view{
//    
//    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 1.0);
//    //[view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    [view drawViewHierarchyInRect:CGRectMake(0, 0, 1024, 768) afterScreenUpdates:NO];
//    UIImage *imageView = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    NSData *imageData;
//    UIImage *image;
//    imageData = UIImageJPEGRepresentation(imageView, 1.0 );
//    image = [UIImage imageWithData:imageData];
//    
//    UIImage *effectImage = nil;
//    
//    effectImage = [image blurredImageWithRadius:10 iterations:3 tintColor:nil];
//    
//    if(!viewForBackground)
//        viewForBackground = [[UIImageView alloc] initWithFrame:CGRectMake(-10, -10, 1024+20, 768+20)];
//    
//    viewForBackground.image = effectImage;
//    [view addSubview:viewForBackground];
//    
//    CGFloat effect = 30.0f;
//    
//    // Set vertical effect
//    UIInterpolatingMotionEffect *verticalMotionEffect =
//    [[UIInterpolatingMotionEffect alloc]
//     initWithKeyPath:@"center.y"
//     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
//    verticalMotionEffect.minimumRelativeValue = @(-effect);
//    verticalMotionEffect.maximumRelativeValue = @(effect);
//    
//    // Set horizontal effect
//    UIInterpolatingMotionEffect *horizontalMotionEffect =
//    [[UIInterpolatingMotionEffect alloc]
//     initWithKeyPath:@"center.x"
//     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
//    horizontalMotionEffect.minimumRelativeValue = @(-effect);
//    horizontalMotionEffect.maximumRelativeValue = @(effect);
//    
//    // Create group to combine both
//    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
//    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
//    
//    // Add both effects to your view
//    [view addMotionEffect:group];
//}


#pragma mark -
#pragma mark iCarousel taps

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSNumber *item = (self.items)[index];
    NSLog(@"Tapped view number: %@", item);
    selectedView = [self.arrayOfViews objectAtIndex:index];
}

@end
