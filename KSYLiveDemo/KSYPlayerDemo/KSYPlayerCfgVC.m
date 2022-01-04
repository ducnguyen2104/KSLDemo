//
//  KSYPlayerCfgVC.m
//  KSYPlayerDemo
//
//  Created by zhengWei on 2017/4/17.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "KSYUIView.h"
#import "KSYPlayerCfgVC.h"
#import "KSYPlayerVC.h"
#import "KSYSimplePlayVC.h"

#define ELEMENT_GAP  5

@interface KSYPlayerCfgVC() <UITextFieldDelegate>

@end

@implementation KSYPlayerCfgVC {
    KSYUIView *ctrlView;
    
    UILabel *labelHostUrl;
    UITextField *textHostUrl;
    
    UILabel  *labelHWCodec;
    UISegmentedControl *segHWCodec;
    
    UILabel *labelContentMode;
    UISegmentedControl *segContentMode;
    
    UILabel *labelAutoPlay;
    UISegmentedControl *segAutoPlay;
    
    UILabel  *labelDeinterlace;
    UISegmentedControl *segDeinterlace;
 
    UILabel  *labelAudioInterrupt;
    UISegmentedControl *segAudioInterrupt;
    
    UILabel  *labelLoop;
    UISegmentedControl *segLoop;
    
    UILabel *labelMode;
    UISegmentedControl *segMode;
    
    KSYNameSlider *sliderConnectTimeout;
    
    KSYNameSlider *sliderReadTimeout;
    
    KSYNameSlider *sliderBufferTimeMax;
    
    KSYNameSlider *sliderBufferSizeMax;
    
    UILabel *demoLable;
    
    //播放按钮
    UIButton *btnPlay;
    //退出按钮
    UIButton *btnQuit;
    //极简播放按钮
    UIButton *btnSamplestPlay;
}

- (instancetype)initWithURL:(NSURL *)url  fileList:(NSArray *)fileList{
    self = [super init];
    _url = url;
    _fileList = fileList;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    //初始化各个控件
    ctrlView = [[KSYUIView alloc] initWithFrame:self.view.bounds];
    ctrlView.backgroundColor = [UIColor whiteColor];
    ctrlView.gap = ELEMENT_GAP;
    
    @WeakObj(self);
    ctrlView.onBtnBlock = ^(id sender){
        [selfWeak  onBtn:sender];
    };
    
    ctrlView.onSegCtrlBlock = ^(id sender){
        [selfWeak onSeg:sender];
    };
    
    labelHostUrl = [ctrlView addLable:@"Play address"];
    textHostUrl = [ctrlView addTextField:[_url isFileURL] ? [_url path] : [_url absoluteString]];
    textHostUrl.returnKeyType = UIReturnKeyDone;
    textHostUrl.delegate = self;
    
    //放置硬解码和swich开关
    labelHWCodec = [ctrlView addLable:@"Decoding method"];
    segHWCodec = [ctrlView addSegCtrlWithItems:@[@"Advanced Hard Solutions", @"Automatic", @"hard Solutions", @"Soft Solutions"]];
    segHWCodec.selectedSegmentIndex = 1;
    
    labelContentMode = [ctrlView addLable:@"Fill mode"];
    segContentMode = [ctrlView addSegCtrlWithItems:@[@"none", @"Year-on-year", @"Crop", @"Full screen"]];
    segContentMode.selectedSegmentIndex = 1;
    
    labelAutoPlay = [ctrlView addLable:@"Autoplay"];
    segAutoPlay = [ctrlView addSegCtrlWithItems:@[@"On",@"Off"]];
    
    labelDeinterlace = [ctrlView addLable:@"De-interlace mode"];
    segDeinterlace = [ctrlView addSegCtrlWithItems:@[@"On",@"off"]];
    
    labelAudioInterrupt = [ctrlView addLable:@"Audio interruption mode"];
    segAudioInterrupt = [ctrlView addSegCtrlWithItems:@[@"On",@"off"]];
    
    labelLoop = [ctrlView addLable:@"Loop"];
    segLoop = [ctrlView addSegCtrlWithItems:@[@"On",@"off"]];
    segLoop.selectedSegmentIndex = 1;
    
    labelMode = [ctrlView addLable:@"Play type"];
    segMode = [ctrlView addSegCtrlWithItems:@[@"Live", @"demand broadcast"]];
    
    sliderConnectTimeout = [ctrlView addSliderName:@"Connection timeout (sec)" From:3 To:100 Init:10];
    sliderReadTimeout = [ctrlView addSliderName:@"Read timeout (sec)" From:3 To:100 Init:30];
    sliderBufferTimeMax = [ctrlView addSliderName:@"bufferTimeMax(sec)" From:0 To:60 Init:2];
    sliderBufferSizeMax = [ctrlView addSliderName:@"bufferSizeMax(MB)" From:0 To:100 Init:15];
 
    demoLable    = [ctrlView addLable:@"Select the corresponding button to start"];
    demoLable.textAlignment = NSTextAlignmentCenter;
    
    //添加一个播放按钮
    btnPlay = [ctrlView addButton:@"Play"];
    //添加一个退出按钮
    btnQuit = [ctrlView addButton:@"quit"];
    btnSamplestPlay = [ctrlView addButton:@"Minimalist playback"];
    
    [self layoutUI];
    
    [self.view addSubview: ctrlView];
}

