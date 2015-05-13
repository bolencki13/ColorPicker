//
//  customColorPicker.m
//  ColorPicker
//
//  Created by Brian Olencki on 4/28/15.
//  Copyright (c) 2015 bolencki13. All rights reserved.
//
#import "customColorPicker.h"

static const float stepper = 0.02;//used for lightening/darkenign a color by x amount

@implementation customColorPicker
- (id)init {
    self = [super init];
    if (self) {
        self.frame = SCREEN;
        prefs = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];

        UIView *blur = [[UIView alloc] initWithFrame:SCREEN];
        blur.backgroundColor = [UIColor darkGrayColor];
        blur.alpha = 0.85;
        [self addSubview:blur];
        
        [self createMainView];
        
    }
    return  self;
}

#pragma mark - Creation
- (void)createMainView {
    mainView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN.size.width-300)/2, 60, 300, 320)];
    mainView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1];
    mainView.layer.cornerRadius = 10;
    mainView.layer.borderWidth = 0.5;
    mainView.layer.borderColor = [UIColor blackColor].CGColor;
    [self addSubview:mainView];
    
    sdrColor = [[UISlider alloc] initWithFrame:CGRectMake(20, VIEW.size.height-80, VIEW.size.width-40, 20)];
    [sdrColor addTarget:self action:@selector(colorSlider:) forControlEvents:UIControlEventValueChanged];
    [sdrColor setBackgroundColor:[UIColor clearColor]];
    sdrColor.minimumValue = 0.0;
    sdrColor.maximumValue = 125;//16,777,215 possible color options
    sdrColor.value = [prefs integerForKey:@"sliderValue"];
    
    [mainView addSubview:sdrColor];
    
    UITapGestureRecognizer *sliderTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
    [sdrColor addGestureRecognizer:sliderTapGesture];
    
    txtHex = [[UITextField alloc] initWithFrame:CGRectMake(20, VIEW.size.height-50, VIEW.size.width-120, 30)];
    txtHex.placeholder = hexColor;
    txtHex.textAlignment = NSTextAlignmentCenter;
    txtHex.backgroundColor = [UIColor whiteColor];
    txtHex.layer.borderColor = [UIColor lightGrayColor].CGColor;
    txtHex.layer.borderWidth = 0.5;
    txtHex.layer.cornerRadius = 3;
    txtHex.textColor = [UIColor grayColor];
    txtHex.returnKeyType = UIReturnKeyDone;
    txtHex.delegate = self;
    
    txtHex.layer.shadowOpacity = 0.3;
    txtHex.layer.shadowRadius = 2.0;
    txtHex.layer.shadowColor = [UIColor blackColor].CGColor;
    txtHex.layer.shadowOffset = CGSizeMake(0.0, 3.0);
    [mainView addSubview:txtHex];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    label.text = @"  #";
    [label sizeToFit];
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor whiteColor];
    txtHex.leftViewMode = UITextFieldViewModeAlways;
    txtHex.leftView = label;

    float width = 30;
    
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnConfirm addTarget:self action:@selector(confirmColor) forControlEvents:UIControlEventTouchUpInside];
    [btnConfirm setTitle:@"√" forState:UIControlStateNormal];
    [btnConfirm setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    btnConfirm.frame = CGRectMake(VIEW.size.width-width-width-20-10, VIEW.size.height-50, width, width);
    btnConfirm.layer.cornerRadius = width/2;
    btnConfirm.backgroundColor = [UIColor whiteColor];
    btnConfirm.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btnConfirm.layer.borderWidth = 0.5;
    btnConfirm.layer.shadowOpacity = 0.3;
    btnConfirm.layer.shadowRadius = 2.0;
    btnConfirm.layer.shadowColor = [UIColor blackColor].CGColor;
    btnConfirm.layer.shadowOffset = CGSizeMake(0.0,3.0);
    [mainView addSubview:btnConfirm];
    
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnExit addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    [btnExit setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnExit setTitle:@"X" forState:UIControlStateNormal];
    btnExit.frame = CGRectMake(VIEW.size.width-width-20, VIEW.size.height-50, width, width);
    btnExit.backgroundColor = [UIColor whiteColor];
    btnExit.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btnExit.layer.borderWidth = 0.3;
    btnExit.layer.cornerRadius = width/2;
    btnExit.layer.shadowOpacity = 0.3;
    btnExit.layer.shadowRadius = 2.0;
    btnExit.layer.shadowColor = [UIColor blackColor].CGColor;
    btnExit.layer.shadowOffset = CGSizeMake(0.0, 3.0);
    [mainView addSubview:btnExit];
    
    colorView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, VIEW.size.width-40, VIEW.size.height-140)];
    colorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    colorView.layer.borderWidth = 0.3;
    colorView.backgroundColor = [UIColor whiteColor];
    colorView.layer.cornerRadius = 7;
    colorView.layer.masksToBounds = YES;
    [mainView addSubview:colorView];
    
    alphaCenter = CGPointFromString([prefs objectForKey:@"alphaCord"]);
    
    UIPanGestureRecognizer *colorAlpha = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(adjustAlpha:)];
    [alphaBrowser addGestureRecognizer:colorAlpha];
    
    [self colorSlider:sdrColor];
}
- (void)createAlphaBrowser {
    
    alphaBrowser = [[UIView alloc] initWithFrame:CGRectMake(25, 25, 20, 20)];
    alphaBrowser.backgroundColor = [UIColor clearColor];
    alphaBrowser.layer.cornerRadius = 20/2;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(20/2,20/2) radius:20/2 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    CAShapeLayer *progressLayer = [[CAShapeLayer alloc] init];
    [progressLayer setPath:bezierPath.CGPath];
    [progressLayer setStrokeColor:[UIColor colorWithWhite:0.5 alpha:1.0].CGColor];
    [progressLayer setFillColor:[UIColor clearColor].CGColor];
    [progressLayer setLineWidth:3.0];
    [progressLayer setStrokeEnd:1.0];
    [alphaBrowser.layer addSublayer:progressLayer];
    [colorView addSubview:alphaBrowser];
    alphaBrowser.center = alphaCenter;
    
    UIPanGestureRecognizer *colorAlpha = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(adjustAlpha:)];
    [alphaBrowser addGestureRecognizer:colorAlpha];
}

