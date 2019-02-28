/*
  Simple DirectMedia Layer
  Copyright (C) 1997-2014 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/
#include "../../SDL_internal.h"

#if SDL_VIDEO_DRIVER_UIKIT

#include "SDL_video.h"
#include "SDL_assert.h"
#include "SDL_hints.h"
#include "../SDL_sysvideo.h"
#include "../../events/SDL_events_c.h"

#include "SDL_uikitviewcontroller.h"
#include "SDL_uikitvideo.h"
#include "SDL_uikitmodes.h"
#include "SDL_uikitwindow.h"

#include "libintl.h"

#import <AVFoundation/AVFoundation.h>

#import "MBProgressHUD.h"
#import "DQAlertView.h"

#import "RMStore.h"

#import "SDVersion.h"

#import "SCLAlertView.h"


NSString *const kInAppPurchseIdentifierBasicSoundPack = @"com.dancing_bottle.Cataclysm_Dark_Days_Ahead.BasicSoundPack";
NSString *const kInAppPurchseIdentifierAwesomeSoundPack = @"com.dancing_bottle.Cataclysm_Dark_Days_Ahead.AwesomeSoundPack";




int count = 0;
enum
{
    MENU_KEYBOARD = 10001,
    MENU_INFO,
    MENU_ACTION,
    MENU_ATTACK,
    MENU_INVENTORY,
    MENU_ADV_INVENTORY,
    MENU_BUILD,
    MENU_SPECIAL
};

enum
{
    IAP_NONE = 20001,
    IAP_BUY,
    IAP_RESTORE,
};

@implementation SDL_uikitviewcontroller
{
    NSDictionary* infoActionsCharTable;
    NSDictionary* environActionsCharTable;
    CNPGridMenu* actionsMenu;
    CNPGridMenu* settingsMenu;

    JSDPad *dPad;
    JSButton* yesButton;
    JSButton* noButton;
    JSButton* nextButton;
    JSButton* prevButton;
    JSButton* tabButton;
    JSButton* optionsButton;
    
    NSTimer* dpadTimer;
    
    NSMutableDictionary* actionDesc;
    NSMutableArray* userKeyBindings;
    
    MHWDirectoryWatcher* optionsFileWatcher;
    
    NSDate* keybindingsLastModificationDate;
    NSString* documentPath;
    NSString* userKeyBindingsPath;
    
    NSArray* allMenuItems;
    
    AVAudioPlayer *myAudioPlayer;
    AVAudioPlayer* soundPlayer;
    AVAudioPlayer* zombieSoundPlayer;
    
    MYBlurIntroductionView *introductionView;
    
    UILongPressGestureRecognizer * longPressGesture;
    UIPanGestureRecognizer* panGesture;
    
    BOOL showIntroduction;
    
    

    SKProduct *selectedProduct;
    NSArray *allProducts;
    
    MBProgressHUD *hud;
    
    int iapAction;
    
    NSTimer* keyboardDetectionTimer;
    UITextField *detectionTextField;
    UITextField *aTextField;
    BOOL detectionFlag;
    BOOL keyboardConnected;
    NSMutableArray *_commands;
    NSDictionary *_keyCommandsTranslator;
    
    BOOL isModifyingUI;
    NSTimer* uiBlickTimer;
    
    
    float dPadScale;
    float dPadPosX;
    float dPadPosY;
    
    
    SCLAlertView *alertView;
    
    
    BOOL isRecording;
    
}

@synthesize window;

- (id)initWithSDLWindow:(SDL_Window *)_window
{
    self = [self init];
    if (self == nil) {
        return nil;
    }
    self.window = _window;
  /*
    infoActionsCharTable = @{ ACTION_INFO_PLAYER: @"@",
                              ACTION_INFO_MAP: @"m",
                              ACTION_INFO_MISSIONS: @"M",
                              ACTION_INFO_FACTIONS: @"#",
                              ACTION_INFO_KILLCOUNT: @")",
                              ACTION_INFO_MORALE: @"v",
                              ACTION_INFO_MESSAGELOG: @"P",
                              ACTION_INFO_HELP: @"?",
                                 };
    
    environActionsCharTable = @{ ACTION_ENVIRONMENT_OPEN: @"o",
                         ACTION_ENVIRONMENT_CLOSE: @"c",
                         ACTION_ENVIRONMENT_SMASH: @"s",
                         ACTION_ENVIRONMENT_EXAMINE: @"e",
                         ACTION_ENVIRONMENT_PICK: @"g",
                         ACTION_ENVIRONMENT_GRAB: @"G",
                         ACTION_ENVIRONMENT_BUTCHER: @"B",
                         ACTION_ENVIRONMENT_CHAT: @"C",
                         ACTION_ENVIRONMENT_LOOK: @"x",
                         ACTION_ENVIRONMENT_PEEK: @"X",
                         ACTION_ENVIRONMENT_LIST: @"V",
                         };
    */
    
    if( 1 == count )
    {
            //track = [OALAudioTrack track];
            //[track preloadFile:@"CBRadioMessageHelp_ZA01.146.wav"];
            //[track setNumberOfLoops:-1];
            //[track play];
        //[[OALSimpleAudio sharedInstance] playBg:@"CBRadioMessageHelp_ZA01.146.wav" loop:-1];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:@"DTA_Eminor_Spheres.mp3" ];
        myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        myAudioPlayer.numberOfLoops = -1; //infinite loop
        
        fileURL = [[NSURL alloc] initFileURLWithPath:@"StabStringsCinematic_ZA02.520.mp3" ];
        soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        soundPlayer.numberOfLoops = 0;
        
        [myAudioPlayer play];
        
        showIntroduction = YES;
        
        //banker = [ASBanker sharedInstance];
        iapAction = IAP_NONE;
        
        
        /*[[MKStoreKit sharedKit] startProductRequest];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                          object:nil
                                                           queue:[[NSOperationQueue alloc] init]
                                                      usingBlock:^(NSNotification *note) {
                                                          
                                                          NSLog(@"Products available: %@", [[MKStoreKit sharedKit] availableProducts]);
                                                      }];
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                          object:nil
                                                           queue:[[NSOperationQueue alloc] init]
                                                      usingBlock:^(NSNotification *note) {
                                                          
                                                          hud.labelText = @"Thanks for your support.";
                                                          [hud hide:YES afterDelay:3];
                                                          NSLog(@"Purchased/Subscribed to product with id: %@", [note object]);
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoredPurchasesNotification
                                                          object:nil
                                                           queue:[[NSOperationQueue alloc] init]
                                                      usingBlock:^(NSNotification *note) {
                                                          hud.labelText = @"Purchase restored successfully.";
                                                          [hud hide:YES afterDelay:3];
                                                          NSLog(@"Restored Purchases");
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoringPurchasesFailedNotification
                                                          object:nil
                                                           queue:[[NSOperationQueue alloc] init]
                                                      usingBlock:^(NSNotification *note) {
                                                          hud.labelText = [NSString stringWithFormat:@"Failed to restore purchase: %@", [note object] ];
                                                          [hud hide:YES afterDelay:3];
                                                          NSLog(@"Failed restoring purchases with error: %@", [note object]);
                                                      }];*/
        
        
        [[RMStore defaultStore] addStoreObserver:self];
    }
    
    count++;

    
    return self;
}

- (void)loadView
{
    /* do nothing. */
}



-(NSArray*)createMenuItems:(NSArray*)items
{
    NSMutableArray* menuItems = [NSMutableArray array];
    for (NSDictionary* item in items )
    {
        CNPGridMenuItem *menuItem = [[CNPGridMenuItem alloc] init];
        //menuItem.icon = [UIImage imageNamed:item[@"Icon"]];
        //menuItem.icon = [self imageFromText:item[@"Command"] width:40 height:40];
        menuItem.icon = [self imageWithText:item[@"Command"] fontSize:32 rectSize:CGSizeMake(40, 40)];
        menuItem.title = item[@"Title"];
        menuItem.selectionHandler = ^(CNPGridMenuItem* menuItem){
            SDL_SendKeyboardText( [item[@"Command"] cStringUsingEncoding:NSASCIIStringEncoding] );
            [actionsMenu dismissGridMenuAnimated:YES completion:nil];
            [panGesture setEnabled:YES];
        };
        [menuItems addObject:menuItem];
    }
    
#if 0
    // append setting menu item
    CNPGridMenuItem *menuItem = [[CNPGridMenuItem alloc] init];
    menuItem.icon = [self imageWithText:@"👼" fontSize:32 rectSize:CGSizeMake(40, 40)];
    menuItem.title = @"Settings";
    menuItem.selectionHandler = ^(CNPGridMenuItem* menuItem){
        NSLog(@"Setting Pressed");
        [actionsMenu dismissGridMenuAnimated:NO completion:nil];
        [self performSelectorOnMainThread:@selector(showSettingsMenu) withObject:nil waitUntilDone:NO];
    };
    [menuItems addObject:menuItem];
#endif
#if 0
    CNPGridMenuItem *menuItem = [[CNPGridMenuItem alloc] init];
    menuItem.icon = [self imageWithText:@"🎵" fontSize:32 rectSize:CGSizeMake(40, 40)];
    menuItem.title = @"Sounds";
    menuItem.selectionHandler = ^(CNPGridMenuItem* menuItem){
        NSLog(@"Basic Sound Pack Pressed");
        [actionsMenu dismissGridMenuAnimated:NO completion:nil];
        //[self performSelectorOnMainThread:@selector(showSettingsMenu) withObject:nil waitUntilDone:NO];
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [panGesture setEnabled:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do something...
            [[ASBanker sharedInstance] purchaseItem:allProducts[0]];
        });
        
    };
    [menuItems addObject:menuItem];
    
    
    menuItem = [[CNPGridMenuItem alloc] init];
    menuItem.icon = [self imageWithText:@"🎵" fontSize:32 rectSize:CGSizeMake(40, 40)];
    menuItem.title = @"Sounds";
    menuItem.selectionHandler = ^(CNPGridMenuItem* menuItem){
        NSLog(@"Awesome Sound Pack Pressed");
        [actionsMenu dismissGridMenuAnimated:NO completion:nil];
        //[self performSelectorOnMainThread:@selector(showSettingsMenu) withObject:nil waitUntilDone:NO];
        [[ASBanker sharedInstance] purchaseItem:allProducts[1]];
        [panGesture setEnabled:YES];
    };
    [menuItems addObject:menuItem];
