//
//  customColorPicker.h
//  ColorPicker
//
//  Created by Brian Olencki on 4/28/15.
//  Copyright (c) 2015 bolencki13. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface customColorPicker : UIView <UITextFieldDelegate> {
    UIView *mainView;
    
    UIView *colorView;
    UISlider *sdrColor;
    UITextField *txtHex;
    UIView *alphaBrowser;
    
    NSString *hexColor;
    
    NSUserDefaults *prefs;
    CGPoint alphaCenter;
}
- (NSString*)getColorText;
- (UIColor*)getColorUIColor;
#define BUNDLE_ID (@"com.bolencki13.musicbutton")
#define SCREEN ([UIScreen mainScreen].bounds)
#define VIEW (mainView.frame)
@end