#pragma mark - Actions
- (void)colorSlider:(UISlider*)slider {
    [self updateWithColor:[self getColorFromSlider:slider] updatePalet:YES];
}
- (void)sliderTapped:(UIGestureRecognizer *)recognizer {
    UISlider* s = (UISlider*)recognizer.view;
    if (s.highlighted) {
        return; // tap on thumb, let slider deal with it
    }
    CGPoint pt = [recognizer locationInView: s];
    CGFloat percentage = pt.x / s.bounds.size.width;
    CGFloat delta = percentage * (s.maximumValue - s.minimumValue);
    CGFloat value = s.minimumValue + delta;
    [s setValue:value animated:YES];
    [self colorSlider:sdrColor];
}
- (void)adjustAlpha:(UIPanGestureRecognizer*)recognizer {
    static CGPoint originalCenter;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        originalCenter = recognizer.view.center;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translate = [recognizer translationInView:recognizer.view.superview];
        recognizer.view.center = CGPointMake(originalCenter.x + translate.x, originalCenter.y + translate.y);
        /*
        alphaCenter = recognizer.view.center;
        float alpha = [self getAlphaPercent];
        NSLog(@"%f",alpha);
        if (alpha < 0.5) {
            [self updateWithColor:[self lightenColor:[self UIColorwithHexString:txtHex.text alpha:1.0] byX:alpha] updatePalet:NO];
        } else if (alpha == 0.5) {
            [self updateWithColor:[self getColorFromSlider:sdrColor] updatePalet:NO];
        } else if (alpha > 0.5) {
            [self updateWithColor:[self darkenColor:[self UIColorwithHexString:txtHex.text alpha:1.0] byX:alpha] updatePalet:NO];
        }*/
    }
}

#pragma mark - Hex & UIColor & Alpha
- (NSString *)hexStringForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}
- (UIColor *)UIColorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha {
    //-----------------------------------------
    // Convert hex string to an integer
    //-----------------------------------------
    unsigned int hexint = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet
                                       characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexint];
    
    //-----------------------------------------
    // Create color object, specifying alpha
    //-----------------------------------------
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}
- (void)setGradientWithColor:(UIColor*)middleColor {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = colorView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[middleColor CGColor],(id)[[UIColor blackColor] CGColor], nil];
    gradient.startPoint = CGPointMake(0.0, 1.0);
    gradient.endPoint = CGPointMake(1.0, 1.0);
    [colorView.layer addSublayer:gradient];
    gradient.locations = @[@0.0, @0.5, @1.0];
    
    [alphaBrowser removeFromSuperview];
    [self createAlphaBrowser];
}
- (void)setTextFieldWith:(UIColor*)color {
    [txtHex setText:[self hexStringForColor:color]];
}
- (NSString*)intToHex:(int)integer {
    NSString *hex = [[NSString alloc] initWithFormat:@"%02x",integer];
    return hex;
}
- (int)hexToInt:(NSString*)input {
    unsigned int integer = 0;
    NSScanner *scanner = [NSScanner scannerWithString:input];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&integer];
    
    return integer;
}
- (float)getAlphaPercent {
    return alphaCenter.x/colorView.frame.size.width;
}