#endif
    return [NSArray arrayWithArray:menuItems];
}

-(void)showSettingsMenu
{
    [self presentGridMenu:settingsMenu animated:YES completion:nil];
}

-(void)dismissSettingsMenu
{
    [settingsMenu dismissGridMenuAnimated:YES completion:nil];
}


-(NSArray*)createSettingsMenuItems
{
    NSArray* items = @[ @"Controls", @"Home", @"Wiki", @"Item Browser", @"Q/A", @"Rate" ];
//    NSArray* itemActions = @[
//                                ^(CNPGridMenuItem* menuItem){
//                                    
//                                    //[settingsMenu dismissGridMenuAnimated:YES completion:nil];
//                                    //[self performSelectorOnMainThread:@selector(dismissSettingsMenu) withObject:nil waitUntilDone:NO];
//                                    
//                                },
//                                ^(CNPGridMenuItem* menuItem){
//                                    NSLog( @"show home" );
//                                },
//                                ^(CNPGridMenuItem* menuItem){
//                                    NSLog( @"show wiki" );
//                                },
//                                ^(CNPGridMenuItem* menuItem){
//                                    NSLog( @"show item browser" );
//                                },
//                                ^(CNPGridMenuItem* menuItem){
//                                    NSLog( @"show Q/A" );
//                                },
//                                ^(CNPGridMenuItem* menuItem){
//                                    NSLog( @"show rate" );
//                                },
//                                 
//                              ];
//    NSArray* icons = @{ @"C", @"W", @"I", @"Q" };
    NSMutableArray* menuItems = [NSMutableArray array];
    for( NSUInteger i = 0; i < [items count]; ++i )
    {
        NSString* item = items[i];
    
        CNPGridMenuItem *menuItem = [[CNPGridMenuItem alloc] init];
        //menuItem.icon = [UIImage imageNamed:item[@"Icon"]];
        //menuItem.icon = [self imageFromText:item[@"Command"] width:40 height:40];
        menuItem.icon = [self imageWithText:@"H" fontSize:32 rectSize:CGSizeMake(40, 40)];
        menuItem.title = item;
        //menuItem.selectionHandler = itemActions[i];
        [menuItems addObject:menuItem];
    }
    
    ((CNPGridMenuItem*)menuItems[0]).selectionHandler =^ (CNPGridMenuItem* menuItem){
        
        NSLog( @"show controls" );
        [settingsMenu dismissGridMenuAnimated:YES completion:nil];
        //[self performSelectorOnMainThread:@selector(dismissSettingsMenu) withObject:nil waitUntilDone:NO];
        
    };
    
    ((CNPGridMenuItem*)menuItems[1]).selectionHandler =^ (CNPGridMenuItem* menuItem){
        
        NSLog( @"show home" );
        [settingsMenu dismissGridMenuAnimated:YES completion:nil];
        //[self performSelectorOnMainThread:@selector(dismissSettingsMenu) withObject:nil waitUntilDone:NO];
        
    };
    
    ((CNPGridMenuItem*)menuItems[2]).selectionHandler =^ (CNPGridMenuItem* menuItem){
        
        NSLog( @"show wiki" );
        [settingsMenu dismissGridMenuAnimated:YES completion:nil];
        //[self performSelectorOnMainThread:@selector(dismissSettingsMenu) withObject:nil waitUntilDone:NO];
        
    };
    
    ((CNPGridMenuItem*)menuItems[3]).selectionHandler =^ (CNPGridMenuItem* menuItem){
        
        NSLog( @"show item browser" );
        [settingsMenu dismissGridMenuAnimated:YES completion:nil];
        //[self performSelectorOnMainThread:@selector(dismissSettingsMenu) withObject:nil waitUntilDone:NO];
        
    };
    
    ((CNPGridMenuItem*)menuItems[4]).selectionHandler =^ (CNPGridMenuItem* menuItem){
        
        NSLog( @"show Q/A" );
        [settingsMenu dismissGridMenuAnimated:YES completion:nil];
        //[self performSelectorOnMainThread:@selector(dismissSettingsMenu) withObject:nil waitUntilDone:NO];
        
    };

    ((CNPGridMenuItem*)menuItems[5]).selectionHandler =^ (CNPGridMenuItem* menuItem){
        
        NSLog( @"show rate" );
        [settingsMenu dismissGridMenuAnimated:YES completion:nil];
        //[self performSelectorOnMainThread:@selector(dismissSettingsMenu) withObject:nil waitUntilDone:NO];
        
    };



    
    return [NSArray arrayWithArray:menuItems];
}


- (void)gridMenuDidTapOnBackground:(CNPGridMenu *)menu {
    
    [self dismissGridMenuAnimated:YES completion:^{
        [panGesture setEnabled:YES];
        NSLog(@"Grid Menu Dismissed With Background Tap");
    }];
}

#if 0
- (void)gridMenu:(CNPGridMenu *)menu didTapOnItem:(CNPGridMenuItem *)item {

    [self dismissGridMenuAnimated:NO completion:^{
        NSLog(@"Grid Menu Did Tap On Item: %@", item.title);
    }];
}
#endif


//-(void)TouchUpInside:(id)sender
//{
//    UIButton* button = (UIButton*)sender;
//    switch ( button.tag )
//    {
//        case 1000:
//            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_LEFT );
//            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_LEFT );
//            break;
//        case 1001:
//            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_RIGHT );
//            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_RIGHT );
//            break;
//        case 1002:
//            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_UP );
//            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_UP );
//            break;
//        case 1003:
//            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_DOWN );
//            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_DOWN );
//            break;
//        case 1004:
//            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_RETURN );
//            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_RETURN );
//            
//            break;
//        case 1005:
//            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_ESCAPE );
//            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_ESCAPE );
//            
//            break;
//
//        case 1006:
//            SDL_SendKeyboardText("<");
//            break;
//            
//        case 1007:
//            SDL_SendKeyboardText( ">" );
//            break;
//
//        default:
//            break;
//    }
//    
//    NSLog(@"TouchUpInside");
//}


