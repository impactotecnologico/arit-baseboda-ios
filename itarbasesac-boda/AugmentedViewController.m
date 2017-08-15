//
//  AugmentedViewController.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 10/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "Constants.h"
#import "AugmentedViewController.h"
#import "ApplicationController.h"
#import "ViewUtils.h"

@interface AugmentedViewController() <CraftARSDKProtocol, CraftARContentEventsProtocol, SearchProtocol, CraftARTrackingEventsProtocol>

@property CraftARSDK *sdk;
@property CraftARCloudRecognition *cloudRecognition;
@property CraftARTracking *tracking;
@property CraftARItemAR *currentItem;

@property int currentIndex;
@property unsigned long countResources;
@property TypeContent currentTypeContent;

@property Scene* currentScene;
@property CraftARTrackingContent* nextButton;
@property CraftARTrackingContent* prevButton;
@property CraftARTrackingContent* cart;

@property (weak, nonatomic) IBOutlet UIView *viewVideoPreview;
@property (weak, nonatomic) IBOutlet UIView *viewScanOverlay;

@property (weak, nonatomic) IBOutlet UIView *viewInfoDialog;
@property (weak, nonatomic) IBOutlet UILabel *labelInfoMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imageInfoReference;
@property (weak, nonatomic) IBOutlet UIView *viewInfoBackground;

@property Config* config;
@property BOOL isVisibleCard;

@end

@implementation AugmentedViewController

@synthesize sdk;
@synthesize cloudRecognition;
@synthesize tracking;
@synthesize currentItem;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setCurrentIndex:0];
    [self setIsVisibleCard:NO];
    
    [[ApplicationController Instance] getConfigOnSuccess:^(Config * config)
    {
        [self setConfig:config];
    }];
    
    [[self viewInfoBackground] setBackgroundColor:[UIColor whiteColor]];
    if ([[self action] isEqualToString: ACTION_VIDEO])
    {
        [self setCurrentTypeContent:TypeContentVideo];
        [self setCountResources: [[[self config] videosAR] count]];
        [[self labelInfoMessage] setText: TEXT_HELP_WELCOME];
        NSString *path = [[self config] pathARResource:@"bienvenida_mini.jpg"];
        [[self imageInfoReference] setImage: [[UIImage alloc] initWithContentsOfFile:path]];
        [[[[self navigationController] navigationBar] topItem] setTitle:TEXT_TITLE_WELCOME];
    }
    else
    {
        [self setCurrentTypeContent:TypeContentImage];
        [self setCountResources: [[[self config] imagesAR] count]];
        [[self labelInfoMessage] setText: TEXT_HELP_MENU_STEP_1];
        NSString *path = [[self config] pathARResource:@"minuta_mini.jpg"];
        [[self imageInfoReference] setImage: [[UIImage alloc] initWithContentsOfFile:path]];
        [[[[self navigationController] navigationBar] topItem] setTitle:TEXT_TITLE_MENU];
    }
    
    [self setSdk:[CraftARSDK sharedCraftARSDK]];
    [[self sdk] setDelegate:self];
    
    [self setCloudRecognition: [CraftARCloudRecognition sharedCloudImageRecognition]];
    [[self cloudRecognition] setDelegate: self];
    
    [self setTracking: [CraftARTracking sharedTracking]];
    [[self tracking] setDelegate:self];
}

- (void) viewWillAppear:(BOOL) animated
{
    [super viewWillAppear:animated];
    [[self sdk] startCaptureWithView:self.viewVideoPreview];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[self sdk]  stopCapture];
    [[self tracking]  removeAllARItems];
    [super viewWillDisappear:animated];
}

#pragma mark -

#pragma mark Content Management