#pragma mark - Color Modifications
- (void)updateWithColor:(UIColor*)color updatePalet:(BOOL)updatePalet{
    if (updatePalet) {
        [self setGradientWithColor:color];
    }
    [self setTextFieldWith:color];
}
- (UIColor*)darkenColor:(UIColor*)inputColor byX:(float)percent {
    CGFloat r, g, b, a;
    if ([inputColor getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:MAX(r - percent, 0.0)
                               green:MAX(g - (percent/g), 0.0)
                                blue:MAX(b - (percent/b), 0.0)
                               alpha:a];
    }
    return inputColor;
}
- (UIColor*)lightenColor:(UIColor*)inputColor byX:(float)percent {
    CGFloat r, g, b, a;
    if ([inputColor getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:MIN(r + (percent/2/r), 1.0)
                               green:MIN(g + (percent/2/g), 1.0)
                                blue:MIN(b + (percent/2/b), 1.0)
                               alpha:a];
    }
    return inputColor;
}
- (UIColor*)getColorFromSlider:(UISlider*)slider {
    const int blue = slider.minimumValue;
    const int green = slider.maximumValue/5;
    const int yellow = slider.maximumValue/5*2;
    const int orange = slider.maximumValue/5*3;
    const int red = slider.maximumValue/5*4;
    const int purple = slider.maximumValue;
    int value = (int)slider.value;
    UIColor *tempHolder = [UIColor whiteColor];
    float offSet = 0.0;
    float colorSpace = 23;
    
    if (value == blue) {
        tempHolder = [UIColor blueColor];
    } else if (value > blue && value < green) {
        offSet = (value-blue)/colorSpace;
        tempHolder = [UIColor colorWithRed:0.0 green:(0.0+offSet) blue:(1.0-offSet) alpha:1.0];
    } else if (value == green) {
        tempHolder = [UIColor greenColor];
    } else if (value > green && value < yellow) {
        offSet = (value-green)/colorSpace;
        tempHolder = [UIColor colorWithRed:(0.0+offSet) green:1.0 blue:0.0 alpha:1.0];
    } else if (value == yellow) {
        tempHolder = [UIColor yellowColor];
    } else if (value > yellow && value < orange) {
        offSet = (value-yellow)/colorSpace;
        offSet = offSet/2;
        tempHolder = [UIColor colorWithRed:1.0 green:(1.0-offSet) blue:0.0 alpha:1.0];
    } else if (value == orange) {
        tempHolder = [UIColor orangeColor];
    } else if (value > orange && value < red) {
        offSet = (value-orange)/colorSpace;
        offSet = offSet/2;
        tempHolder = [UIColor colorWithRed:1.0 green:(0.502-offSet) blue:0.0 alpha:1.0];
    } else if (value == red) {
        tempHolder = [UIColor redColor];
    } else if (value > red && value < purple) {
        offSet = (value-red)/colorSpace;
        tempHolder = [UIColor colorWithRed:1.0 green:0.0 blue:(0.0+offSet) alpha:1.0];
    } else if (value == purple) {
        tempHolder = [UIColor magentaColor];
    }
    
    return tempHolder;
}

#pragma mark - Saving & Recalling
- (void)saveUIColor:(UIColor*)color {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [prefs setObject:colorData forKey:@"customColor"];
    [prefs setInteger:sdrColor.value forKey:@"sliderValue"];
    [prefs setObject:NSStringFromCGPoint(alphaCenter) forKey:@"alphaCord"];
    [prefs synchronize];
}
- (UIColor*)recallUIColor {
    UIColor *color;
    if ([prefs objectForKey:@"customColor"] != nil) {
        NSData *colorData = [prefs objectForKey:@"customColor"];
        color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    } else {
        color = [UIColor blueColor];
    }
    
    return color;
}
- (void)sendUIColorValue {
    /*
    const CGFloat *components = CGColorGetComponents([self recallUIColor].CGColor);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    */
    
    for(UIView *v in self.superview.subviews) {
        if ([v tag]==1000) {
            UIButton *btnColor=(UIButton*)v;
            [btnColor setTitle:[NSString stringWithFormat:@"#%@",txtHex.text] forState:UIControlStateNormal];
            for (UIView *v2 in btnColor.subviews) {
                if ([v2 tag]==1000) {
                    [v2 setBackgroundColor:[self UIColorwithHexString:txtHex.text alpha:1.0]];
                }
            }
        }
    }
}

#pragma mark - Used to get Saved Color & Hex String
- (NSString*)getColorText {
    return [NSString stringWithFormat:@"#%@",[txtHex.text uppercaseString]];
}
- (UIColor*)getColorUIColor {
    return [self recallUIColor];
}

#pragma mark - Keyboard Movement
- (void)removeKeyboard {
    [txtHex resignFirstResponder];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.2 animations:^{
        int offSet = [self getOffset];
        if (offSet != 60) {
            offSet = -1*offSet;
        }
        
        [mainView setFrame:CGRectMake((SCREEN.size.width-300)/2, offSet, 300, 320)];
    }];
    
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        [mainView setFrame:CGRectMake((SCREEN.size.width-300)/2, 60, 300, 320)];
    }];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self removeKeyboard];
    [self setGradientWithColor:[self UIColorwithHexString:theTextField.text alpha:1.0]];
    return YES;
}
- (float)getOffset {
    switch ((int)SCREEN.size.height) {
        case 480:
            return 110;
            break;
        case 568:
            return 30;
            break;
        /*case 667:
            return 0;
            break;
        case 736:
            return expression
            break;*/
        default:
            return 60;
            break;
    }
}

#pragma mark - Exit Actions
- (void)exit {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)confirmColor {
    [self saveUIColor:[self UIColorwithHexString:txtHex.text alpha:1.0]];
    [self sendUIColorValue];
    [self exit];
}
@end