-(void)doVolumeFade1
{
    if (myAudioPlayer.volume > 0.1) {
        myAudioPlayer.volume = myAudioPlayer.volume - 0.1;
        [self performSelector:@selector(doVolumeFade1) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        [myAudioPlayer stop];
//        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:@"DTA_Eminor_Spheres.wav" ];
//        myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
//        myAudioPlayer.numberOfLoops = -1; //infinite loop
//        [myAudioPlayer play];
//        self.player.currentTime = 0;
//        [self.player prepareToPlay];
//        self.player.volume = 1.0;
    }
}

-(void)doVolumeFade2
{
    if (myAudioPlayer.volume > 0.1) {
        myAudioPlayer.volume = myAudioPlayer.volume - 0.1;
        [self performSelector:@selector(doVolumeFade2) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        [myAudioPlayer stop];
        //        self.player.currentTime = 0;
        //        [self.player prepareToPlay];
        //        self.player.volume = 1.0;
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.view setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
    static BOOL firstTime = YES;
    //[track play];
    //[track fadeTo:0.0 duration:3.0 target:nil selector:nil];
    [super viewDidAppear:animated];
    
    
    //else
    if( firstTime )
    {
        firstTime = NO;
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        float scale = 1;
        if( ( [SDVersion deviceVersion] == iPad2 ) ||
           ( [SDVersion deviceVersion] == iPadAir ) ||
           ( [SDVersion deviceVersion] == iPadAir2 ) ||
           ( [SDVersion deviceVersion] == iPadMini ) ||
           ( [SDVersion deviceVersion] == iPadMini2 ) ||
           ( [SDVersion deviceVersion] == iPadMini3 ) ||
           ( [SDVersion deviceVersion] == iPadMini4 ) )
            scale = 2;
        
        
        if (self->window->flags & SDL_WINDOW_RESIZABLE) {
            SDL_WindowData *data = self->window->driverdata;
            SDL_VideoDisplay *display = SDL_GetDisplayForWindow(self->window);
            SDL_DisplayModeData *displaymodedata = (SDL_DisplayModeData *) display->current_mode.driverdata;
            const CGSize size = data->view.bounds.size;
            int w, h;

            w = (int)(size.width * displaymodedata->scale);
            h = (int)(size.height * displaymodedata->scale);

            SDL_SendWindowEvent(self->window, SDL_WINDOWEVENT_RESIZED, w, h);
        }
        


        

        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(singleTapped:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.delegate = self;
        [self.view addGestureRecognizer:singleTap];
        
        
        UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeUp.numberOfTouchesRequired = 1;
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        swipeUp.delegate = self;
        [self.view addGestureRecognizer:swipeUp];
        
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeDown.numberOfTouchesRequired = 1;
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        swipeDown.delegate = self;
        [self.view addGestureRecognizer:swipeDown];
        
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeLeft.numberOfTouchesRequired = 1;
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        swipeLeft.delegate = self;
        [self.view addGestureRecognizer:swipeLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeRight.numberOfTouchesRequired = 1;
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        swipeRight.delegate = self;
        [self.view addGestureRecognizer:swipeRight];
        
        
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        panGesture.minimumNumberOfTouches = 2;
        panGesture.maximumNumberOfTouches = 3;
        panGesture.delegate = self;
        [self.view addGestureRecognizer:panGesture];
        
        
        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(hangleLongPress:)];
        longPressGesture.minimumPressDuration = 1.0;
        [self.view addGestureRecognizer:longPressGesture];

        
        
        noButton = [[JSButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-64-64-16, self.view.bounds.size.height-64, 64, 64)];
        //[[yesButton titleLabel] setText:@"Next"];
        [noButton setBackgroundImage:[UIImage imageNamed:@"No"]];
        [noButton setBackgroundImagePressed:[UIImage imageNamed:@"No_Touched"]];
        noButton.delegate = self;
        noButton.alpha = 0.3f;
        noButton.controller = self;
        [self.view addSubview:noButton];
        if( [userDefaults floatForKey:@"NoPosX"] == -1.0f || [userDefaults floatForKey:@"NoPosY"] == -1.0f )
        {
            [userDefaults setFloat:noButton.center.x forKey:@"NoPosX"];
            [userDefaults setFloat:noButton.center.y forKey:@"NoPosY"];
            [userDefaults setFloat:noButton.transform.a forKey:@"NoScale"];
            [userDefaults synchronize];
        }
        else
        {
            [noButton setTransform:CGAffineTransformMakeScale([userDefaults floatForKey:@"NoScale"], [userDefaults floatForKey:@"NoScale"])];
            [noButton setCenter:CGPointMake([userDefaults floatForKey:@"NoPosX"], [userDefaults floatForKey:@"NoPosY"])];
        }
        
        
        yesButton = [[JSButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-64, self.view.bounds.size.height-64, 64, 64)];
        //[[noButton titleLabel] setText:@"Prev"];
        [yesButton setBackgroundImage:[UIImage imageNamed:@"Yes"]];
        [yesButton setBackgroundImagePressed:[UIImage imageNamed:@"Yes_Touched"]];
        yesButton.delegate = self;
        yesButton.alpha = 0.3f;
        yesButton.controller = self;
        [self.view addSubview:yesButton];
        if( [userDefaults floatForKey:@"YesPosX"] == -1.0f || [userDefaults floatForKey:@"YesPosY"] == -1.0f )
        {
            [userDefaults setFloat:yesButton.center.x forKey:@"YesPosX"];
            [userDefaults setFloat:yesButton.center.y forKey:@"YesPosY"];
            [userDefaults setFloat:yesButton.transform.a forKey:@"YesScale"];
            [userDefaults synchronize];
        }
        else
        {
            [yesButton setTransform:CGAffineTransformMakeScale([userDefaults floatForKey:@"YesScale"], [userDefaults floatForKey:@"YesScale"])];
            [yesButton setCenter:CGPointMake([userDefaults floatForKey:@"YesPosX"], [userDefaults floatForKey:@"YesPosY"])];
        }
        
        prevButton = [[JSButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-64-64-16, self.view.bounds.size.height-64-64, 64, 64)];
        //[[yesButton titleLabel] setText:@"Next"];
        [prevButton setBackgroundImage:[UIImage imageNamed:@"Prev"]];
        [prevButton setBackgroundImagePressed:[UIImage imageNamed:@"Prev_Touched"]];
        prevButton.delegate = self;
        prevButton.alpha = 0.3f;
        prevButton.controller = self;
        [self.view addSubview:prevButton];
        if( [userDefaults floatForKey:@"PrevPosX"] == -1.0f || [userDefaults floatForKey:@"PrevPosY"] == -1.0f )
        {
            [userDefaults setFloat:prevButton.center.x forKey:@"PrevPosX"];
            [userDefaults setFloat:prevButton.center.y forKey:@"PrevPosY"];
            [userDefaults setFloat:prevButton.transform.a forKey:@"NextScale"];
            [userDefaults synchronize];
        }
        else
        {
            [prevButton setTransform:CGAffineTransformMakeScale([userDefaults floatForKey:@"PrevScale"], [userDefaults floatForKey:@"PrevScale"])];
            [prevButton setCenter:CGPointMake([userDefaults floatForKey:@"PrevPosX"], [userDefaults floatForKey:@"PrevPosY"])];
        }
        
        nextButton = [[JSButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-64, self.view.bounds.size.height-64-64, 64, 64)];
        //[[yesButton titleLabel] setText:@"Next"];
        [nextButton setBackgroundImage:[UIImage imageNamed:@"Next"]];
        [nextButton setBackgroundImagePressed:[UIImage imageNamed:@"Next_Touched"]];
        nextButton.delegate = self;
        nextButton.alpha = 0.3f;
        nextButton.controller = self;
        [self.view addSubview:nextButton];
        if( [userDefaults floatForKey:@"NextPosX"] == -1.0f || [userDefaults floatForKey:@"NextPosY"] == -1.0f )
        {
            [userDefaults setFloat:nextButton.center.x forKey:@"NextPosX"];
            [userDefaults setFloat:nextButton.center.y forKey:@"NextPosY"];
            [userDefaults setFloat:nextButton.transform.a forKey:@"NextScale"];
            [userDefaults synchronize];
        }
        else
        {
            [nextButton setTransform:CGAffineTransformMakeScale([userDefaults floatForKey:@"NextScale"], [userDefaults floatForKey:@"NextScale"])];
            [nextButton setCenter:CGPointMake([userDefaults floatForKey:@"NextPosX"], [userDefaults floatForKey:@"NextPosY"])];
        }
        
        
        tabButton = [[JSButton alloc] initWithFrame:CGRectMake(8, 8, 32, 32)];
        //[tabButton.layer setAnchorPoint:CGPointMake(0, 1)];
        //[[noButton titleLabel] setText:@"Prev"];
        [tabButton setBackgroundImage:[UIImage imageNamed:@"tab"]];
        [tabButton setBackgroundImagePressed:[UIImage imageNamed:@"tab_Touched"]];
        tabButton.delegate = self;
        tabButton.alpha = 0.3f;
        [self.view addSubview:tabButton];
        
        
        
    //    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    //    
    //    NSDictionary *views = NSDictionaryOfVariableBindings(button1, button2, button3, button4, button5, button6, button7, button8);
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button1][button2(==button1)][button3(==button1)][button4(==button1)][button5(==button1)][button6(==button1)][button7(==button1)][button8(==button1)]|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];


        UIPinchGestureRecognizer* pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        [self.view addGestureRecognizer:pinchGestureRecognizer];
        
        
        
        dPad = [[JSDPad alloc] initWithFrame:CGRectMake(8, self.view.bounds.size.height - 8 - 144, 144, 144)];
        dPad.delegate = self;
        dPad.alpha = 0.3f;
        dPad.controller = self;
        [self.view addSubview:dPad];
        NSLog(@"%f %f", [userDefaults floatForKey:@"DPadPosX"], [userDefaults floatForKey:@"DPadPosY"] );
        if( [userDefaults floatForKey:@"DPadPosX"] == -1.0f || [userDefaults floatForKey:@"DPadPosY"] == -1.0f )
        {
            [userDefaults setFloat:dPad.center.x forKey:@"DPadPosX"];
            [userDefaults setFloat:dPad.center.y forKey:@"DPadPosY"];
            [userDefaults setFloat:dPad.transform.a forKey:@"DPadScale"];
            [userDefaults synchronize];
        }
        else
        {
            [dPad setTransform:CGAffineTransformMakeScale([userDefaults floatForKey:@"DPadScale"], [userDefaults floatForKey:@"DPadScale"])];
            [dPad setCenter:CGPointMake([userDefaults floatForKey:@"DPadPosX"], [userDefaults floatForKey:@"DPadPosY"])];
        }
        
        
        
        
        optionsButton = [[JSButton alloc] initWithFrame:CGRectMake( self.view.bounds.size.width - 28 * scale, 0, 28 * scale, 28* scale)];
        [optionsButton setBackgroundImage:[UIImage imageNamed:@"options_silver_on"]];
        [optionsButton setBackgroundImagePressed:[UIImage imageNamed:@"options_silver_off"]];
        optionsButton.delegate = self;
        optionsButton.alpha = 0.3f;
        [self.view addSubview:optionsButton];
        
        
        isModifyingUI = NO;
        
        
        [self loadKeyBindings];
        
        allMenuItems = [self createMenuItems:userKeyBindings];
        actionsMenu = [[CNPGridMenu alloc] initWithMenuItems:allMenuItems];
        actionsMenu.delegate = self;
        
        
        NSArray* settingsMenuItems = [self createSettingsMenuItems];
    //    settingsMenu = [[CNPGridMenu alloc] initWithMenuItems:settingsMenuItems];
        settingsMenu = [[CNPGridMenu alloc] initWithMenuItems:@[]];
        [settingsMenu setMenuItems:settingsMenuItems];
        settingsMenu.delegate = self;
        
        
        
        documentPath = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path] stringByAppendingString:@"/"];
        optionsFileWatcher = [MHWDirectoryWatcher directoryWatcherAtPath:[documentPath stringByAppendingPathComponent:@"options.txt"] callback:^{
            [optionsFileWatcher stopWatching];
            [self performSelectorOnMainThread:@selector(optionsFileDidChange) withObject:nil waitUntilDone:NO];
        }];
        

        userKeyBindingsPath = [documentPath stringByAppendingPathComponent:@"keybindings.json"];
        
        NSError* e;
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:userKeyBindingsPath error:&e];
        keybindingsLastModificationDate = attributes[@"NSFileModificationDate"];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        
    }
    else
    {
        SDL_WindowData *data = self->window->driverdata;
        SDL_VideoDisplay *display = SDL_GetDisplayForWindow(self->window);
        SDL_DisplayModeData *displaymodedata = (SDL_DisplayModeData *) display->current_mode.driverdata;
        const CGSize size = data->view.bounds.size;
        int w, h;
        
        w = (int)(size.width * displaymodedata->scale);
        h = (int)(size.height * displaymodedata->scale);
        
        SDL_SendWindowEvent(self->window, SDL_WINDOWEVENT_EXPOSED, w, h);
    }
    
    if( showIntroduction )
    {
        //[self doVolumeFade1];
        showIntroduction = NO;
        [self showIntroductionView];
    }
    
    
    
    NSString *str = @"Timer event has fired";
   
    


    //KEYBOARD_LABELS = 0;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //[center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //SDL_StopTextInput();
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (!KEYBOARD_LABELS) {
//            return;
//        }
//        
//        BOOL hasShownKeyBoardWarning = NO;//[[NSUserDefaults standardUserDefaults] boolForKey:@"Has Shown Keyboard Warning"];
//        
//        if (!hasShownKeyBoardWarning) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Keyboard Detected" message:@"There's a bluetooth keyboard detected. The in game keyboard will not be displayed. Turn off blue tooth if you do not plan on using an external keyboard." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//        }
//    });
    
    detectionTextField = [[UITextField alloc] initWithFrame: CGRectZero];
    detectionTextField.delegate = self;
    /* placeholder so there is something to delete! */
    detectionTextField.text = @" ";
    
    /* set UITextInputTrait properties, mostly to defaults */
    detectionTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    detectionTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    detectionTextField.enablesReturnKeyAutomatically = NO;
    detectionTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    detectionTextField.keyboardType = UIKeyboardTypeDefault;
    detectionTextField.returnKeyType = UIReturnKeyDefault;
    detectionTextField.secureTextEntry = NO;
    
    detectionTextField.hidden = YES;
    
    [self.view addSubview:detectionTextField];
    
    detectionFlag = NO;
    keyboardConnected = NO;
    //[detectionTextField becomeFirstResponder];
    
    
    aTextField = [[UITextField alloc] initWithFrame: CGRectZero];
    aTextField.delegate = self;
    /* placeholder so there is something to delete! */
    aTextField.text = @" ";
    
    /* set UITextInputTrait properties, mostly to defaults */
    aTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    aTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    aTextField.enablesReturnKeyAutomatically = NO;
    aTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    aTextField.keyboardType = UIKeyboardTypeDefault;
    aTextField.returnKeyType = UIReturnKeyDefault;
    aTextField.secureTextEntry = NO;
    
    aTextField.hidden = YES;
    
    [self.view addSubview:aTextField];


}

