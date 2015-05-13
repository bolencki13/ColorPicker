//
//  ViewController.m
//  ColorPicker
//
//  Created by Brian Olencki on 4/28/15.
//  Copyright (c) 2015 bolencki13. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    UIButton *btnColorPicker = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnColorPicker addTarget:self action:@selector(openPicker) forControlEvents:UIControlEventTouchUpInside];
    [btnColorPicker setTitle:@"Open Color Picker" forState:UIControlStateNormal];
    btnColorPicker.frame = CGRectMake(0, 0, 50, 50);
    [btnColorPicker sizeToFit];
    btnColorPicker.center = self.view.center;
    [self.view addSubview:btnColorPicker];
    */
    
    colorPicker = [customColorPicker new];
    [self createColorPickerButton];
}
- (void)createColorPickerButton {
    UIButton *btnOpenPalet = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOpenPalet.backgroundColor = [UIColor whiteColor];
    [btnOpenPalet addTarget:self action:@selector(openPicker) forControlEvents:UIControlEventTouchUpInside];
    [btnOpenPalet setTitle:[colorPicker getColorText] forState:UIControlStateNormal];
    btnOpenPalet.tag = 1000;
    btnOpenPalet.frame = CGRectMake(SCREEN.size.width-100, 25, 100, 30);
    [btnOpenPalet setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnOpenPalet.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnOpenPalet setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.view addSubview:btnOpenPalet];
    
    UIView *colorPalet = [[UIView alloc] initWithFrame:CGRectMake(btnOpenPalet.bounds.size.width-25, 5, 20, 20)];
    colorPalet.backgroundColor = [colorPicker getColorUIColor];
    colorPalet.tag = 1000;
    colorPalet.layer.borderColor = [UIColor blackColor].CGColor;
    colorPalet.layer.borderWidth = 0.5;
    colorPalet.layer.cornerRadius = 20/2;
    [btnOpenPalet addSubview:colorPalet];
}

#pragma mark - Opens Color Picker
- (void)openPicker {
    colorPicker = [customColorPicker new];
    colorPicker.alpha = 0.0;
    [self.view addSubview:colorPicker];

    [UIView animateWithDuration:0.3 animations:^{
        colorPicker.alpha = 1.0;
    }];
}
@end
