//
//  KSYFilterView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//
#import <GPUImage/GPUImage.h>
#import "KSYFilterView.h"
#import "KSYNameSlider.h"
#import "KSYPresetCfgView.h"
#import "ZipArchive.h"


@interface KSYFilterView() {
    UILabel * _lblSeg;
    NSInteger _curIdx;
    NSArray * _effectNames;
    NSInteger _curEffectIdx;
    //GPUResource storage path
    NSString *_gpuResourceDir;
}

@property (nonatomic) UILabel * lbPrevewFlip;
@property (nonatomic) UILabel * lbStreamFlip;

@property (nonatomic) UILabel * lbUiRotate;
@property (nonatomic) UILabel * lbStrRotate;

@property KSYNameSlider *proFilterLevel;
@property UIStepper *proFilterLevelStep;

@end

@implementation KSYFilterView

- (id)init{
    self = [super init];
    _effectNames = [NSArray arrayWithObjects:
                    @"0 Original picture closes special effects",
                    @"1 Small fresh",
                    @"2 Pretty",
                    @"3 Sweet and lovely",
                    @"4 Nostalgia",
                    @"5 Blues",
                    @"6 old photo",
                    @"7 Cherry blossoms",
                    @"8 Cherry blossoms (suitable for low-light environments)",
                    @"9 Ruddy (suitable for low-light environments)",
                    @"10 Sunlight (suitable for low-light environments)",
                    @"11 rosy",
                    @"12 Sunlight",
                    @"13 nature",
                    @"14 Lovers",
                    @"15 elegant",
                    @"16 Pretty in Pink ",
                    @"17 Yogurt ",
                    @"18 fleeting time ",
                    @"19 Soft light ",
                    @"20 classic ",
                    @"21 Early summer ",
                    @"22 Black and white ",
                    @"23 New York ",
                    @"24 Ueno ",
                    @"25 Bibo ",
                    @"26 Japanese ",
                    @"27 Cool ",
                    @"28 Tilt ",
                    @"29 dream ",
                    @"30 Calm ",
                    @"31 Migratory birds ",
                    @"32 Elegant ", nil];
    [self downloadGPUResource];
    _curEffectIdx = 1;
    // Modify beauty parameters
    _filterParam1 = [self addSliderName:@"parameter" From:0 To:100 Init:50];
    _filterParam2 = [self addSliderName:@"Whitening" From:0 To:100 Init:50];
    _filterParam3 = [self addSliderName:@"rosy" From:0 To:100 Init:50];
    _filterParam2.hidden = YES;
    _filterParam3.hidden = YES;
    
    _proFilterLevel    = [self addSliderName:@"type" From:1 To:4 Init:1];
    _proFilterLevel.precision = 0;
    _proFilterLevel.slider.enabled = NO;
    _proFilterLevelStep  = [[UIStepper alloc] init];
    _proFilterLevelStep.continuous = NO;
    _proFilterLevelStep.maximumValue = 4;
    _proFilterLevelStep.minimumValue = 1;
    [self addSubview:_proFilterLevelStep];
    [_proFilterLevelStep addTarget:self
                   action:@selector(onStep:)
         forControlEvents:UIControlEventValueChanged];
    _proFilterLevel.hidden = YES;
    _proFilterLevelStep.hidden = YES;
    
    _lblSeg = [self addLable:@"Filter"];
    _filterGroupType = [self addSegCtrlWithItems:
  @[ @"close",
     @"Old beauty",
     @"Beauty pro",
     @"natural",
     @"rosy",
     @"Special effects",
     ]];
    _filterGroupType.selectedSegmentIndex = 1;
    [self selectFilter:1];
    
    _lbPrevewFlip = [self addLable:@"Preview mirror"];
    _lbStreamFlip = [self addLable:@"Stream mirror"];
    _swPrevewFlip = [self addSwitch:NO];
    _swStreamFlip = [self addSwitch:NO];
    
    _lbUiRotate   = [self addLable:@"UI rotation"];
    _lbStrRotate  = [self addLable:@"stream rotation"];
    _swUiRotate   = [self addSwitch:NO];
    _swStrRotate  = [self addSwitch:NO];
    _swStrRotate.enabled = NO;
    
    _effectPicker = [[UIPickerView alloc] init];
    [self addSubview: _effectPicker];
    _effectPicker.hidden     = YES;
    _effectPicker.delegate   = self;
    _effectPicker.dataSource = self;
    _effectPicker.showsSelectionIndicator= YES;
    _effectPicker.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [_effectPicker selectRow:1 inComponent:0 animated:YES];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    self.yPos = 0;
    [self putRow: @[_lbPrevewFlip, _swPrevewFlip,
                    _lbStreamFlip, _swStreamFlip ]];
    [self putRow: @[_lbUiRotate, _swUiRotate,
                    _lbStrRotate, _swStrRotate ]];
    [self putLable:_lblSeg andView: _filterGroupType];
    CGFloat paramYPos = self.yPos;
    if ( self.width > self.height){
        self.winWdt /= 2;
    }
    [self putRow1:_filterParam1];
    [self putRow1:_filterParam2];
    [self putRow1:_filterParam3];
    [self putWide:_proFilterLevel andNarrow:_proFilterLevelStep];
    
    if ( self.width > self.height){
        _effectPicker.frame = CGRectMake( self.winWdt, paramYPos, self.winWdt, 162);
    }
    else {
        self.btnH = 162;
        [self putRow1:_effectPicker];
    }
}