- (void)keyboardDidHide: (NSNotification *) notif{
    SDL_StopTextInput();
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger orientationMask = 0;

    const char *orientationsCString;
    if ((orientationsCString = SDL_GetHint(SDL_HINT_ORIENTATIONS)) != NULL) {
        BOOL rotate = NO;
        NSString *orientationsNSString = [NSString stringWithCString:orientationsCString
                                                            encoding:NSUTF8StringEncoding];
        NSArray *orientations = [orientationsNSString componentsSeparatedByCharactersInSet:
                                 [NSCharacterSet characterSetWithCharactersInString:@" "]];

        if ([orientations containsObject:@"LandscapeLeft"]) {
            orientationMask |= UIInterfaceOrientationMaskLandscapeLeft;
        }
        if ([orientations containsObject:@"LandscapeRight"]) {
            orientationMask |= UIInterfaceOrientationMaskLandscapeRight;
        }
        if ([orientations containsObject:@"Portrait"]) {
            orientationMask |= UIInterfaceOrientationMaskPortrait;
        }
        if ([orientations containsObject:@"PortraitUpsideDown"]) {
            orientationMask |= UIInterfaceOrientationMaskPortraitUpsideDown;
        }

    } else if (self->window->flags & SDL_WINDOW_RESIZABLE) {
        orientationMask = UIInterfaceOrientationMaskAll;  /* any orientation is okay. */
    } else {
        if (self->window->w >= self->window->h) {
            orientationMask |= UIInterfaceOrientationMaskLandscape;
        }
        if (self->window->h >= self->window->w) {
            orientationMask |= (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
        }
    }

    /* Don't allow upside-down orientation on the phone, so answering calls is in the natural orientation */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        orientationMask &= ~UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return orientationMask;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient
{
    NSUInteger orientationMask = [self supportedInterfaceOrientations];
    return (orientationMask & (1 << orient));
}

- (BOOL)prefersStatusBarHidden
{
//    if (self->window->flags & (SDL_WINDOW_FULLSCREEN|SDL_WINDOW_BORDERLESS)) {
//        return YES;
//    } else {
//        return NO;    //    }
    return YES;
}

-(void)singleTapped:(UIGestureRecognizer *)recognizer
{
    //NSLog( @"Single Tapped" );
    //SDL_SendKeyboardText( "." );
    NSLog(@"singleTapped: %@", NSStringFromCGPoint([recognizer locationInView:[recognizer.view superview]]));
}


- (void) handleSwipe:(UISwipeGestureRecognizer*)gesture
{
    //NSLog( @"Double Swipe: %lu", (unsigned long)gesture.direction );
    
    if( UISwipeGestureRecognizerDirectionUp == gesture.direction )
    {
        if( !SDL_IsScreenKeyboardShown( SDL_GetFocusWindow() ) )
            SDL_StartTextInput();
//        else
//            SDL_StopTextInput();
    }
    else if( UISwipeGestureRecognizerDirectionDown == gesture.direction )
    {
        if( SDL_IsScreenKeyboardShown( SDL_GetFocusWindow() ) )
        {
            SDL_StopTextInput();
            self.lockKeyboard = NO;
        }
        //[self presentGridMenu:actionsMenu animated:YES completion:nil];
    }
    else if( UISwipeGestureRecognizerDirectionLeft == gesture.direction )
    {
        SDL_SendKeyboardText( "V" );
    }
    else if( UISwipeGestureRecognizerDirectionRight == gesture.direction )
    {
        SDL_SendKeyboardText( "m" );
    }
}

-(void)handlePanGesture:(UIPanGestureRecognizer*)gesture
{
    //NSLog( @"%lu %f", (unsigned long)gesture.numberOfTouches, [gesture translationInView:self.view].y );
    
    
    
    
    if( 2 == gesture.numberOfTouches )
    {
        [panGesture setEnabled:NO];
        
        NSError* e;
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:userKeyBindingsPath error:&e];
        NSDate* currentModificationDate = attributes[@"NSFileModificationDate"];
        
        if( [currentModificationDate compare:keybindingsLastModificationDate] == NSOrderedDescending )
        {
            keybindingsLastModificationDate = currentModificationDate;
            [self keybindingsFileDidChange];
        }
        
        if( SDL_IsScreenKeyboardShown( SDL_GetFocusWindow() ) )
        {
            SDL_StopTextInput();
            self.lockKeyboard = NO;
        }
        
        [self presentGridMenu:actionsMenu animated:YES completion:^{
            
        }];

    }
    else if( 3 == gesture.numberOfTouches )
    {
        float alpha = dPad.alpha;
        float offsetY = [gesture translationInView:self.view].y;
        if( offsetY > 0 )
        {
            alpha -= 0.02;
            if( alpha <= 0.1 )
                alpha = 0.1;
        }
        else if( offsetY < 0 )
        {
            alpha += 0.02;
            if( alpha >= 0.9 )
                alpha = 0.9;
        }
        
        dPad.alpha = alpha;
        yesButton.alpha = alpha;
        noButton.alpha = alpha;
        nextButton.alpha = alpha;
        prevButton.alpha = alpha;
        tabButton.alpha = alpha;
    }
    
    
    [gesture setTranslation:CGPointMake(0, 0) inView:self.view];
}

-(void)hangleLongPress:(UILongPressGestureRecognizer*)gesture
{
    if( gesture.state == UIGestureRecognizerStateEnded )
    {
        NSLog( @"Long Press Ended" );
    }
    else if( gesture.state == UIGestureRecognizerStateBegan )
    {
        NSLog( @"Long Press Began" );
        if( !SDL_IsScreenKeyboardShown( SDL_GetFocusWindow() ) )
        {
            self.lockKeyboard = YES;
            SDL_StartTextInput();
        }
    }
}


-(void)handlePinchGesture:(UIPinchGestureRecognizer*)pinchGestureRecognier
{
    float threshold = 0.1f;
    
    if( pinchGestureRecognier.state == UIGestureRecognizerStateEnded )
    {
        NSLog( @"%f", pinchGestureRecognier.scale );
        if( pinchGestureRecognier.scale > ( 1.0f + threshold ) )
        {
            if( isModifyingUI )
            {
                float scale = self.selectedUI.transform.a;
                scale += 0.25f;
                if( scale > 2.0f )
                    scale = 2.0f;
                [self.selectedUI setTransform:CGAffineTransformMakeScale(scale, scale)];
            }
            else
                SDL_SendKeyboardText( "Z" );
        }
        else if( pinchGestureRecognier.scale < ( 1.0f - threshold ) )
        {
            if( isModifyingUI )
            {
                float scale = self.selectedUI.transform.a;
                scale -= 0.25f;
                if( scale < 0.5f )
                    scale = 0.5f;
                [self.selectedUI setTransform:CGAffineTransformMakeScale(scale, scale)];

            }
            else
                SDL_SendKeyboardText( "z" );
        }
        pinchGestureRecognier.scale = 1.0f;
    }
    
}




- (UIImage *)imageWithText:(NSString *)text fontSize:(CGFloat)fontSize rectSize:(CGSize)rectSize {
    
    // 描画する文字列のフォントを設定。
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    // オフスクリーン描画のためのグラフィックスコンテキストを作る。
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(rectSize, NO, 0.0f);
    else
        UIGraphicsBeginImageContext(rectSize);
    
    /* Shadowを付ける場合は追加でこの部分の処理を行う。
     CGContextRef ctx = UIGraphicsGetCurrentContext();
     CGContextSetShadowWithColor(ctx, CGSizeMake(1.0f, 1.0f), 5.0f, [[UIColor grayColor] CGColor]);
     */
    
    // 文字列の描画領域のサイズをあらかじめ算出しておく。
    CGSize textAreaSize = [text sizeWithFont:font constrainedToSize:rectSize];
    
    // 描画対象領域の中央に文字列を描画する。
    [text drawInRect:CGRectMake((rectSize.width - textAreaSize.width) * 0.5f,
                                (rectSize.height - textAreaSize.height) * 0.5f,
                                textAreaSize.width,
                                textAreaSize.height)
            withFont:font
       lineBreakMode:NSLineBreakByWordWrapping
           alignment:NSTextAlignmentCenter];
    
    // コンテキストから画像オブジェクトを作成する。
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)dpadTimerHandler:(NSTimer *)timer
{
    //NSLog( @"dpadTimerHandler" );
    
    switch( [[timer userInfo][@"Direction"] integerValue] )
    {
        case JSDPadDirectionLeft:
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_LEFT );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_LEFT );
            break;
            
        case JSDPadDirectionRight:
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_RIGHT );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_RIGHT );
            break;
            
        case JSDPadDirectionUp:
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_UP );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_UP );
            break;
            
        case JSDPadDirectionDown:
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_DOWN );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_DOWN );
            break;
            
        case JSDPadDirectionUpLeft:
            SDL_SendKeyboardText( "y" );
            break;
            
        case JSDPadDirectionUpRight:
            SDL_SendKeyboardText( "u" );
            break;
            
        case JSDPadDirectionDownLeft:
            SDL_SendKeyboardText( "b" );
            break;
            
        case JSDPadDirectionDownRight:
            SDL_SendKeyboardText( "n" );
            break;
            
        case JSDPadDirectionCenter:
            SDL_SendKeyboardText( "." );
            break;
            
        default:
            break;
            
    }
    
    //dpadTimer = [NSTimer scheduledTimerWithTimeInterval:0.333 target:self selector:@selector(dpadTimerHandler:) userInfo:@{@"Direction": [timer userInfo][@"Direction"]} repeats:NO];
    
//    [dpadTimer fire];
    
}

