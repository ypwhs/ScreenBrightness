//
//  WindowController.m
//  ScreenBrightness
//
//  Created by 杨培文 on 2016/10/20.
//  Copyright © 2016年 杨培文. All rights reserved.
//

#import "WindowController.h"

@interface WindowController ()

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    //整个窗口均可拖动
    self.window.movableByWindowBackground = true;
    
    //最上，且在每个屏幕中显示
    self.window.level = kCGMainMenuWindowLevel-1;
    [self.window setCollectionBehavior:NSWindowCollectionBehaviorStationary|NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
    
    self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    
}

@end