-(void) augmentedContent
{
    NSLog(@"menuAugmented.");
    
    if ([self countResources] > 1)
    {
        NSLog(@"Adding Controls");
        NSString *prevPath = [[NSBundle mainBundle] pathForResource:@"prev" ofType:@"png"];
        [self setPrevButton: [self makeButtonWithResource:[NSURL fileURLWithPath: prevPath]
                                               withScale: CATransform3DMakeScale(0.6, 0.6, 0.6)
                                          withTransition: CATransform3DMakeTranslation(-240, -261.33, 82.68)]];
        
        NSString *nextPath = [[NSBundle mainBundle] pathForResource:@"next" ofType:@"png"];
        [self setNextButton: [self makeButtonWithResource:[NSURL fileURLWithPath: nextPath]
                                               withScale: CATransform3DMakeScale(0.6, 0.6, 0.6)
                                          withTransition: CATransform3DMakeTranslation(240, -261.33, 82.68)]];
    }
    
    [self updateCurrentScene];
    
    switch ([self currentTypeContent]) {
        case TypeContentImage:
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(),
                ^{
                    [[self labelInfoMessage] setText: TEXT_HELP_MENU_STEP_2];
                    [[ApplicationController Instance] getConfigOnSuccess:^(Config * config) {
                        [[self viewInfoBackground] setBackgroundColor: [ViewUtils colorFromHexString: [config colorRosa]]];
                    }];
                });
                break;
            }
            
        default:
            break;
    }
    
    self.viewScanOverlay.hidden = true;
}

-(void) updateCurrentScene
{
    // Si cambia el contenido se borra el cart...
    [self setCart: nil];
    
    if ([self currentScene])
    {
        [[self currentItem] removeContent:[[self currentScene] content]];
        if (([self countResources] > 1))
        {
            [[self currentItem] removeContent:[self prevButton]];
        }
    }
    
    [self setCurrentScene: [[ApplicationController Instance] getSceneAt: [self currentIndex] ofType: [self currentTypeContent]]];
    [[[self currentScene] content] setWrapMode: CRAFTAR_TRACKING_WRAP_ASPECT_FIT];
    [[[self currentScene] content] setScale:CATransform3DMakeScale(1.5, 2.2, 1.5)];
    [[self currentItem] addContent:[[self currentScene] content]];
    
    if (([self countResources] > 1))
    {
        [[self currentItem] addContent: [self prevButton]];
        [[self currentItem] addContent: [self nextButton]];
    }
}

-(CraftARTrackingContent*) makeButtonWithResource: (NSURL*) pathResource withScale: (CATransform3D) scale withTransition: (CATransform3D) transition
{
    CraftARTrackingContent* content = [[CraftARTrackingContentImage alloc] initWithImageFromURL: pathResource];
    [content setWrapMode: CRAFTAR_TRACKING_WRAP_ASPECT_FIT];
    [content setScale: scale];
    [content setTranslation: transition];
    
    return content;
}

-(void) toggleCard
{
    if ([self isVisibleCard])
    {
        [[self currentItem] removeContent: [self cart]];
        [self setIsVisibleCard: NO];
    }
    else
    {
        if ([self cart] == nil)
        {
            NSString *pathResource = [[self config] pathARResource: [NSString stringWithFormat:@"info%d.png", [self currentIndex]]];
            CraftARTrackingContent* content = [[CraftARTrackingContentImage alloc] initWithImageFromURL: [NSURL fileURLWithPath:pathResource]];
            [content setWrapMode: CRAFTAR_TRACKING_WRAP_ASPECT_FIT];
            [content setTranslation: CATransform3DMakeTranslation(0.0, 0.0, 142.63)];
            [content setScale: CATransform3DMakeScale(1.6, 1.6, 1.6)];
        }
        
        [[self currentItem] addContent:[self cart]];
        [self setIsVisibleCard: YES];
    }
}

#pragma mark Finder mode AR implementation