#pragma mark - JSDPadDelegate
- (NSString *)stringForDirection:(JSDPadDirection)direction
{
    NSString *string = nil;
    
    switch (direction) {
        case JSDPadDirectionNone:
            string = @"None";
            SDL_SendKeyboardText( "." );
            break;
        case JSDPadDirectionUp:
            string = @"Up";
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_UP );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_UP );
            if( dpadTimer && [dpadTimer isValid] )
            {
                [dpadTimer invalidate];
                dpadTimer = nil;
            }
            dpadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dpadTimerHandler:) userInfo:@{@"Direction": [NSNumber numberWithInteger:JSDPadDirectionUp]} repeats:YES];
            
            //[dpadTimer fire];
            //SDL_SendKeyboardText( "8" );
            break;
        case JSDPadDirectionDown:
            string = @"Down";
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_DOWN );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_DOWN );
            if( dpadTimer && [dpadTimer isValid] )
            {
                [dpadTimer invalidate];
                dpadTimer = nil;
            }
            dpadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dpadTimerHandler:) userInfo:@{@"Direction": [NSNumber numberWithInteger:JSDPadDirectionDown]} repeats:YES];
            
            //[dpadTimer fire];
            //SDL_SendKeyboardText( "2" );
            break;
        case JSDPadDirectionLeft:
            string = @"Left";
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_LEFT );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_LEFT );
            if( dpadTimer && [dpadTimer isValid] )
            {
                [dpadTimer invalidate];
                dpadTimer = nil;
            }
            dpadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dpadTimerHandler:) userInfo:@{@"Direction": [NSNumber numberWithInteger:JSDPadDirectionLeft]} repeats:YES];
            
            //[dpadTimer fire];

            //SDL_SendKeyboardText( "h" );
            break;
        case JSDPadDirectionRight:
            string = @"Right";
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_RIGHT );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_RIGHT );
            if( dpadTimer && [dpadTimer isValid] )
            {
                [dpadTimer invalidate];
                dpadTimer = nil;
            }
            dpadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dpadTimerHandler:) userInfo:@{@"Direction": [NSNumber numberWithInteger:JSDPadDirectionRight]} repeats:YES];
            
            //[dpadTimer fire];
            //SDL_SendKeyboardText( "l" );
            break;
        case JSDPadDirectionUpLeft:
            string = @"Up Left";
            SDL_SendKeyboardText( "y" );
            if( dpadTimer && [dpadTimer isValid] )
            {
                [dpadTimer invalidate];
                dpadTimer = nil;
            }
            dpadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dpadTimerHandler:) userInfo:@{@"Direction": [NSNumber numberWithInteger:JSDPadDirectionUpLeft]} repeats:YES];
            break;
        case JSDPadDirectionUpRight:
            string = @"Up Right";
            SDL_SendKeyboardText( "u" );
            if( dpadTimer && [dpadTimer isValid] )
            {
                [dpadTimer invalidate];
                dpadTimer = nil;
            }
            dpadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dpadTimerHandler:) userInfo:@{@"Direction": [NSNumber numberWithInteger:JSDPadDirectionUpRight]} repeats:YES];
            break;
        case JSDPadDirectionDownLeft:
            string = @"Down Left";
            SDL_SendKeyboardText( "b" );
            if( dpadTimer && [dpadTimer isValid] )
            {
                [dpadTimer invalidate];
                dpadTimer = nil;
            }
            dpadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dpadTimerHandler:) userInfo:@{@"Direction": [NSNumber numberWithInteger:JSDPadDirectionDownLeft]} repeats:YES];
            break;
        case JSDPadDirectionDownRight:
            string = @"Down Right";
            SDL_SendKeyboardText( "n" );
            if( dpadTimer && [dpadTimer isValid] )
            {
                [dpadTimer invalidate];
                dpadTimer = nil;
            }
            dpadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dpadTimerHandler:) userInfo:@{@"Direction": [NSNumber numberWithInteger:JSDPadDirectionDownRight]} repeats:YES];
            break;
            
        case JSDPadDirectionCenter:
            //SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_RETURN );
            //SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_RETURN );
            SDL_SendKeyboardText( "." );
            if( dpadTimer && [dpadTimer isValid] )
            {
                [dpadTimer invalidate];
                dpadTimer = nil;
            }
            dpadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dpadTimerHandler:) userInfo:@{@"Direction": [NSNumber numberWithInteger:JSDPadDirectionCenter]} repeats:YES];
            break;
            
        default:
            string = @"NO";
            break;
    }
    
    return string;
}


- (void)dPad:(JSDPad *)dPad didPressDirection:(JSDPadDirection)direction
{
    [longPressGesture setEnabled:NO];
    [self stringForDirection:direction];
    //NSLog(@"Changing direction to: %@", [self stringForDirection:direction]);
    //[self updateDirectionLabel];
    
}

- (void)dPadDidReleaseDirection:(JSDPad *)dpad
{
    //NSLog(@"Releasing DPad");
    //[self updateDirectionLabel];
    [dpadTimer invalidate];
    dpadTimer = nil;
    [longPressGesture setEnabled:YES];
}


#pragma mark - JSButtonDelegate

- (void)buttonPressed:(JSButton *)button
{
    [longPressGesture setEnabled:NO];
    
    
}

- (void)buttonReleased:(JSButton *)button
{
    if ([button isEqual:yesButton])
    {
        SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_RETURN );
        SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_RETURN );
    }
    else if ([button isEqual:noButton])
    {
        SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_ESCAPE );
        SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_ESCAPE );
    }
    else if( [button isEqual:prevButton])
    {
        SDL_SendKeyboardText("<");
    }
    else if( [button isEqual:nextButton] )
    {
        SDL_SendKeyboardText(">");
        //SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_TAB );
        //SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_TAB );
    }
    else if( [button isEqual:tabButton] )
    {
        SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_TAB );
        SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_TAB );
    }
    else if( [button isEqual:optionsButton] )
    {
        [self didTapOptionsButton];
    }
    
    [longPressGesture setEnabled:YES];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[dPad class]] || [touch.view isKindOfClass:[yesButton class]] )
    {
        return NO;
    }
    
    return YES;
}


-(void) showAllUI
{
    dPad.isModifying = NO;
    dPad.panGestureRecognizer.enabled = NO;
    yesButton.isModifying = NO;
    yesButton.panGestureRecognizer.enabled = NO;
    noButton.isModifying = NO;
    noButton.panGestureRecognizer.enabled = NO;
    prevButton.isModifying = NO;
    prevButton.panGestureRecognizer.enabled = NO;
    nextButton.isModifying = NO;
    nextButton.panGestureRecognizer.enabled = NO;
    
    [dPad setAlpha:0.3f];
    [yesButton setAlpha:0.3f];
    [noButton setAlpha:0.3f];
    [prevButton setAlpha:0.3f];
    [nextButton setAlpha:0.3f];
    
    optionsButton.backgroundImage = [UIImage imageNamed:@"options_silver_on"];
    
}

-(void)didTapOptionsButton
{
    
    //if( gesture.state == UIGestureRecognizerStateBegan )
    {
        
        
        NSLog( @"Triple Tapped" );
        
        if( isModifyingUI )
        {
            isModifyingUI = NO;
            
            [uiBlickTimer invalidate];
            [self showAllUI];
            
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setFloat:dPad.transform.a forKey:@"DPadScale"];
            [userDefaults setFloat:dPad.center.x forKey:@"DPadPosX"];
            [userDefaults setFloat:dPad.center.y forKey:@"DPadPosY"];
            
            [userDefaults setFloat:yesButton.transform.a forKey:@"YesScale"];
            [userDefaults setFloat:yesButton.center.x forKey:@"YesPosX"];
            [userDefaults setFloat:yesButton.center.y forKey:@"YesPosY"];
            
            [userDefaults setFloat:noButton.transform.a forKey:@"NoScale"];
            [userDefaults setFloat:noButton.center.x forKey:@"NoPosX"];
            [userDefaults setFloat:noButton.center.y forKey:@"NoPosY"];
            
            [userDefaults setFloat:prevButton.transform.a forKey:@"PrevScale"];
            [userDefaults setFloat:prevButton.center.x forKey:@"PrevPosX"];
            [userDefaults setFloat:prevButton.center.y forKey:@"PrevPosY"];
            
            [userDefaults setFloat:nextButton.transform.a forKey:@"NextScale"];
            [userDefaults setFloat:nextButton.center.x forKey:@"NextPosX"];
            [userDefaults setFloat:nextButton.center.y forKey:@"NextPosY"];
            
            [userDefaults synchronize];
            
        }
        else
        {
            alertView = [[SCLAlertView alloc] init];
            //Using Selector
            SCLButton* button = [alertView addButton:@"Show tutorial" actionBlock:^(void) {
                NSLog(@"Show tutorial");
                //[self showLeaderboard];
            }];
            button.persistAfterExecution = YES;
            
            //Using Block
            button = [alertView addButton:@"Show keybindings" actionBlock:^(void) {
                NSLog(@"Show keybindings");
                //[self showKeybindings];
                
            }];
            button.persistAfterExecution = YES;
            
            //Using Block
            button = [alertView addButton:@"Adjust user interface" actionBlock:^(void) {
                NSLog(@"Adjust user interface");
                [self askIfAdjustUI];
                
                
            }];
            button.persistAfterExecution = NO;
            
            
            if( iOSVersionGreaterThanOrEqualTo(@"9") )
            {
                if( isRecording )
                {
                    button = [alertView addButton:@"Stop recording" actionBlock:^(void) {
                        NSLog(@"Stop recording");
                        isRecording = NO;
                        [self stopRecording];
                    }];
                }
                else
                {
                    button = [alertView addButton:@"Start recording" actionBlock:^(void) {
                        NSLog(@"Start recording");
                        isRecording = YES;
                        [self startRecording];
                    }];
                }
                button.persistAfterExecution = NO;
            }
            
            
            alertView.shouldDismissOnTapOutside = YES;
            [alertView showCustom:self image:[UIImage imageNamed:@"icon_152.jpg"] color:[UIColor blackColor] title:@"Options" subTitle:nil closeButtonTitle:nil duration:0.0f];
            
            
        }
        
    }
    
 
}

