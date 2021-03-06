//
//  KSYAudioCtrlView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "KSYPresetCfgView.h"
#import "KSYAudioCtrlView.h"
#import "KSYNameSlider.h"

@interface KSYAudioCtrlView() {
    
}

@property UILabel       * lblPlayCapture;
@property UILabel       * lblMuteSt;
@property UILabel       * lblReverb;
@property UILabel       * lblVPIO;
@property UILabel       * lblStereo;
@end
@implementation KSYAudioCtrlView

- (id)init{
    self = [super init];
    // 混音音量
    _micVol = [self addSliderName:@"Microphone volume" From:0.0 To:2.0 Init:0.9];
    _bgmVol = [self addSliderName:@"Background music volume"  From:0.0 To:2.0 Init:0.5];
    _bgmMix = [self addSwitch:YES];
    
    _micInput = [self addSegCtrlWithItems:@[ @"Built-in mic", @"Headset", @"Bluetooth mic"]];
    [self initMicInput];
    
    _lblAudioOnly    = [self addLable:@"Pure audio streaming"]; // 关闭视频
    _swAudioOnly     = [self addSwitch:NO]; // 关闭视频
    _lblMuteSt       = [self addLable:@"Mute push"];
    _muteStream      = [self addSwitch:NO];
    
    _lblStereo     = [self addLable:@"Stereo streaming"];
    _stereoStream  = [self addSwitch:NO];
    _lblReverb  = [self addLable:@"reverberation"];
    _reverbType = [self addSegCtrlWithItems:@[@"off", @"Video studio",
                                              @"concert",@"KTV",@"Small stage"]];
    _lblPlayCapture = [self addLable:@"Ear return"];
    _swPlayCapture  = [self addSwitch:NO];
    _playCapVol= [self addSliderName:@"Ear return volume"  From:0.0 To:1.0 Init:0.5];
    _effectType  = [self addSegCtrlWithItems:@[@"Off voice changer", @"Uncle", @"Loli", @"solemn", @"robot", @"custom"]];
    _reverbEffectParamsVaule= [self addSliderName:@"reverb parameter value"  From:0.0 To:100.0 Init:0.0];
    _delayEffectParamsVaule= [self addSliderName:@"delay parameter value"  From:0.0 To:100.0 Init:50.0];
    _pitchEffectParamsVaule= [self addSliderName:@"pitch parameter value"  From:-2400.0 To:2400.0 Init:1.0];
    _swReverbEffect  = [self addSwitch:NO];
    _swDelayEffect  = [self addSwitch:NO];
    _swPitchEffect  = [self addSwitch:NO];
    _noiseSuppressSeg = [self addSegCtrlWithItems:@[@"Off denoising",@"Low", @"middle", @"high", @"Very high"]];
    _noiseSuppressSeg.selectedSegmentIndex = 3;
    _audioDataTypeSeg = [self addSegCtrlWithItems:@[@"CMSampleBufer",@"RawPcm"]];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    self.btnH = 30;
    if (self.width > self.height) {
        self.btnH = 25;
    }
    [self putRow1:_micVol];
    [self putSlider:_bgmVol
          andSwitch:_bgmMix];
    [self putRow1:_micInput];
    [self putLable:_lblReverb andView:_reverbType];
    id nu = [NSNull null];
    [self putRowFit:@[_lblAudioOnly,_swAudioOnly,
                      nu, _lblMuteSt,_muteStream,
                      nu,_lblPlayCapture,_swPlayCapture] ];
    [self putRow1:_playCapVol];
    [self putRowFit:@[_lblStereo, _stereoStream, _audioDataTypeSeg]];
    [self putRow1:_noiseSuppressSeg];
    [self putRow1:_effectType];
    [self putSlider:_reverbEffectParamsVaule andSwitch:_swReverbEffect];
    [self putSlider:_delayEffectParamsVaule andSwitch:_swDelayEffect];
    [self putSlider:_pitchEffectParamsVaule andSwitch:_swPitchEffect];
    
}
- (void) initMicInput {
    BOOL bHS = [AVAudioSession isHeadsetInputAvaible];
    BOOL bBT = [AVAudioSession isBluetoothInputAvaible];
    [_micInput setEnabled:YES forSegmentAtIndex:1];
    [_micInput setEnabled:YES forSegmentAtIndex:2];
    if (!bHS){
        [_micInput setEnabled:NO forSegmentAtIndex:1];
    }
    if (!bBT){
        [_micInput setEnabled:NO forSegmentAtIndex:2];
    }
}

static int micType2Int( KSYMicType t) {
    if (t == KSYMicType_builtinMic){
        return 0;
    }
    else if (t == KSYMicType_headsetMic){
        return 1;
    }
    else if (t == KSYMicType_bluetoothMic){
        return 2;
    }
    return 0;
}

static KSYMicType int2MicType( int t) {
    if (t == 0){
        return KSYMicType_builtinMic;
    }
    else if (t == 1){
        return KSYMicType_headsetMic;
    }
    else if (t == 2){
        return KSYMicType_bluetoothMic;
    }
    return KSYMicType_builtinMic;
}

@synthesize  micType = _micType;
- (void) setMicType:(KSYMicType)micType{
    _micType = micType;
    _micInput.selectedSegmentIndex = micType2Int(micType);
}

- (KSYMicType) micType{
    _micType = int2MicType((int)_micInput.selectedSegmentIndex);
    return _micType;
}
@synthesize audioEffect = _audioEffect;
- (void) setAudioEffect:(KSYAudioEffectType)audioEffect {
    _audioEffect = audioEffect;
    if (_audioEffect < 6 ) {
        _effectType.selectedSegmentIndex  = (NSInteger) _audioEffect;
    }
}
- (KSYAudioEffectType) audioEffect {
    _audioEffect =  _effectType.selectedSegmentIndex;
    return _audioEffect;
}

@synthesize noiseSuppress = _noiseSuppress;
- (KSYAudioNoiseSuppress) noiseSuppress {
    return _noiseSuppressSeg.selectedSegmentIndex - 1; // off is -1
}
@synthesize audioDataType = _audioDataType;
- (KSYAudioDataType) audioDataType {
    return _audioDataTypeSeg.selectedSegmentIndex;
}
@end
