//
//  IMOColorViewController.m
//  testTwitter
//
//  Created by imokhles on 28/01/15.
//  Copyright (c) 2015 iMokhles. All rights reserved.
//

#import "IMOColorViewController.h"

@interface IMOColorViewController () {
    UIColor *fixColor;
}
@property (nonatomic, strong) UIView *CPickerBlurView;
@end

@implementation IMOColorViewController
@synthesize colorPicker;
- (id)init {
    self = [super init];
    if (self) {
        // additional view controller initialization
        if([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
            [self setEdgesForExtendedLayout:UIRectEdgeBottom];
        }
        self.blurEffectStyle = CPickerBlurEffectStyleDark;
        /******* blur effect ********/
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:(UIBlurEffectStyle)self.blurEffectStyle];
        self.CPickerBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [self.view addSubview:self.CPickerBlurView];
    }
    
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    colorChip = [[UIView alloc] init];
    colorChip.layer.borderColor = [UIColor whiteColor].CGColor;
    colorChip.layer.borderWidth = 3.0f;
    [self.view addSubview:colorChip];

    UIBarButtonItem *changetypeBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshType)];
    UIBarButtonItem *optionsBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(moreOptions)];
    UIBarButtonItem *composeBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeAction)];

    // self.navigationItem.rightBarButtonItem = changetypeBtn;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:changetypeBtn, optionsBtn, composeBtn, nil]];

    CGRect colorPickerFrame;
    if (IS_IPAD) {
        colorPickerFrame = CGRectMake(5, 71, self.view.frame.size.width-10, self.view.frame.size.width-10);
    } else {
        colorPickerFrame = CGRectMake(5, 71, self.view.frame.size.width-10, self.view.frame.size.width-10);
    }
    colorPicker = [[RSColorPickerView alloc] initWithFrame:colorPickerFrame];
    [colorPicker setDelegate:self];
    [self.view addSubview:colorPicker];

    _brightnessSlider = [[RSBrightnessSlider alloc] initWithFrame:CGRectMake(5, colorPicker.bounds.size.height+80, self.view.frame.size.width-10, 30)];
    [_brightnessSlider setColorPicker:colorPicker];
    [self.view addSubview:_brightnessSlider];

    if (IS_IPAD) {
            _brightnessSlider.frame = CGRectMake(5, colorPicker.bounds.size.height+80, self.view.frame.size.width-10, 30);
    }
    // View that controls opacity
    _opacitySlider = [[RSOpacitySlider alloc] initWithFrame:CGRectMake(5, colorPicker.bounds.size.height+120, self.view.frame.size.width-10, 30)];
    [_opacitySlider setColorPicker:colorPicker];
    [self.view addSubview:_opacitySlider];

    if (IS_IPAD) {
            _opacitySlider.frame = CGRectMake(5, colorPicker.bounds.size.height+120, [UIScreen mainScreen].bounds.size.width-10, 30);
    }
    NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.tweakDefaults]];
    if(!self.cellKey) {
        fixColor = [UIColor colorWithHex:@"#1d2225"];
        NSString *hexColor = [UIColor hexFromColor:fixColor];
        colorChip.backgroundColor = [UIColor colorWithHex:hexColor];
        self.view.backgroundColor = fixColor;
        NSMutableDictionary *mutableDict = tweakSettings ? [tweakSettings mutableCopy] : [NSMutableDictionary dictionary];
        [mutableDict setObject:hexColor forKey:self.cellKey];
        [mutableDict writeToFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.tweakDefaults] atomically:YES];
    } else {
        NSString *currentValue = tweakSettings[self.cellKey];
        NSNumber *currentCircleValue = tweakSettings[@"cropToCircle_key"];
        colorChip.backgroundColor = [UIColor colorWithHex:currentValue];
        self.view.backgroundColor = [UIColor colorWithHex:currentValue];
        colorPicker.hexValue = currentValue;
        [colorPicker setSelectionColor:self.view.backgroundColor quiet:YES];
        [colorPicker setCropToCircle:[currentCircleValue boolValue]];
    }
    self.navigationController.navigationBar.translucent = NO;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // self.navigationController.navigationBar.translucent = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Colors";

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.CPickerBlurView.frame = self.view.bounds;
    colorChip.frame = CGRectMake(5, 10, self.view.frame.size.width-10, 50);
    if (IS_IPAD) {
        colorChip.frame = CGRectMake(5, 10, self.view.frame.size.width-10, 50);
    }
    [self.view insertSubview:colorPicker aboveSubview:self.CPickerBlurView];
    [self.view insertSubview:colorChip aboveSubview:self.CPickerBlurView];
    [self.view insertSubview:_brightnessSlider aboveSubview:self.CPickerBlurView];
    [self.view insertSubview:_opacitySlider aboveSubview:self.CPickerBlurView];
}
#pragma mark - RSColorPickerView delegate methods

