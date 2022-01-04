//
//  KSYFloatingWindowVC.m
//  KSYLiveDemo
//
//  Created by iVermisseDich on 2017/3/13.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYFloatingWindowVC.h"

@interface FloatingView : KSYUIView

@property UIButton * quitBtn;
@property KSYGPUView * preView;
@property UILabel * text;
@property CGPoint loc_in;

@end

@implementation FloatingView
- (id) init {
    self = [super init];
    self.backgroundColor = [UIColor whiteColor];
    _text  = [self addLable:@"Kingsoft Video Cloud relies on industry-leading codec technology and powerful distribution services, based on Kingsoft Cloud’s top IaaS infrastructure, and provides one-stop cloud direct and on-demand services. \nKingsoft Video Cloud provides tools for content production and viewing, that is, push streaming SDK. With its complete functions, excellent compatibility and performance, it can meet the emerging business needs of customers, and then cooperate with third-party platforms through the Kingsoft Rubik’s Cube system. Realize the prosperity of the video ecological chain. \n\nKingsoft Cloud Push Streaming SDK supports H.264/H.265 encoding, software and hard coding, supports a variety of beauty filters, special effects, and microphones. The audio module is also continuously strengthened: bel canto, up and down, voice change, mixing The weak network optimization module is also quite successful: adaptive bit rate, active network detection, dynamic frame rate, etc. \nKingsoft Cloud Play SDK provides first-class live broadcast experience through live broadcast optimization strategies such as opening seconds on the first screen and catching up with live broadcasts."];
    _text.textAlignment = NSTextAlignmentCenter;
    _text.numberOfLines = 0;

    _preView = [[KSYGPUView alloc] init];
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_preView addGestureRecognizer:panGes];
    
    [self addSubview:_preView];
    
    _quitBtn = [self addButton:@"X"];
    [_preView addSubview:_quitBtn];
    
    return self;
}

- (void)updateConstraints{
    [super updateConstraints];
    _quitBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:_quitBtn
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_preView
                                 attribute:NSLayoutAttributeRight
                                multiplier:1.0
                                  constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:_quitBtn
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_preView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:_quitBtn
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:30].active = YES;
    [NSLayoutConstraint constraintWithItem:_quitBtn
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:30].active = YES;
}

- (void)pan:(UIPanGestureRecognizer *)ges{
    CGPoint loc = [ges locationInView:self];
    if (ges.state == UIGestureRecognizerStateBegan) {
        _loc_in = [ges locationInView:_preView];
    }
    
    // 坐标矫正，避免画面超出屏幕
    CGFloat x;
    CGFloat y;
    if (_preView.frame.size.width - _loc_in.x + loc.x >= self.width){
        x = self.width - _preView.frame.size.width * 0.5;
    }else if (loc.x - _loc_in.x <= 0) {
        x = _preView.frame.size.width * 0.5;
    }else {
        x = _preView.frame.size.width * 0.5 - _loc_in.x + loc.x;
    }
    
    if (_preView.frame.size.height - _loc_in.y + loc.y >= self.height) {
        y = self.height - _preView.frame.size.height * 0.5;
    }else if (loc.y - _loc_in.y <= 0){
        y = _preView.frame.size.height * 0.5;
    }else {
        y = _preView.frame.size.height * 0.5 - _loc_in.y + loc.y;
    }
    
    [UIView animateWithDuration:0 animations:^{
        _preView.center = CGPointMake(x, y);
    }];
}

- (void)rotateUI{
    [super layoutUI];
    _text.frame =  CGRectMake(0, 60, self.width, 100);
    [_text sizeToFit];
}

- (void) layoutUI {
    [super layoutUI];
    CGFloat x = self.width/2;
    CGFloat wdt = self.width/3;
    CGFloat hgt = self.height/3;
    _text.frame =  CGRectMake(0, 60, self.width, 100);
    [_text sizeToFit];

    _preView.frame = CGRectMake(x, self.yPos, wdt, hgt);
}

@end


@interface KSYFloatingWindowVC ()
{
    FloatingView * _floatingView;
}
@end

@implementation KSYFloatingWindowVC


- (void)loadView{
    _floatingView = [[FloatingView alloc] init];
    self.view = _floatingView;
    @WeakObj(self);
    _floatingView.onBtnBlock = ^(id sender){
        [selfWeak  onBtn:sender];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    // 需要在父类方法之前调用
    self.view.frame = [UIApplication sharedApplication].keyWindow.bounds;

    if (_streamerVC) {
        [_streamerVC.kit.vPreviewMixer addTarget: _floatingView.preView];
        _floatingView.preView.transform = _streamerVC.kit.preview.transform;
    }

    [super viewWillAppear:animated];
}

-(void)layoutUI{
    _floatingView.frame = self.view.bounds;
    [_floatingView layoutUI];
}

- (void)onViewRotate{
    [_floatingView rotateUI];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)onBtn:(id)sender {
    if (sender == _floatingView.quitBtn) {
        [_streamerVC.kit.vPreviewMixer removeTarget:_floatingView.preView];
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
        return;
    }
}

@end
