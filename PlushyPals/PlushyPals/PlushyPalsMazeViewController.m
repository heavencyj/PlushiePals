//
//  PlushyPalsMazeViewController.m
//  PlushyPals
//
//  Created by Heaven Chen on 1/13/13.
//  Copyright (c) 2013 Heaven Chen. All rights reserved.
//

#import "PlushyPalsMazeViewController.h"

// This is defined in Math.h
#define M_PI   3.14159265358979323846264338327950288   /* pi */
// Our conversion definition
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

@interface PlushyPalsMazeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *turningImage;
@property CGFloat imageAngle;
@end

@implementation PlushyPalsMazeViewController
@synthesize swipeLeft = _swipeLeft;
@synthesize swipeRight = _swipeRight;
@synthesize turningImage = _turningImage;
@synthesize imageAngle = _imageAngle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.swipeRight addTarget:self action:@selector(turnTo:)];
  [self.swipeLeft addTarget:self action:@selector(turnTo:)];
  self.imageAngle = 0;
  //hello test 2 branch!!
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)turnTo:(UISwipeGestureRecognizer *)sender
{
  self.imageAngle = (sender.direction ==  UISwipeGestureRecognizerDirectionRight) ? self.imageAngle+90:self.imageAngle-90;
  [self rotateImage:self.turningImage duration:0.2 curve:UIViewAnimationCurveEaseIn degrees:self.imageAngle];
}

- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
              curve:(int)curve degrees:(CGFloat)degrees
{
  // Setup the animation
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationCurve:curve];
  [UIView setAnimationBeginsFromCurrentState:YES];
  
  // The transform matrix
  CGAffineTransform transform =
  CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
  image.transform = transform;
  
  // Commit the changes
  [UIView commitAnimations];
}

@end
