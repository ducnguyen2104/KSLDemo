//
//  KSYFloatVC.m
//  KSYPlayerDemo
//
//  Created by 施雪梅 on 2017/3/10.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "KSYUIView.h"
#import "KSYFloatVC.h"

#define ELEMENT_GAP  15

static NSString *backgroudText1 = {@"    Kingsoft Video Cloud relies on industry-leading codec technology and powerful distribution services, based on Kingsoft Cloud’s top IaaS infrastructure, providing one-stop cloud direct and on-demand services。"};
static NSString *backgroudText2 = {@"    Kingsoft Video Cloud provides tools for content production and viewing, namely the push streaming SDK. With its complete functions, excellent compatibility and performance, it can meet the emerging business needs of customers, and then realize the video through the Kingsoft Cube system and third-party platforms. The prosperity of the ecological chain."};
static NSString *backgroudText3 = {@"    Kingsoft Video Cloud provides tools for content production and viewing, namely the push streaming SDK. With its complete functions, excellent compatibility and performance, it can meet the emerging business needs of customers, and then realize the video through the Kingsoft Cube system and third-party platforms. The prosperity of the ecological chain。"};
static NSString *backgroudText4 = {@"    Kingsoft Cloud Push Streaming SDK supports H.264/H.265 encoding, soft and hard coding, and supports a variety of beauty filters, special effects, and microphones. The audio module is also continuously strengthened: bel canto, up and down, voice change, mixing, etc., weak The network optimization module is also quite successful: bit rate adaptation, network active detection, dynamic frame rate, etc.。"};

@implementation KSYFloatVC {
    KSYUIView *ctrlView;
    UILabel *bgText;
    UIView *videoView;
    UIButton *btnQuit;
    UIButton *btnStop;
    
    BOOL isMoving;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    ctrlView = [[KSYUIView alloc] initWithFrame:self.view.bounds];
    ctrlView.backgroundColor = [UIColor whiteColor];
    ctrlView.gap = ELEMENT_GAP;
    
    @WeakObj(self);
    ctrlView.onBtnBlock = ^(id sender){
        [selfWeak  onBtn:sender];
    };
    
    bgText = [ctrlView addLable:[NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@", backgroudText1, backgroudText2, backgroudText3, backgroudText4]];
    bgText.backgroundColor = [UIColor clearColor];
    bgText.textColor = [UIColor lightGrayColor];
    bgText.font = [UIFont fontWithName:@"楷体"  size:(22.0)];
    bgText.numberOfLines = -1;
    bgText.textAlignment = NSTextAlignmentLeft;
    
    videoView = [[UIView alloc] init];
    videoView.backgroundColor = [UIColor clearColor];
    [ctrlView addSubview:videoView];
    
    btnStop = [ctrlView addButton:@"stop"];
    btnQuit = [ctrlView addButton:@"quit"];
    
    [self layoutUI];
    
    [self.view addSubview: ctrlView];
}

- (void)layoutUI {
    ctrlView.frame = self.view.frame;
    [ctrlView layoutUI];
    
    bgText.frame =  CGRectMake(self.view.frame.size.width / 20, self.view.frame.size.height  / 20, self.view.frame.size.width * 9 / 10 , self.view.frame.size.height  * 9 / 10);
    videoView.frame = CGRectMake(self.view.frame.size.width / 2,  self.view.frame.size.height / 4, self.view.frame.size.width / 3 , self.view.frame.size.height / 3);
    
    ctrlView.yPos  = self.view.frame.size.height -  ctrlView.btnH - ELEMENT_GAP;
    [ctrlView putRow:@[btnStop, btnQuit]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_playerVC && _playerVC.player) {
        [_playerVC.player.view setFrame: videoView.bounds];
        [videoView addSubview: _playerVC.player.view];
    }
}

- (void)onBtn:(UIButton *)btn{
    if (btn == btnStop) {
        [self onStop];
    }else if (btn == btnQuit){
        [self onQuit];
    }
}

- (void)onQuit{
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

- (void)onStop{
    if(_playerVC && _playerVC.player)
    {
        [_playerVC.player stop];
        
        [_playerVC.player removeObserver:_playerVC forKeyPath:@"currentPlaybackTime" context:nil];
        [_playerVC.player removeObserver:_playerVC forKeyPath:@"clientIP" context:nil];
        [_playerVC.player removeObserver:_playerVC forKeyPath:@"localDNSIP" context:nil];
        
        [_playerVC.player.view removeFromSuperview];
        _playerVC.player = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.view];
    //判断触摸点是否在画中画上
    CALayer *touchedLayer = [self.view.layer hitTest:point];
    
    if(touchedLayer == _playerVC.player.view.layer){
        isMoving = YES;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    if(!isMoving){
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint current = [touch locationInView:self.view];
    CGPoint previous = [touch previousLocationInView:self.view];
    
    CGPoint center = videoView.center;
    
    CGPoint offset = CGPointMake(current.x - previous.x, current.y - previous.y);
    
    videoView.center = CGPointMake(center.x + offset.x, center.y + offset.y);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    isMoving = NO;
}
@end
