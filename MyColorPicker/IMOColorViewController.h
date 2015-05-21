//
//  IMOColorViewController.h
//  testTwitter
//
//  Created by imokhles on 28/01/15.
//  Copyright (c) 2015 iMokhles. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import "DevLibPREFS.h"
#import <MessageUI/MessageUI.h>
#import "UIColor+extensions.h"
#import "ColorHelper/RSColorPickerView.h"
#import "ColorHelper/RSColorFunctions.h"
#import "ColorHelper/RSColorPickerState.h"

#import "ColorHelper/RSBrightnessSlider.h"
#import "ColorHelper/RSOpacitySlider.h"


#define kTweakName_Key @"DevelopersLib"

typedef NS_ENUM(NSInteger, CPickerBlurEffectStyle) {
    CPickerBlurEffectStyleExtraLight,
    CPickerBlurEffectStyleLight,
    CPickerBlurEffectStyleDark
};

@interface IMOColorViewController : PSViewController <RSColorPickerViewDelegate, UIAlertViewDelegate> {
	UIView *colorChip;
}
@property (nonatomic, assign) CPickerBlurEffectStyle blurEffectStyle;
@property (nonatomic, strong) RSColorPickerView *colorPicker;
@property (nonatomic, strong) RSBrightnessSlider *brightnessSlider;
@property (nonatomic, strong) RSOpacitySlider *opacitySlider;
@property (nonatomic, assign) NSString *tweakDefaults;
@property (nonatomic, assign) NSString *tweakKillAppName;
@property (nonatomic, assign) NSString *cellKey;
@property (nonatomic, assign) NSString *callNotification;
@end
