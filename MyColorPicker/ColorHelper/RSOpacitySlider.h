//
//  RSOpacitySlider.h
//  RSColorPicker
//
//  Created by Jared Allen on 5/16/13.
//  Copyright (c) 2013 Red Cactus LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSColorPickerView.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-no-attribute"

@interface RSOpacitySlider : UISlider

@property (nonatomic) RSColorPickerView *colorPicker;

@end
#pragma clang diagnostic pop