-(void)loadKeyBindings
{
    NSString* basePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/"];
    NSString* defaultKeyBindingsPath = [basePath stringByAppendingPathComponent:@"data/raw/keybindings.json"];
    
    
    NSError *e = nil;
    
    
    NSMutableArray* defaultKeyBindings = [NSMutableArray array];
    NSArray *defaultKeyBindingsJSONArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:defaultKeyBindingsPath] options:NSJSONReadingMutableContainers error:&e];
    actionDesc = [NSMutableDictionary dictionary];
    if (!defaultKeyBindingsJSONArray) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        for(NSDictionary *item in defaultKeyBindingsJSONArray)
        {
            if( [item[@"category"] isEqualToString:@"DEFAULTMODE"] )
            {
                for (NSDictionary* binding in item[@"bindings"])
                {
                    if( [binding[@"input_method"] isEqualToString:@"keyboard"] )
                    {
                        if( actionDesc[ item[@"id"] ] == nil )
                        {
                            actionDesc[ item[@"id"] ] = item[@"name"];
                            
                            //NSLog( @"%@: %@", [NSString stringWithUTF8String:gettext( [item[@"name"] cStringUsingEncoding:NSUTF8StringEncoding] ) ], binding[@"key"] );
                            
                            [defaultKeyBindings addObject:@{@"Title": [NSString stringWithUTF8String:gettext( [item[@"name"] cStringUsingEncoding:NSUTF8StringEncoding] ) ],
                                                            @"Command": binding[@"key"],
                                                            @"Icon": @""}];
                        }
                        
                        
                        continue;
                    }
                }
                
                if( actionDesc[ item[@"id"] ] == nil )
                    actionDesc[ item[@"id"] ] = item[@"name"];
                    
            }
        }
    }
    
    
    
    
    
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:userKeyBindingsPath] )
    {
        userKeyBindings = [NSMutableArray array];
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:userKeyBindingsPath] options:NSJSONReadingMutableContainers error:&e];
        
        if (!jsonArray) {
            NSLog(@"Error parsing JSON: %@", e);
        } else {
            for(NSDictionary *item in jsonArray) {
                
                if( [item[@"category"] isEqualToString:@"DEFAULTMODE"] )
                {
                    //NSLog(@"Item: %@", item);
                    for (NSDictionary* binding in item[@"bindings"])
                    {
                        if( [binding[@"input_method"] isEqualToString:@"keyboard"] )
                        {
                            //input_context::getattrlist(<#const char *#>, <#void *#>, <#void *#>, <#size_t#>, <#unsigned int#>)
                            //NSLog( @"%@: %@", [NSString stringWithUTF8String:gettext( [actionDesc[ item[@"id"] ] cStringUsingEncoding:NSUTF8StringEncoding] ) ], binding[@"key"][0] );
                            [userKeyBindings addObject:@{@"Title": [NSString stringWithUTF8String:gettext( [actionDesc[ item[@"id"] ] cStringUsingEncoding:NSUTF8StringEncoding] ) ],
                                                         @"Command": binding[@"key"][0],
                                                         @"Icon": @""}];
                            continue;
                        }
                    }
                }
            }
        }
    }
    else
    {
        userKeyBindings = [NSMutableArray arrayWithArray:defaultKeyBindings];
    }
    
    NSArray *sorted = [userKeyBindings sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        NSString* obj1String = obj1[@"Command"];
        NSString* obj2String = obj2[@"Command"];
        return [obj1String compare:obj2String];
    }];
    
    userKeyBindings = [NSMutableArray arrayWithArray:sorted];
   
}
                          
                          
- (void)optionsFileDidChange
{
    NSLog(@"options.txt files changed" );
    
    [self loadKeyBindings];
    
    NSArray* newMenuItems = [self createMenuItems:userKeyBindings];
    //actionsMenu = [[CNPGridMenu alloc] initWithMenuItems:allMenuItems];
    [actionsMenu setMenuItems:newMenuItems];
    //actionsMenu.delegate = self;
    
    [optionsFileWatcher startWatching];
    
}

- (void)keybindingsFileDidChange
{
    NSLog(@"keybindings.json files changed" );
    
    [self loadKeyBindings];
    
    NSArray* newMenuItems = [self createMenuItems:userKeyBindings];
    //actionsMenu = [[CNPGridMenu alloc] initWithMenuItems:allMenuItems];
    [actionsMenu setMenuItems:newMenuItems];
    //actionsMenu.delegate = self;
}

-(void)showIntroductionView
{
    introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    introductionView.delegate = self;
    [introductionView setBackgroundColor:[UIColor blackColor]];
    
    
    MYIntroductionPanel *panelStory1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"Cataclysm: Dark Days Ahead" description:@"You emerge from the shelter into the dim light of an overcast day, and look around for the first time since the disaster." image:nil];
    MYIntroductionPanel *panelStory2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"Cataclysm: Dark Days Ahead" description:@"The world as you knew it is gone and in its place, a twisted mockery of all that was once familiar." image:nil];
    
    MYIntroductionPanel *panelStory3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"Cataclysm: Dark Days Ahead" description:@"Everything was cast aside in that frantic race for the shelter. You have no food, nothing to drink, no weapons. Nothing but your ingenuity and the fierce determination to survive against appalling odds." image:nil];
    
    MYIntroductionPanel *panelStory4 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"Cataclysm: Dark Days Ahead" description:@"A grim prospect faces you. Perhaps worse even than the nightmares of last night, when you were tortured by dreams of the dead themselves rising to jealously tear life from the living." image:nil];
    
    MYIntroductionPanel *panelStory5 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"Cataclysm: Dark Days Ahead" description:@"You cast your eyes up the road and begin to walk towards a house in the far distance. Things may be bad right now, but you've got a sinking feeling that there are darker days ahead." image:nil];
    
    MYIntroductionPanel *panelTitle = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"Cataclysm: Dark Days Ahead" description:nil image:nil];
    
    
    MYIntroductionPanel *panelControlDPad = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Play" description:@"Use the D-Pad to move your character or cursor." video:@"DPad"];
    
    MYIntroductionPanel *panelControlActionButtons = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Play" description:@"Use the action buttons to confirm or cancel actions. They work like the RETURN and ESC keys on the keyboard" video:@"ConfirmCancel"];
    
    MYIntroductionPanel *panelControlTabButtons= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Play" description:@"Use the tab buttons to move to next/previous tab, or descend/ascend stairs. They work like the > and < keys on the keyboard." video:@"TabStair"];
    
    MYIntroductionPanel *panelGesturesSwipeUpAndDown= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Play" description:@"Swipe up to show the keyboard. Swipe down to hide it." video:@"SwipeUp"];
    
    MYIntroductionPanel *panelGesturesLongPress= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Play" description:@"Long press empty space to show locked keyboard. It can be used to type long strings." video:@"LongPress"];
    
    MYIntroductionPanel *panelGesturesSwipeRight= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Play" description:@"Swipe right to show map. It works like pressing m key on the keyboard." video:@"SwipeRight"];
    
    MYIntroductionPanel *panelGesturesSwipeLeft= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Play" description:@"Swipe left to list all items/creatures around the player. It works like pressing V key on the keyboard." video:@"SwipeLeft"];
    
    MYIntroductionPanel *panelGesturesPinch= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Play" description:@"Pinch to zoom in or zoom out." video:@"Zoom"];
    
    MYIntroductionPanel *panelGesturesPause= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Play" description:@"Single tap to pause character, or keep moving while driving. It works like pressing . key on the keyboard." video:@"PauseDrive"];
    
    MYIntroductionPanel *panelGesturesDoubleSwipe= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Play" description:@"Two-finger swipe in any directions to show show all the controls. Tap empty space to dismiss." video:@"DoubleSwipe"];
    
    MYIntroductionPanel *panelGesturesTripleSwipe= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Play" description:@"Three-finger swipe up to increase opacity of the onscreen controls. Three-finger swipe down to decrease the opacity." video:@"3FingersSwipe"];
    
    
    MYIntroductionPanel *panelCredits= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"Credits" description:@"Original author:    Project Manager:    Website/Forum:\nWhales (retired)    KevinGranade        GlyphGryph\n\nCurrent Main Developers/Github Managers:\nKevinGranade, Rivet-the-Zombie, BevapDin, Coolthulu, i2amroy\n\nCataclysm:Dark Days Ahead is the result of contributions from over 400 volunteers. You can download free desktop versions of Cataclysm: Dark Days Ahead at http://en.cataclysmdda.com\n\nFor a full list of contributors please see:\nhttps://github.com/CleverRaven/Cataclysm-DDA/contributors\nCataclysm: Dark Days Ahead is released under CC-BY-SA 3.0." image:nil];
    
    
    MYIntroductionPanel *panelChangeLanguage= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Change Language" description:@"Go to Options->Interface->Language to change language." video:@"ChangeLanguage"];
    
    MYIntroductionPanel *panelChangeTileSet= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"How To Change Tileset" description:@"Go to Options->Interface->Graphics->Choose tileset to change tileset." video:@"ChangeTileset"];
    
    MYIntroductionPanel *panelBeta1= [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) title:@"About iOS Version" description:@"This iOS version is brought you by Dancing Bottle.\n\nPlease report iOS version specific bugs/issues in the forum at http://dancingbottle.com" image:nil];
    
    
    //[introductionView setBackgroundColor:[UIColor blackColor]];
    
    [introductionView buildIntroductionWithPanels:@[ //panelStory1,
                                                     //panelStory2,
                                                     //panelStory3,
                                                     //panelStory4,
                                                     //panelStory5,
                                                     //panelTitle,
                                                     panelControlActionButtons,
                                                     panelControlTabButtons,
                                                     panelControlDPad,
                                                     panelGesturesSwipeUpAndDown,
                                                     panelGesturesLongPress,
                                                     panelGesturesSwipeRight,
                                                     panelGesturesSwipeLeft,
                                                     panelGesturesPinch,
                                                     panelGesturesPause,
                                                     panelGesturesDoubleSwipe,
                                                     panelGesturesTripleSwipe,
                                                     panelChangeLanguage,
                                                     panelChangeTileSet,
                                                     panelCredits,
                                                     panelBeta1 ]];
    [self.view addSubview:introductionView];

}



#pragma mark - MYIntroductionDelegate Methods
-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType
{
    [self doVolumeFade1];
    
    
    [soundPlayer play];
    
    //[self doVolumeFade2];
    
    SDL_WindowData *data = self->window->driverdata;
    SDL_VideoDisplay *display = SDL_GetDisplayForWindow(self->window);
    SDL_DisplayModeData *displaymodedata = (SDL_DisplayModeData *) display->current_mode.driverdata;
    const CGSize size = data->view.bounds.size;
    int w, h;
    
    w = (int)(size.width * displaymodedata->scale);
    h = (int)(size.height * displaymodedata->scale);
    
    SDL_SendWindowEvent(self->window, SDL_WINDOWEVENT_EXPOSED, w, h);
    

    keyboardDetectionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                            selector:@selector(keyboardDetectionEvent:) userInfo:nil repeats:YES];
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex
{
    
}

