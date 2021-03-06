//
//  KSYAudioView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYBgmView.h"
#import "KSYNameSlider.h"
#import "KSYFileSelector.h"

@interface KSYBgmView(){
    UILabel * _bgmTitle;
    KSYFileSelector *_bgmSel;
    NSInteger _cnt;
}
@end

@implementation KSYBgmView
-(id)init{
    self = [super init];
    _bgmTitle   = [self addLable:@"Background music address Documents/bgms"];
    _previousBtn= [self addButton:@"Prev"];
    _playBtn    = [self addButton:@"Play"];
    _pauseBtn   = [self addButton:@"pause"];
    [_pauseBtn setTitle: @"continue" forState: UIControlStateSelected];
    _stopBtn    = [self addButton:@"stop"];
    _volumSl    = [self addSliderName:@"volume" From:0 To:100 Init:50];
    _pitchSl    = [self addSliderName:@"tone" From:-3 To:3 Init:0];
    _pitchSl.precision = 0;
    _pitchSl.slider.enabled = NO;
    _pitchStep  = [[UIStepper alloc] init];
    _pitchStep.continuous = NO;
    _pitchStep.maximumValue = 3;
    _pitchStep.minimumValue = -3;
    [self addSubview:_pitchStep];
    [_pitchStep addTarget:self
                   action:@selector(onStep:)
         forControlEvents:UIControlEventValueChanged];
    _nextBtn    = [self addButton:@"next"];
    _bgmStatus  = @"idle";
    _bgmPattern = @[@".mp3", @".m4a", @".aac"];
    _bgmSel     = [[KSYFileSelector alloc] initWithDir:@"/Documents/bgms/"
                                             andSuffix:_bgmPattern];
    _bgmPath    = _bgmSel.filePath;
    _cnt        = _bgmSel.fileList.count;
    _loopType = [self addSegCtrlWithItems:@[@"Single play", @"Single cycle", @"Shuffle Playback",@"Loop"]];
    _loopType.selectedSegmentIndex = 3;
    _progressBar = [[KSYProgressView alloc] init];
    [self addSubview:_progressBar];
    if (_cnt == 0) {
        NSString *urlStr = @"https://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios/bgm.aac";
        [_bgmSel downloadFile:urlStr name:@"bgm.aac" ];
        urlStr = @"https://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios/test1.mp3";
        [_bgmSel downloadFile:urlStr name:@"test1.mp3"];
    }
    return self;
}

- (void)layoutUI{
    [super layoutUI];
    [self putRow1:_progressBar];
    [self putRow1:_bgmTitle];
    [self putRow:@[_previousBtn,_playBtn,_pauseBtn, _stopBtn, _nextBtn] ];
    [self putRow1:_volumSl];
    [self putRow1:_loopType];
    [self putWide:_pitchSl  andNarrow:_pitchStep];
}

- (NSString*) loopNextBgmPath {
    //@"Single play", @"single loop", @"random play",@"loop play"]
    if (_loopType.selectedSegmentIndex == 0) {
    }
    else if (_loopType.selectedSegmentIndex == 1) {
    }
    else if (_loopType.selectedSegmentIndex == 2) {
        [_bgmSel selectFileWithType:KSYSelectType_RANDOM];
    }
    else if (_loopType.selectedSegmentIndex == 3){
        [_bgmSel selectFileWithType:KSYSelectType_NEXT];
    }
    return [self updateBgmPath];
}
- (NSString*) nextBgmPath {
    [_bgmSel selectFileWithType:KSYSelectType_NEXT];
    return [self updateBgmPath];
}
- (NSString*) previousBgmPath{
    [_bgmSel selectFileWithType:KSYSelectType_PREVIOUS];
    return [self updateBgmPath];
}
- (NSString*) updateBgmPath{
    dispatch_async(dispatch_get_main_queue(), ^{
        _bgmTitle.text = [_bgmStatus stringByAppendingString:_bgmSel.fileInfo];
    });
    _bgmPath    = _bgmSel.filePath;
    return _bgmSel.filePath;
}

@synthesize bgmStatus = _bgmStatus;
- (void) setBgmStatus:(NSString *)bgmStatus{
    _bgmStatus = bgmStatus;
    dispatch_async(dispatch_get_main_queue(), ^{
        _bgmTitle.text = [_bgmStatus stringByAppendingString:_bgmSel.fileInfo];
    });
}
- (NSString *) bgmStatus{
    return _bgmStatus;
}
- (IBAction)onStep:(id)sender {
    if (sender == _pitchStep) {
        _pitchSl.value = _pitchStep.value;
    }
}
- (void) relaodFile {
    [_bgmSel reload];
    _bgmPath = _bgmSel.filePath;
    _cnt     = _bgmSel.fileList.count;
}
@end
