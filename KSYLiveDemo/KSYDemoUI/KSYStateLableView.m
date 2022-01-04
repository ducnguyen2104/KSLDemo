//
//  KSYStateLableView.m
//  KSYDemo
//
//  Created by pengbin on 16/9/5.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIVC.h"
#import "KSYStateLableView.h"
#import "KSYPresetCfgView.h"


@interface KSYStateLableView ()

@end

@implementation KSYStateLableView

- (id) init {
    self = [super init];
    self.backgroundColor = [UIColor clearColor];
    self.textColor = [UIColor redColor];
    self.numberOfLines = 12;
    self.textAlignment = NSTextAlignmentLeft;
    self.hideText = NO;
    [self initStreamStat];
    return self;
}

// 将推流状态信息清0
- (void) initStreamStat{
    memset(&_lastStD, 0, sizeof(_lastStD));
    _startTime  = [[NSDate date]timeIntervalSince1970];
    _notGoodCnt = 0;
    _bwRaiseCnt = 0;
    _bwDropCnt  = 0;
}

- (void) updateState:(KSYStreamerBase*)str {
    KSYStreamerQosInfo *info = [str qosInfo];
    
    StreamState curState = {0};
    curState.timeSecond     = [[NSDate date]timeIntervalSince1970];
    curState.uploadKByte    = [str uploadedKByte];
    curState.encodedFrames  = [str encodedFrames];
    curState.droppedVFrames = [str droppedVideoFrames];
    curState.capFrames      = _capFrames;
    
    StreamState deltaS  = {0};
    deltaS.timeSecond    = curState.timeSecond    -_lastStD.timeSecond    ;
    deltaS.uploadKByte   = curState.uploadKByte   -_lastStD.uploadKByte   ;
    deltaS.encodedFrames = curState.encodedFrames -_lastStD.encodedFrames ;
    deltaS.droppedVFrames= curState.droppedVFrames-_lastStD.droppedVFrames;
    deltaS.capFrames     = curState.capFrames     -_lastStD.capFrames;
    
    _lastStD = curState;
    if (self.hideText) {
        self.text = nil;
        return;
    }
    
    double realTKbps   = deltaS.uploadKByte*8 / deltaS.timeSecond;
    double encFps      = deltaS.encodedFrames / deltaS.timeSecond;
    double capFps      = deltaS.capFrames / deltaS.timeSecond;
    double dropPercent = deltaS.droppedVFrames * 100.0 /MAX(curState.encodedFrames, 1);
    
    
    NSString* liveTime =[KSYUIVC timeFormatted: (int)(curState.timeSecond-_startTime) ] ;
    NSString *uploadDateSize = [KSYUIVC sizeFormatted:curState.uploadKByte];
    NSString* stateurl  = [NSString stringWithFormat:@"%@\n", [str.hostURL absoluteString]];
    //Show streaming address
    NSString *playUrl = @"http://mobile.kscvbu.cn:8080/live/";
    if (![[str.hostURL scheme] isEqualToString:@"rtmp"]) {
        //Record to local
        NSString *fileName = [[stateurl componentsSeparatedByString:@"/"]lastObject];
        playUrl = [NSString stringWithFormat:@"Pull stream address:%@\n",fileName];
    }else{
        //Push stream
        NSString *fileName = [[stateurl componentsSeparatedByString:@"/"]lastObject];
        NSString *playUrlPostfix = @".flv";
        playUrl = [NSString stringWithFormat:@"%@%@%@",playUrl,fileName,playUrlPostfix];
        playUrl = [NSString stringWithFormat:@"Pull stream address:%@\n",playUrl];
    }
    NSString* statekbps = [NSString stringWithFormat:@"Real-time bit rate(kbps)%4.1f\tA%4.1f\tV%4.1f\n", realTKbps, [str encodeAKbps], [str encodeVKbps] ];
    NSString* statefps  = [NSString stringWithFormat:@"Real-time frame rate(fps)%2.1f %2.1f\t总上传:%@\n", encFps, capFps, uploadDateSize ];
    NSString* videoqosinfo = [NSString stringWithFormat:@"Video buffering %d B  %d ms  %d packets \n",
                                                    info->videoBufferDataSize, info->videoBufferTimeLength, info->videoBufferPackets];
    NSString* audioqosinfo = [NSString stringWithFormat:@"Audio buffer %d B  %d ms  %d packets \n",
                                                    info->audioBufferDataSize, info->audioBufferTimeLength, info->audioBufferPackets];
    NSString* statedrop = [NSString stringWithFormat:@"Video frame drop %4d\t %2.1f%% \n", curState.droppedVFrames, dropPercent ];
    NSString* netEvent = [NSString stringWithFormat:@"Network event count %d bad\n\tbw %d Raise %d drop\t fps %d Raise %d drop\n",
                                            _notGoodCnt, _bwRaiseCnt, _bwDropCnt, _fpsRaiseCnt, _fpsDropCnt];
    NSString *cpu_use = [NSString stringWithFormat:@"%@ \tcpu: %.2f mem: %.1fMB",liveTime, [KSYUIVC cpu_usage], [KSYUIVC memory_usage] ];
    NSArray *texts = @[stateurl, playUrl, statekbps, statefps, videoqosinfo, audioqosinfo, statedrop, netEvent, cpu_use ];
    self.text = [texts componentsJoinedByString:@""];

    
}

- (void)drawTextInRect:(CGRect) rect {
    if (self.text == nil){
        return;
    }
    CGFloat oldH = rect.size.height;
    NSAttributedString *attributedText;
    attributedText = [[NSAttributedString alloc] initWithString:self.text
                                                     attributes:@{NSFontAttributeName:self.font}];
    rect.size.height = [attributedText boundingRectWithSize:rect.size
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                    context:nil].size.height;
    if (self.numberOfLines != 0) {
        rect.size.height = MIN(rect.size.height, self.numberOfLines * self.font.lineHeight);
    }
    rect.origin.y = oldH - rect.size.height;  // Align Bottom Move a paragraph of text to the bottom
    [super drawTextInRect:rect];
}
@end