- (void)layoutUI {
    //设置各个控件的fram
    ctrlView.frame = self.view.frame;
    [ctrlView layoutUI];
    
    [ctrlView putLable:labelHostUrl andView:textHostUrl];
    //放置硬解码和swich开关
    [ctrlView putLable:labelHWCodec andView:segHWCodec];
    [ctrlView putLable:labelContentMode andView:segContentMode];
    [ctrlView putLable:labelAutoPlay andView:segAutoPlay];
    [ctrlView putLable:labelDeinterlace andView:segDeinterlace];
    [ctrlView putLable:labelAudioInterrupt andView:segAudioInterrupt];
    [ctrlView putLable:labelLoop andView:segLoop];
    [ctrlView putLable:labelMode andView:segMode];
    [ctrlView putRow1:sliderConnectTimeout];
    [ctrlView putRow1:sliderReadTimeout];
    [ctrlView putRow1:sliderBufferTimeMax];
    [ctrlView putRow1:sliderBufferSizeMax];
    [ctrlView putRow1:demoLable];
    
    CGFloat yPos = ctrlView.yPos > ctrlView.height ? ctrlView.yPos  - ctrlView.height : ctrlView.yPos;
    ctrlView.btnH = (ctrlView.height - yPos - ctrlView.gap*2) ;
    
    //放置播放和退出按钮
    [ctrlView putRow3:btnPlay and:btnSamplestPlay and:btnQuit];
}

- (void)onBtn:(UIButton *)btn{
    UIViewController *vc = nil;
    if(btn == btnPlay)
    {
        vc  = [[KSYPlayerVC alloc]initWithURLAndConfigure:[NSURL URLWithString:textHostUrl.text] fileList:_fileList config:self];
    }else if(btn == btnSamplestPlay){
        vc = [[KSYSimplePlayVC alloc]initWithURLAndConfigure:[NSURL URLWithString:textHostUrl.text] fileList:_fileList config:self];
    }
    else if(btn == btnQuit)
        [self dismissViewControllerAnimated:FALSE
                                 completion:nil];
    
    if (vc){
        [self presentViewController:vc animated:true completion:nil];
    }
}

- (void)onSeg:(UISegmentedControl*)seg {
    if(seg == segMode)
    {
        [self onPlayMode];
    }
}

- (void)onPlayMode{
    if(segMode.selectedSegmentIndex == 0)
    {
        sliderBufferTimeMax.slider.maximumValue = 60;
        sliderBufferTimeMax.slider.value = 2;
        sliderBufferTimeMax.valueL.text = @"2";
    }
    else
    {
        sliderBufferTimeMax.slider.maximumValue = 3600;
        sliderBufferTimeMax.slider.value = 3600;
        sliderBufferTimeMax.valueL.text = @"3600";
    }
}

- (MPMovieVideoDecoderMode)decodeMode {
    //返回解码方式
    switch(segHWCodec.selectedSegmentIndex) {
        case 0:
            return MPMovieVideoDecoderMode_DisplayLayer;
        case 1:
            return MPMovieVideoDecoderMode_AUTO;
        case 2:
            return MPMovieVideoDecoderMode_Hardware;
        case 3:
            return MPMovieVideoDecoderMode_Software;
        default:
            return MPMovieVideoDecoderMode_AUTO;
    }
}

- (MPMovieScalingMode)contentMode {
    //返回填充方式
    switch(segContentMode.selectedSegmentIndex) {
        case 0:
            return MPMovieScalingModeNone;
        case 1:
            return MPMovieScalingModeAspectFit;
        case 2:
            return  MPMovieScalingModeAspectFill;
        case 3:
            return MPMovieScalingModeFill;
        default:
            return  MPMovieScalingModeNone;
    }
}

- (BOOL)bAutoPlay {
    switch(segAutoPlay.selectedSegmentIndex) {
        case 0:
            return YES;
        case 1:
            return NO;
        default:
            return YES;
    }
}

- (MPMovieVideoDeinterlaceMode)deinterlaceMode {
    switch(segDeinterlace.selectedSegmentIndex) {
        case 0:
            return MPMovieVideoDeinterlaceMode_Auto;
        case 1:
            return MPMovieVideoDeinterlaceMode_None;
        default:
            return MPMovieVideoDeinterlaceMode_Auto;
    }
}

- (BOOL)bAudioInterrupt {
    switch(segAudioInterrupt.selectedSegmentIndex) {
        case 0:
            return YES;
        case 1:
            return NO;
        default:
            return YES;
    }
}

- (BOOL)bLoop {
    switch(segLoop.selectedSegmentIndex) {
        case 0:
            return YES;
        case 1:
            return NO;
        default:
            return YES;
    }
}

- (int)connectTimeout {
    return (int)sliderConnectTimeout.value;
}

- (int)readTimeout {
    return (int)sliderReadTimeout.value;
}

- (double)bufferTimeMax {
    return sliderBufferTimeMax.value;
}

- (int)bufferSizeMax {
    return (int)sliderBufferSizeMax.value;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
