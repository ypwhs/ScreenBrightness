//
//  ViewController.m
//  ScreenBrightness
//
//  Created by 杨培文 on 2016/10/20.
//  Copyright © 2016年 杨培文. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ViewController

const int kMaxDisplays = 16;
const CFStringRef kDisplayBrightness = CFSTR(kIODisplayBrightnessKey);

- (float) get_brightness {
    CGDirectDisplayID display[kMaxDisplays];
    CGDisplayCount numDisplays;
    CGDisplayErr err;
    err = CGGetActiveDisplayList(kMaxDisplays, display, &numDisplays);
    
    if (err != CGDisplayNoErr)
        printf("cannot get list of displays (error %d)\n",err);
    for (CGDisplayCount i = 0; i < numDisplays; ++i) {
        
        CGDirectDisplayID dspy = display[i];
        CFDictionaryRef originalMode = CGDisplayCurrentMode(dspy);
        if (originalMode == NULL)
            continue;
        io_service_t service = CGDisplayIOServicePort(dspy);
        
        float brightness;
        err= IODisplayGetFloatParameter(service, kNilOptions, kDisplayBrightness, &brightness);
        if (err != kIOReturnSuccess) {
            fprintf(stderr,
                    "failed to get brightness of display 0x%x (error %d)",
                    (unsigned int)dspy, err);
            continue;
        }
        return brightness;
    }
    return -1.0;//couldn't get brightness for any display
}

- (void) set_brightness:(float) new_brightness {
    CGDirectDisplayID display[kMaxDisplays];
    CGDisplayCount numDisplays;
    CGDisplayErr err;
    err = CGGetActiveDisplayList(kMaxDisplays, display, &numDisplays);
    
    if (err != CGDisplayNoErr)
        printf("cannot get list of displays (error %d)\n",err);
    for (CGDisplayCount i = 0; i < numDisplays; ++i) {
        CGDirectDisplayID dspy = display[i];
        CFDictionaryRef originalMode = CGDisplayCurrentMode(dspy);
        if (originalMode == NULL)
            continue;
        io_service_t service = CGDisplayIOServicePort(dspy);
        
        float brightness;
        err = IODisplayGetFloatParameter(service, kNilOptions, kDisplayBrightness,
                                         &brightness);
        if (err != kIOReturnSuccess) {
            fprintf(stderr,
                    "failed to get brightness of display 0x%x (error %d)",
                    (unsigned int)dspy, err);
            continue;
        }
        
        err = IODisplaySetFloatParameter(service, kNilOptions, kDisplayBrightness,
                                         new_brightness);
        if (err != kIOReturnSuccess) {
            fprintf(stderr,
                    "Failed to set brightness of display 0x%x (error %d)",
                    (unsigned int)dspy, err);
            continue;
        }
    }
}

int seconds = 0;
float brightness;
int alltime = 2 * 3600;

- (void)viewDidLoad {
    [super viewDidLoad];
    seconds = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"seconds"];
    NSVisualEffectView * view = (NSVisualEffectView *)self.view;
    
    view.material = NSVisualEffectMaterialDark;
    view.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    view.state = NSVisualEffectStateActive;
    
    self.leftProgress.minValue = 0;
    self.leftProgress.maxValue = alltime;
    
    //统计使用时间/执行线程
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        while(true){
            brightness = [self get_brightness] * 16;
            if(brightness > 0){
                seconds += 1;
            }
            
            int left = alltime - seconds;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.timeLabel.stringValue = [NSString stringWithFormat:@"已用时间：%d:%02d:%02d\n剩余时间：%d:%02d:%02d", seconds/3600, seconds/60%60, seconds%60, left/3600, left/60%60, left%60];
                self.leftProgress.doubleValue = left;
            });
            
            //超过日累计使用时间，黑屏
            if(left < -5){
                [self set_brightness:0];
            }
            
            //每日0点0分到0点1分清空日累计使用时间
            NSDate * now = [NSDate date];
            NSCalendar * calendar = [NSCalendar currentCalendar];
            NSDateComponents * components= [calendar components:0xFF fromDate:now];
            if(components.hour == 0 && components.minute < 1){
                seconds = 0;
            }
            
            [NSThread sleepForTimeInterval:1];
        }
    });
}

- (void)viewWillDisappear{
    [[NSUserDefaults standardUserDefaults] setInteger:seconds forKey:@"seconds"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


@end