- (void)moreOptions {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"More Options" message:@"Choose one of those colors" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"White", @"Black", @"Red", @"Blue", @"Green", nil];
    [alertView show];
}
- (void)composeAction {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"More Options" message:@"Copy color value or set one" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Copy", @"Set Color", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setText:[UIColor hexFromColor:self.view.backgroundColor]];
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Cancel"]) {
         NSLog(@"Cancelled");
    }
    if ([title isEqualToString:@"White"]) {
         [colorPicker setSelectionColor:[UIColor whiteColor]];
    }
    if ([title isEqualToString:@"Black"]) {
         [colorPicker setSelectionColor:[UIColor blackColor]];
    }
    if ([title isEqualToString:@"Red"]) {
         [colorPicker setSelectionColor:[UIColor redColor]];
    }
    if ([title isEqualToString:@"Blue"]) {
         [colorPicker setSelectionColor:[UIColor blueColor]];
    }
    if ([title isEqualToString:@"Green"]) {
         [colorPicker setSelectionColor:[UIColor greenColor]];
    }
    if ([title isEqualToString:@"Copy"]) {
         [[UIPasteboard generalPasteboard] setString:[UIColor hexFromColor:self.view.backgroundColor]];
    }
    if ([title isEqualToString:@"Set Color"]) {
        if ([[alertView textFieldAtIndex:0].text hasPrefix:@"#"] && [UIColor colorWithHex:[alertView textFieldAtIndex:0].text]) {
            [colorPicker setSelectionColor:[UIColor colorWithHex:[alertView textFieldAtIndex:0].text]];
        }
    }
}
- (void)refreshType {
    NSMutableDictionary *preferencesDict = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.tweakDefaults]];
    if (colorPicker.cropToCircle) {
        colorPicker.cropToCircle = NO;
        [preferencesDict setObject:[NSNumber numberWithBool:NO] forKey:@"cropToCircle_key"];
    } else {
        colorPicker.cropToCircle = YES;
        [preferencesDict setObject:[NSNumber numberWithBool:YES] forKey:@"cropToCircle_key"];
    }
    [preferencesDict writeToFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.tweakDefaults] atomically:YES];
}

- (void)colorPickerDidChangeSelection:(RSColorPickerView *)cp {
    NSString *hexColor;
    UIColor *color = [cp selectionColor];
    colorChip.backgroundColor = color;
    self.view.backgroundColor = color;
    _brightnessSlider.value = [cp brightness];
    _opacitySlider.value = [cp opacity];
    NSMutableDictionary *preferencesDict = [NSMutableDictionary dictionary];
    [preferencesDict addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.tweakDefaults]]];
    hexColor = [UIColor hexFromColor:color];
    [preferencesDict setObject:hexColor forKey:self.cellKey];
    [preferencesDict writeToFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.tweakDefaults] atomically:YES];
    NSString *colorExisteValue = preferencesDict[self.cellKey];
    if (self.callNotification && ![hexColor isEqualToString:colorExisteValue]) {
        CFStringRef colorPickerNotiPost = (CFStringRef)CFBridgingRetain(self.callNotification);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), colorPickerNotiPost, NULL, NULL, YES);
    }
    if (self.tweakKillAppName) {
        NSString *cmd = [NSString stringWithFormat:@"killall '%@'", self.tweakKillAppName];
        system([cmd UTF8String]);
    }
}

@end
