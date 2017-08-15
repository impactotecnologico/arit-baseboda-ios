//
//  MainViewController.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 10/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//


#import "Constants.h"
#import "MainViewController.h"
#import "AugmentedViewController.h"
#import "ApplicationController.h"

//#import <Photos/PHAsset.h>
//#import <Photos/PHFetchResult.h>

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *buttonMenu;
@property (weak, nonatomic) IBOutlet UIButton *buttonVideo;
@property (weak, nonatomic) IBOutlet UIImageView *testImage;
@property (weak, nonatomic) IBOutlet UIView *viewProcessDialog;
@property (weak, nonatomic) IBOutlet UILabel *labelProcessMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelProcessPercent;


@property NSString *action;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAction: ACTION_MENU];
    
    [[ApplicationController Instance] getConfigOnSuccess:^(Config *config)  {
        [self didReceiveConfig:config];
    }];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[[[self navigationController] navigationBar] topItem] setTitle:@""];
}

- (void)didReceiveConfig: (Config*) config
{
    NSLog(@"didReceiveConfig");
    
    NSString *path = [config pathARResource:@"churrasco.png"];
    NSLog(path);
    UIImage *storeImage = [UIImage imageWithContentsOfFile:path];
    if (storeImage)
    {
        [[self testImage] setImage:storeImage];
    }
    
    [[ApplicationController Instance] getResourcesAndStore:^(NSString *message, float percent) {
        [self didChangeProcessStoreResourceMessage:message percentProcess:percent];
    } callback:^{
        [self didFinishedStoreResource];
    }];
    
    //PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
}

- (void)didChangeProcessStoreResourceMessage: (NSString*) message percentProcess:(float) percent
{
    [[self labelProcessMessage] setText:message];
    [[self labelProcessPercent] setText: [NSString stringWithFormat:@"%.02f", percent]];
}

-(void) didFinishedStoreResource
{
    [[self viewProcessDialog] setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onTapButton:(UIButton*)sender
{
    
    if ([sender isEqual: [self buttonVideo]])
        [self setAction: ACTION_VIDEO];
    else
        [self setAction: ACTION_MENU];
    
    [self performSegueWithIdentifier:AUGMENTED_SEGUE sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:AUGMENTED_SEGUE])
    {
        AugmentedViewController *view = (AugmentedViewController *) [segue destinationViewController];
        [view setAction: [self action]];
    }
}

@end