- (IBAction)onStep:(id)sender {
    if (sender == _proFilterLevelStep) {
        _proFilterLevel.value = _proFilterLevelStep.value;
        [self selectFilter: _filterGroupType.selectedSegmentIndex];
    }
    [super onSegCtrl:sender];
}

- (IBAction)onSwitch:(id)sender {
    if (sender == _swUiRotate){
        // Only when the interface rotates with the device, the push stream can rotate
        _swStrRotate.enabled = _swUiRotate.on;
        if (!_swUiRotate.on) {
            _swStrRotate.on = NO;
        }
    }
    [super onSwitch:sender];
}

- (IBAction)onSegCtrl:(id)sender {
    if (_filterGroupType == sender){
        [self selectFilter: _filterGroupType.selectedSegmentIndex];
    }
    [super onSegCtrl:sender];
}
- (void) selectFilter:(NSInteger)idx {
    _curIdx = idx;
    _filterParam1.hidden = YES;
    _filterParam2.hidden = YES;
    _filterParam3.hidden = YES;
    _proFilterLevel.hidden = YES;
    _proFilterLevelStep.hidden = YES;
    _effectPicker.hidden = YES;
    // Identifies the currently selected filter
    if (idx == 0){
        _curFilter  = nil;
    }
    else if (idx == 1){
        _filterParam1.nameL.text = @"parameter";
        _filterParam1.hidden = NO;
        _curFilter = [[KSYGPUBeautifyExtFilter alloc] init];
    }
    else if (idx == 2){ // Beauty pro
        _filterParam1.hidden = NO;
        _filterParam2.hidden = NO;
        _filterParam3.hidden = NO;
        _proFilterLevel.hidden = NO;
        _proFilterLevelStep.hidden = NO;
        KSYBeautifyProFilter * f = [[KSYBeautifyProFilter alloc] initWithIdx:_proFilterLevel.value];
        _filterParam1.nameL.text = @"Microdermabrasion";
        f.grindRatio  = _filterParam1.normalValue;
        f.whitenRatio = _filterParam2.normalValue;
        f.ruddyRatio  = _filterParam3.normalValue;
        _curFilter    = f;
    }
    else if (idx == 3){ // natural
        _filterParam1.hidden = NO;
        _filterParam2.hidden = NO;
        _filterParam3.hidden = NO;
        KSYBeautifyProFilter * nf = [[KSYBeautifyProFilter alloc] initWithIdx:3];
        _filterParam1.nameL.text = @"Microdermabrasion";
        nf.grindRatio  = _filterParam1.normalValue;
        nf.whitenRatio = _filterParam2.normalValue;
        nf.ruddyRatio  = _filterParam3.normalValue;
        _curFilter    = nf;
    }
    else if (idx == 4){ // Ruddy + Beauty
        _filterParam1.nameL.text = @"Microdermabrasion";
        _filterParam3.nameL.text = @"rosy";
        _filterParam1.hidden = NO;
        _filterParam2.hidden = NO;
        _filterParam3.hidden = NO;
        NSString *imgPath=[_gpuResourceDir stringByAppendingString:@"3_tianmeikeren.png"];
        UIImage *rubbyMat=[[UIImage alloc]initWithContentsOfFile:imgPath];
        if (rubbyMat == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"hint"
                                                            message:@"Special effects resources are being downloaded, please try again later"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Sure", nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
        KSYBeautifyFaceFilter *bf = [[KSYBeautifyFaceFilter alloc] initWithRubbyMaterial:rubbyMat];
        bf.grindRatio  = _filterParam1.normalValue;
        bf.whitenRatio = _filterParam2.normalValue;
        bf.ruddyRatio  = _filterParam3.normalValue;
        _curFilter = bf;
    }
    else if (idx == 5){ // Beauty + special effects filter combination
        _filterParam1.nameL.text = @"Microdermabrasion";
        _filterParam3.nameL.text = @"Special effects";
        _filterParam1.hidden = NO;
        _filterParam2.hidden = NO;
        _filterParam3.hidden = NO;
        _effectPicker.hidden = NO;
        _proFilterLevel.hidden = NO;
        _proFilterLevelStep.hidden = NO;
        // Construct beauty filters and special effects filters
        KSYBeautifyProFilter    * bf = [[KSYBeautifyProFilter alloc] initWithIdx:_proFilterLevel.value];
        bf.grindRatio  = _filterParam1.normalValue;
        bf.whitenRatio = _filterParam2.normalValue;
        bf.ruddyRatio  = 0.5;
        
        KSYBuildInSpecialEffects * sf = [[KSYBuildInSpecialEffects alloc] initWithIdx:_curEffectIdx];
        sf.intensity   = _filterParam3.normalValue;
        [bf addTarget:sf];
        
        // Use the filter set to concatenate the filters into a whole
        GPUImageFilterGroup * fg = [[GPUImageFilterGroup alloc] init];
        [fg addFilter:bf];
        [fg addFilter:sf];
        
        [fg setInitialFilters:[NSArray arrayWithObject:bf]];
        [fg setTerminalFilter:sf];
        _curFilter = fg;
    }
    else {
        _curFilter = nil;
    }
}

- (IBAction)onSlider:(id)sender {
    if (sender != _filterParam1 &&
        sender != _filterParam2 &&
        sender != _filterParam3 ) {
        return;
    }
    float nalVal = _filterParam1.normalValue;
    if (_curIdx == 1){
        int val = (nalVal*5) + 1; // level 1~5
        [(KSYGPUBeautifyExtFilter *)_curFilter setBeautylevel: val];
    }
    else if (_curIdx == 2 || _curIdx == 3) {
        KSYBeautifyProFilter * f =(KSYBeautifyProFilter*)_curFilter;
        if (sender == _filterParam1 ){
            f.grindRatio = _filterParam1.normalValue;
        }
        if (sender == _filterParam2 ) {
            f.whitenRatio = _filterParam2.normalValue;
        }
        if (sender == _filterParam3 ) {  // 红润参数
            f.ruddyRatio = _filterParam3.normalValue;
        }
    }
    else if (_curIdx == 4 ){ // 美颜
        KSYBeautifyFaceFilter * f =(KSYBeautifyFaceFilter*)_curFilter;
        if (sender == _filterParam1 ){
            f.grindRatio = _filterParam1.normalValue;
        }
        if (sender == _filterParam2 ) {
            f.whitenRatio = _filterParam2.normalValue;
        }
        if (sender == _filterParam3 ) {  // 红润参数
            f.ruddyRatio = _filterParam3.normalValue;
        }
    }
    else if ( _curIdx == 5 ){
        GPUImageFilterGroup * fg = (GPUImageFilterGroup *)_curFilter;
        KSYBeautifyProFilter    * bf = (KSYBeautifyProFilter *)[fg filterAtIndex:0];
        KSYBuildInSpecialEffects * sf = (KSYBuildInSpecialEffects *)[fg filterAtIndex:1];
        if (sender == _filterParam1 ){
            bf.grindRatio = _filterParam1.normalValue;
        }
        if (sender == _filterParam2 ) {
            bf.whitenRatio = _filterParam2.normalValue;
        }
        if (sender == _filterParam3 ) {  // 特效参数
            [sf setIntensity:_filterParam3.normalValue];
        }
    }
    [super onSlider:sender];
}

#pragma mark - effect picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1; // 单列
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    return _effectNames.count;//
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    return [_effectNames objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    _curEffectIdx = row;
    if (! [_curFilter isMemberOfClass:[GPUImageFilterGroup class]]){
        return;
    }
    GPUImageFilterGroup * fg = (GPUImageFilterGroup *)_curFilter;
    if (![fg.terminalFilter isMemberOfClass:[KSYBuildInSpecialEffects class]]) {
        return;
    }
    KSYBuildInSpecialEffects * sf = (KSYBuildInSpecialEffects *)fg.terminalFilter;
    [sf setSpecialEffectsIdx:_curEffectIdx];
}

-(void)downloadGPUResource{ // 下载资源文件
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    _gpuResourceDir=[NSHomeDirectory() stringByAppendingString:@"/Documents/GPUResource/"];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:_gpuResourceDir]) {
        [fileManager createDirectoryAtPath:_gpuResourceDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    NSString *zipPath = [_gpuResourceDir stringByAppendingString:@"KSYGPUResource.zip"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
        return; // already downloaded
    }
    NSString *zipUrl = @"https://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios/KSYLive_iOS_Resource/KSYGPUResource.zip";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url =[NSURL URLWithString:zipUrl];
        NSData *data =[NSData dataWithContentsOfURL:url];
        [data writeToFile:zipPath atomically:YES];
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        [zipArchive UnzipOpenFile:zipPath ];
        [zipArchive UnzipFileTo:_gpuResourceDir overWrite:YES];
        [zipArchive UnzipCloseFile];
    });
}

@end