-(void)didPressBuyButton
{
    NSLog( @"[didPressBuyButton]" );
    
    uint32_t index = arc4random_uniform(16) + 1;
    NSString*  soundFile =  [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"zombie-%d", index] ofType:@"mp3"];
    NSURL* fileURL = [[NSURL alloc] initFileURLWithPath:soundFile ];
    zombieSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    zombieSoundPlayer.numberOfLoops = 0;
    [zombieSoundPlayer play];
    
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:@"Buy high quality & immersive sound pack?" message:nil buttonTitles:@[@"Buy Sound Pack", @"Restore Purchase"] buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel];

    
    NSArray *sections = @[section1, cancelSection];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        //NSLog( @"%d %d", indexPath.section, indexPath.row );
        if( 0 == indexPath.section )
        {
            if( 0 == indexPath.row )
            {
                iapAction = IAP_BUY;
                //[[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:
                    /*kInAppPurchseIdentifierAwesomeSoundPack*/
                //    kInAppPurchseIdentifierBasicSoundPack
                // ];
                
                NSSet *products = [NSSet setWithArray:@[kInAppPurchseIdentifierAwesomeSoundPack]];
                [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
                    NSLog( @"Found products:" );
                    for( SKProduct* product in products )
                    {
                        NSLog( @"%@", product.productIdentifier);
                        [[RMStore defaultStore] addPayment:product.productIdentifier success:^(SKPaymentTransaction *transaction) {
                            NSLog(@"Product purchased");
                        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                            NSLog(@"Something went wrong");
                        }];
                    }
                    
                    NSLog( @"Invalid product identifiers:" );
                    for( NSString* invalidProductIdentifier in invalidProductIdentifiers )
                    {
                        NSLog( @"%@", invalidProductIdentifier );
                    }
                    
                    //NSLog(@"Products loaded");
                } failure:^(NSError *error) {
                    NSLog(@"Something went wrong");
                }];
                
                hud.labelText = @"Purchasing item";

            }
            else if( 1 == indexPath.row )
            {
                iapAction = IAP_RESTORE;
                
                
                NSSet *products = [NSSet setWithArray:@[kInAppPurchseIdentifierAwesomeSoundPack]];
                [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
                    NSLog( @"Found products:" );
                    for( SKProduct* product in products )
                    {
                        NSLog( @"%@", product.productIdentifier);
                        [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
                            NSLog(@"Transactions restored");
                        } failure:^(NSError *error) {
                            NSLog(@"Something went wrong");
                        }];
                    }
                    
                    NSLog( @"Invalid product identifiers:" );
                    for( NSString* invalidProductIdentifier in invalidProductIdentifiers )
                    {
                        NSLog( @"%@", invalidProductIdentifier );
                    }
                    
                    //NSLog(@"Products loaded");
                } failure:^(NSError *error) {
                    NSLog(@"Something went wrong");
                }];
                
                
                hud.labelText = @"Restoring item";
            }
            hud.mode = MBProgressHUDModeText;
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            //[banker fetchProducts:@[/*kInAppPurchseIdentifierBasicSoundPack/*,*/kInAppPurchseIdentifierAwesomeSoundPack]];
        }
        [sheet dismissAnimated:YES];
    }];
    
    [sheet showInView:self.view animated:YES];
    
#if 0
    DQAlertView * alertView;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if( [defaults objectForKey:@"SoundPackPurchased"] == nil )
    {
        alertView = [[DQAlertView alloc] initWithTitle:@"Buy Sound Pack" message:@"Buy sound pack with high quality and immersive sound effects?" cancelButtonTitle:@"Cancel" otherButtonTitle:@"OK"];
    }
    else
    {
        if( [defaults boolForKey:@"SoundPackPurchased"] == YES )
        {
            alertView = [[DQAlertView alloc] initWithTitle:@"Install Sound Pack" message:@"Restore the sound pack you have purchased before?" cancelButtonTitle:@"Cancel" otherButtonTitle:@"OK"];
        }
        else
        {
            alertView = [[DQAlertView alloc] initWithTitle:@"Buy Sound Pack" message:@"Buy sound pack with high quality and immersive sound effects?" cancelButtonTitle:@"Cancel" otherButtonTitle:@"OK"];
        }
    }
    
    

    alertView.cancelButtonAction = ^{
        NSLog(@"Cancel Clicked");
        introductionView.userInteractionEnabled = YES;
    };
    alertView.otherButtonAction = ^{
        NSLog(@"OK Clicked");
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Fetching product information";
        [banker fetchProducts:@[/*kInAppPurchseIdentifierBasicSoundPack,*/kInAppPurchseIdentifierAwesomeSoundPack]];
    };
//    [self.view addSubview:alertView];
    introductionView.userInteractionEnabled = NO;
    [alertView showInView:self.view];
#endif
}



- (NSURL*)applicationDataDirectory {
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* appSupportDir = nil;
    NSURL* appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir) {
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleID];
    }
    
    return appDirectory;
}



# pragma mark - RMStore notifications
// Products request notifications
- (void)storeProductsRequestFailed:(NSNotification*)notification
{
    NSError *error = notification.rm_storeError;
    NSLog( @"[storeProductsRequestFailed]" );
}

- (void)storeProductsRequestFinished:(NSNotification*)notification
{
    NSArray *products = notification.rm_products;
    NSArray *invalidProductIdentifiers = notification.rm_invalidProductIdentifiers;
    NSLog( @"[storeProductsRequestFinished]" );
}

// Payment transaction notifications

- (void)storePaymentTransactionFinished:(NSNotification*)notification
{
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    NSLog( @"[storePaymentTransactionFinished]" );
}

- (void)storePaymentTransactionFailed:(NSNotification*)notification
{
    NSError *error = notification.rm_storeError;
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    NSLog( @"[storePaymentTransactionFailed]" );
    [hud hide:YES];
}

// iOS 8+ only

- (void)storePaymentTransactionDeferred:(NSNotification*)notification
{
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    NSLog( @"[storePaymentTransactionDeferred]" );
    [hud hide:YES];
}

// Restore transactions notifications
- (void)storeRestoreTransactionsFailed:(NSNotification*)notification;
{
    NSError *error = notification.rm_storeError;
    NSLog( @"[storeRestoreTransactionsFailed]" );
    [hud hide:YES];
}

- (void)storeRestoreTransactionsFinished:(NSNotification*)notification
{
    NSArray *transactions = notification.rm_transactions;
    NSLog( @"[storeRestoreTransactionsFinished]" );
    [hud hide:YES];
}

// Download notifications
- (void)storeDownloadFailed:(NSNotification*)notification
{
    SKDownload *download = notification.rm_storeDownload; // Apple-hosted only
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    NSError *error = notification.rm_storeError;
    
    if ( self.view != [hud superview] )
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Download failed.";
    [hud hide:YES afterDelay:3];
}

- (void)storeDownloadFinished:(NSNotification*)notification;
{
    SKDownload *download = notification.rm_storeDownload; // Apple-hosted only
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    NSLog( @"[storeDownloadFinished] %@", productIdentifier );
    
    NSError* e;

    //NSLog( @"%@", [download.contentURL path] );
    NSString* destPath = [[self applicationDataDirectory] path];
    BOOL isDir = NO;
    
    if( ![[NSFileManager defaultManager] fileExistsAtPath:destPath  isDirectory:&isDir] )
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:destPath withIntermediateDirectories:YES attributes:nil error:&e];
        if( e )
            NSLog(@"%@", [e localizedDescription]);
    }
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:[destPath stringByAppendingPathComponent:@"sound"] isDirectory:&isDir] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:[destPath stringByAppendingPathComponent:@"sound"] error:&e];
        if( e )
            NSLog(@"%@", [e localizedDescription]);
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:[[download.contentURL path] stringByAppendingPathComponent:@"Contents/sound"] toPath:[destPath stringByAppendingPathComponent:@"sound"] error:&e];
    if( e )
        NSLog(@"%@", [e localizedDescription]);
    
    
    


    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"SoundPackPurchased"];
    [defaults setObject:download.contentIdentifier forKey:@"SoundPackIdentifier"];
    [defaults setObject:download.contentVersion forKey:@"SoundPackVersion"];
    [defaults synchronize];


    
    
    if ( self.view != [hud superview] )
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Thanks for your support";
    [hud hide:YES afterDelay:3];
}

- (void)storeDownloadUpdated:(NSNotification*)notification
{
    SKDownload *download = notification.rm_storeDownload; // Apple-hosted only
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    float progress = notification.rm_downloadProgress;
    NSLog( @"[storeDownloadUpdated] %f", progress );

    if ( self.view != [hud superview] )
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.labelText = [NSString stringWithFormat:@"Sound pack %d%% downloaded", (int)(download.progress * 100.0f)] ;
    hud.progress = download.progress;
}

- (void)storeDownloadCanceled:(NSNotification*)notification
{
    SKDownload *download = notification.rm_storeDownload;
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    
    if ( self.view != [hud superview] )
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Download cancelled";
    [hud hide:YES afterDelay:3];
}

- (void)storeDownloadPaused:(NSNotification*)notification
{
    SKDownload *download = notification.rm_storeDownload;
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
}

- (void)storeRefreshReceiptFailed:(NSNotification*)notification;
{
    NSError *error = notification.rm_storeError;
}

- (void)storeRefreshReceiptFinished:(NSNotification*)notification
{
    
}