- (void) didStartCapture {
    
    [[self sdk] setSearchControllerDelegate:[[self cloudRecognition] mSearchController]];
    
    __block AugmentedViewController* mySelf = self;
    
    [[ApplicationController Instance] getConfigOnSuccess:^(Config * config) {
        [[[self cloudRecognition] mSearchController] setSearchPeriod: [[config delay] intValue]];
        [[self cloudRecognition] setCollectionWithToken: [config arCollection] onSuccess:^{
            
            NSLog(@"Ready to search!");
            mySelf.viewScanOverlay.hidden = false;
            [[CraftARSDK sharedCraftARSDK] startFinder];
            
        } andOnError:^(NSError *error) {
            NSLog(@"Error setting token: %@", error.localizedDescription);
        }];
    }];
}

    
- (void) didGetSearchResults:(NSArray *)results {
    
    NSLog(@"didGetSearchResults");
    if ([results count] > 0) {
        [[self sdk] stopFinder];
        
        CraftARSearchResult *result = [results objectAtIndex:0];
        CraftARItem* item = result.item;
        
        if ([item isKindOfClass:[CraftARItemAR class]])
        {
            NSLog(@"isKindOfClass CraftARItemAR");
            [self setCurrentItem: (CraftARItemAR*)item];
            if ([[item name] isEqualToString: AR_COLLECTION_TYPE_MEMORANDUM] && [[self action] isEqualToString: ACTION_MENU])
            {
                NSLog(@"AR_COLLECTION_TYPE_MEMORANDUM && ACTION_MENU");
                [self augmentedContent];
            }
            else if ([[item name] isEqualToString: AR_COLLECTION_TYPE_WELCOME] && [[self action] isEqualToString: ACTION_VIDEO])
            {
                NSLog(@"AR_COLLECTION_TYPE_WELCOME && ACTION_VIDEO");
                [self augmentedContent];
            }
            
            NSError *err = [[self tracking] addARItem: [self currentItem]];
            if (err) {
                NSLog(@"Error adding AR item: %@", err.localizedDescription);
            }
        }
    }
}

- (void) didFailSearchWithError:(NSError *)error
{
    NSLog(@"Error calling CRS: %@", [error localizedDescription]);
}

#pragma mark Receive Tracking and contents events
- (void) didStartTrackingItem:(CraftARItemAR *)item
{
    NSLog(@"Start tracking: %@", item.name);
}

- (void) didStopTrackingItem:(CraftARItemAR *)item
{
    NSLog(@"Stop tracking: %@", item.name);
}

- (void) didGetTouchEvent:(CraftARContentTouchEvent)event forContent:(CraftARTrackingContent *)content
{
    switch (event)
    {
        case CRAFTAR_CONTENT_TOUCH_IN:
            NSLog(@"Touch in: %@", content.uuid);
            break;
        case CRAFTAR_CONTENT_TOUCH_OUT:
            NSLog(@"Touch out: %@", content.uuid);
            break;
        case CRAFTAR_CONTENT_TOUCH_UP:
            NSLog(@"Touch up: %@", content.uuid);
            break;
        case CRAFTAR_CONTENT_TOUCH_DOWN:
            NSLog(@"Touch down: %@", content.uuid);
            
            if ([[[self prevButton] uuid] isEqualToString: content.uuid]) // touch prev button
            {
                if ([self currentIndex] > 0)
                {
                    [self setCurrentIndex: [self currentIndex] - 1];
                }
                else
                {
                    [self setCurrentIndex: [self countResources] - 1];
                }
                
                [self updateCurrentScene];
            }
            else if ([[[self nextButton] uuid] isEqualToString: content.uuid]) // touch next button
            {
                int lastResource = [self countResources] - 1;
                if ([self currentIndex] >= lastResource)
                {
                    [self setCurrentIndex: 0];
                }
                else
                {
                    [self setCurrentIndex: [self currentIndex] + 1];
                }
                
                [self updateCurrentScene];
            }
            else
            {
                if ([self currentTypeContent] == TypeContentImage) // other contents
                {
                    [self toggleCard];
                }
                else
                {
                    [[self currentItem] removeContent: [[self currentScene] content]];
                    //[[self navigationController] popViewControllerAnimated:YES]; // Regresar a la pantalla anterior.
                }
            }
            
            break;
        default:
            break;
    }
}


#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