- (void) keyboardDetectionEvent:(NSTimer *)incomingTimer
{
    if( [aTextField isFirstResponder] )
        return;
    //NSLog(@"Inside updateActivityIndicator method");
    if( !SDL_IsScreenKeyboardShown( SDL_GetFocusWindow() ) )
    {

        if( YES == detectionFlag )
        {
            if( NO == keyboardConnected )
            {
                NSLog( @"keyboard connected" );
                keyboardConnected = YES;
                
                [aTextField becomeFirstResponder];
                
                if ( self.view != [hud superview] )
                {
                    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                }
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"External keyboard detected. On screen controls will be disabled.";
                [hud hide:YES afterDelay:3];
                
                [dPad removeFromSuperview];
                [yesButton removeFromSuperview];
                [noButton removeFromSuperview];
                [nextButton removeFromSuperview];
                [prevButton removeFromSuperview];
                [tabButton removeFromSuperview];
            }
            
            keyboardConnected = YES;
        }
        else
        {
            if( YES == keyboardConnected )
            {
                NSLog( @"keyboard disconnected" );
                keyboardConnected = NO;
                
                if ( self.view != [hud superview] )
                {
                    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                }
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"External keyboard disconnected.";
                [hud hide:YES afterDelay:3];
                
                [self.view addSubview:dPad];
                [self.view addSubview:yesButton];
                [self.view addSubview:noButton];
                [self.view addSubview:nextButton];
                [self.view addSubview:prevButton];
                [self.view addSubview:tabButton];
            }
            detectionFlag = YES;
        }
        
        [detectionTextField becomeFirstResponder];
    }
    //[detectionTextField resignFirstResponder];
}

// UIKeyboardWillShowNotification
- (void)keyboardWillShow:(NSNotification *)notification {
    //NSLog( @"keyboardWillShow" );
    if( [detectionTextField isFirstResponder] )
    {
        detectionFlag = NO;
        [detectionTextField resignFirstResponder];
    }
}



- (NSArray *)keyCommands {
    if(!_commands) {
        _keyCommandsTranslator = @{UIKeyInputUpArrow: @"UP",
                                   UIKeyInputDownArrow: @"DOWN",
                                   UIKeyInputLeftArrow: @"LEFT",
                                   UIKeyInputRightArrow: @"RIGHT",
                                   UIKeyInputEscape: @"\033"};
        
        NSArray *keys = [[NSArray alloc] initWithObjects:
                         @">", @"<", @" ", @"\\",
                         @"]", @"?", @"~",  @"&",
                         @"\r", @"\t", @".", @"@", @"%", @"!", @"^", @"/",
                         nil];
        
        _commands = [[NSMutableArray alloc] init];
        
        for(char i = 'a'; i <= 'z'; i++) {
            NSString *key = [NSString stringWithFormat:@"%c", i];
            [_commands addObject:[UIKeyCommand keyCommandWithInput:key modifierFlags:0 action:@selector(executeKeyCommand:)]];
            [_commands addObject:[UIKeyCommand keyCommandWithInput:key modifierFlags:UIKeyModifierShift action:@selector(executeKeyCommand:)]];
        }
        
        for(char i = '0'; i <= '9'; i++) {
            NSString *key = [NSString stringWithFormat:@"%c", i];
            [_commands addObject:[UIKeyCommand keyCommandWithInput:key modifierFlags:0 action:@selector(executeKeyCommand:)]];
        }
        
        for(id key in keys) {
            [_commands addObject:[UIKeyCommand keyCommandWithInput:key modifierFlags:0 action:@selector(executeKeyCommand:)]];
        }
        
        for(NSString *key in _keyCommandsTranslator) {
            [_commands addObject:[UIKeyCommand keyCommandWithInput:key modifierFlags:0 action:@selector(executeKeyCommand:)]];
        }
    }
    return _commands;
}

- (void)executeKeyCommand:(UIKeyCommand *)keyCommand {
    NSString *key;
    
    if(keyCommand.modifierFlags == UIKeyModifierShift) {
        if([keyCommand.input length] == 1
           && [keyCommand.input characterAtIndex:0] >= 'a'
           && [keyCommand.input characterAtIndex:0] <= 'z') {
            key = [keyCommand.input uppercaseString];
        }
    } else {
        key = [_keyCommandsTranslator objectForKey:keyCommand.input];
        if(key == nil) {
            key = keyCommand.input;
        }
    }
    
    if(key) {
        if( [key compare:@"\033"] == NSOrderedSame )
        {
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_ESCAPE );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_ESCAPE );
        }
        else if( [key compare:@"\015"] == NSOrderedSame )
        {
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_RETURN );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_RETURN );
        }
        else if( [key compare:@"\t"] == NSOrderedSame )
        {
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_TAB );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_TAB );
        }

        else if( [key compare:@"UP"] == NSOrderedSame )
        {
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_UP );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_UP );
        }
        else if( [key compare:@"DOWN"] == NSOrderedSame )
        {
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_DOWN );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_DOWN );
        }
        else if( [key compare:@"LEFT"] == NSOrderedSame )
        {
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_LEFT );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_LEFT );
        }
        else if( [key compare:@"RIGHT"] == NSOrderedSame )
        {
            SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_RIGHT );
            SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_RIGHT );
        }
        else
            SDL_SendKeyboardText( [key cStringUsingEncoding:NSUTF8StringEncoding] );
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if( !keyboardConnected )
        return NO;
    
    const char *_char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSInteger isBackSpace = strcmp(_char, "\b");
    
    if (isBackSpace == -8) {
        // is backspace
        SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_BACKSPACE );
        SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_BACKSPACE );

        
    }
    else if([string isEqualToString:@"\n"]) {
        //[textField resignFirstResponder];
        // enter
        SDL_SendKeyboardKey( SDL_PRESSED, SDL_SCANCODE_RETURN );
        SDL_SendKeyboardKey( SDL_RELEASED, SDL_SCANCODE_RETURN );
    }
    else {
        // misc
        SDL_SendKeyboardText( [string cStringUsingEncoding:NSUTF8StringEncoding] );
    }
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField*)_textField
{
    SDL_SendKeyboardKey(SDL_PRESSED, SDL_SCANCODE_RETURN);
    SDL_SendKeyboardKey(SDL_RELEASED, SDL_SCANCODE_RETURN);
    return NO;
}



-(void)startRecording
{
    
    optionsButton.backgroundImage = [UIImage imageNamed:@"options_gold_on"];
    optionsButton.backgroundImagePressed = [UIImage imageNamed:@"options_gold_off"];
    
    RPScreenRecorder *recorder = [RPScreenRecorder sharedRecorder];
    if (!recorder.available) {
        NSLog(@"recorder is not available");
        return;
    }
    if (recorder.recording) {
        NSLog(@"it is recording");
        return;
    }
    [recorder startRecordingWithMicrophoneEnabled:YES handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"start recorder error - %@",error);
        }
        //[self.startBtn setTitle:@"Recording" forState:UIControlStateNormal];
    }];
}

-(void)stopRecording
{
    optionsButton.backgroundImage = [UIImage imageNamed:@"options_silver_on"];
    optionsButton.backgroundImagePressed = [UIImage imageNamed:@"options_silver_off"];
    
    RPScreenRecorder *recorder = [RPScreenRecorder sharedRecorder];
    if (!recorder.recording) {
        return;
    }
    
    
    
    [recorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        if (error) {
            NSLog(@"stop error - %@",error);
        }
        
        previewViewController.previewControllerDelegate = self;
        
        [self presentViewController:previewViewController animated:YES completion:^{
            NSLog(@"complition");
        }];
    }];
}

- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController
{
    
    [previewController dismissViewControllerAnimated:YES completion:nil];
}

/* @abstract Called when the view controller is finished and returns a set of activity types that the user has completed on the recording. The built in activity types are listed in UIActivity.h. */
- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes
{
    NSLog(@"activity - %@",activityTypes);
}


-(void)adjustUI
{
    dPad.isModifying = YES;
    yesButton.isModifying = YES;;
    noButton.isModifying = YES;;
    nextButton.isModifying = YES;;
    prevButton.isModifying = YES;;
    //dPad.panGestureRecognizer.enabled = YES;
    
    uiBlickTimer = [NSTimer scheduledTimerWithTimeInterval:0.333 target:self
                                                  selector:@selector(blinkUI:) userInfo:nil repeats:YES];
}

- (void) blinkUI:(NSTimer *)timer
{
    static BOOL isHidden = NO;
    
    isHidden = isHidden ? NO : YES;
    
    if( isHidden )
    {
        if( self.selectedUI )
            [self.selectedUI setAlpha:0.05f];
        optionsButton.backgroundImage = [UIImage imageNamed:@"options_gold_off"];
    }
    else
    {
        if( self.selectedUI )
            [self.selectedUI setAlpha:0.3f];
        optionsButton.backgroundImage = [UIImage imageNamed:@"options_gold_on"];
    }
    
}

- (void)setCurrentSelectedUI:(UIView*)selected;
{
    if( self.selectedUI )
    {
        [self.selectedUI setAlpha:0.3f];
        if( [self.selectedUI isKindOfClass:[JSDPad class]] )
        {
            JSDPad* ui = (JSDPad*)self.selectedUI;
            ui.panGestureRecognizer.enabled = NO;
        }
        else if( [self.selectedUI isKindOfClass:[JSButton class]] )
        {
            JSButton* ui = (JSButton*)self.selectedUI;
            ui.panGestureRecognizer.enabled = NO;
        }
    }
    
    self.selectedUI = selected;
    if( [self.selectedUI isKindOfClass:[JSDPad class]] )
    {
        JSDPad* ui = (JSDPad*)self.selectedUI;
        ui.panGestureRecognizer.enabled = YES;
    }
    else if( [self.selectedUI isKindOfClass:[JSButton class]] )
    {
        JSButton* ui = (JSButton*)self.selectedUI;
        ui.panGestureRecognizer.enabled = YES;
    }
}

- (UIView*) getCurrentSelectedUI
{
    if( self.selectedUI )
        return self.selectedUI;
    else
        return nil;
}


-(void)askIfAdjustUI
{
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:@"Adjust Interface" message:nil buttonTitles:@[@"Modify", @"Reset"] buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel];
    
    
    NSArray *sections = @[section1, cancelSection];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath)
    {
        if( 0 == indexPath.section )
        {
            if( 0 == indexPath.row )
            {
                isModifyingUI = YES;
                [self adjustUI];
                
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"Tap: Select. Drag/Pinch: Adjust. OPTIONS: Confirm.";
                                //@"Drag or pinch to adjust UI. Tap OPTIONS to confirm."
                [hud hide:YES afterDelay:5];
                
            }
            else if( 1 == indexPath.row )
            {
                
            }
        }
        [sheet dismissAnimated:YES];
    }];
    
    [sheet showInView:self.view animated:YES];
}

@end

#endif /* SDL_VIDEO_DRIVER_UIKIT */

/* vi: set ts=4 sw=4 expandtab: */
