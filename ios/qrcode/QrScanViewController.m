#import "QrScanViewController.h"
#import "SGQRCode.h"

@interface QrScanViewController () {
  SGQRCodeObtain *obtain;
}
@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) UIButton *flashlightBtn;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UIButton *closeLabel;
@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation QrScanViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  /// 二维码开启方法
  [obtain startRunningWithBefore:nil completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.scanView removeTimer];
  [self removeFlashlightBtn];
  [obtain stopRunning];
}

- (void)dealloc {
  NSLog(@"WCQRCodeVC - dealloc");
  [self removeScanningView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.view.backgroundColor = [UIColor blackColor];
  obtain = [SGQRCodeObtain QRCodeObtain];
  
  [self setupQRCodeScan];
  [self setupNavigationBar];
  
  //[self.view addSubview:self.flashlightBtn];
  [self.view addSubview:self.scanView];
  [self.view addSubview:self.promptLabel];
  [self.view addSubview:self.closeLabel];
  /// 为了 UI 效果
  [self.view addSubview:self.bottomView];
}

- (void)setupQRCodeScan {
  __weak typeof(self) weakSelf = self;
  
  SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
  configure.sampleBufferDelegate = YES;
  [obtain establishQRCodeObtainScanWithController:self configure:configure];
  [obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
    if (result) {
      NSLog(@"正在处理");
      [obtain stopRunning];
      [obtain playSoundName:@"SGQRCode.bundle/sound.caf"];
      
      
      NSLog(@"扫码结果：%@",result);
      
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"关闭页面 haha");
        
        UIViewController * rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        
        [rootViewController dismissViewControllerAnimated:true completion:^{
          weakSelf.resolveBlock(result);
        }];
        
      });
      
      
    }
  }];
  [obtain setBlockWithQRCodeObtainScanBrightness:^(SGQRCodeObtain *obtain, CGFloat brightness) {
    if (brightness < - 1) {
      [weakSelf.view addSubview:weakSelf.flashlightBtn];
    } else {
      if (weakSelf.isSelectedFlashlightBtn == NO) {
        [weakSelf removeFlashlightBtn];
      }
    }
  }];
}

- (void)setupNavigationBar {
  // self.navigationItem.title = @"扫一扫";
  [self.navigationController setNavigationBarHidden:true animated:NO];
}

- (SGQRCodeScanView *)scanView {
  if (!_scanView) {
    _scanView = [[SGQRCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.9 * self.view.frame.size.height)];
  }
  return _scanView;
}

- (void)removeScanningView {
  [self.scanView removeTimer];
  [self.scanView removeFromSuperview];
  self.scanView = nil;
}

- (UIButton *)closeLabel {
  if (!_closeLabel) {
    // 添加闪光灯按钮
    _closeLabel = [UIButton buttonWithType:(UIButtonTypeCustom)];
    CGFloat flashlightBtnW = 24;
    CGFloat flashlightBtnH = 24;
    CGFloat flashlightBtnX = 10;
    CGFloat flashlightBtnY = 10;
    _closeLabel.frame = CGRectMake(flashlightBtnX, flashlightBtnY, flashlightBtnW, flashlightBtnH);
    
    //[_closeLabel setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeLabel setBackgroundImage:[UIImage imageNamed:@"close"] forState:(UIControlStateNormal)];
    
    [_closeLabel addTarget:self action:@selector(closeBtn_action:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _closeLabel;
}

- (void)closeBtn_action:(UIButton *)button {
  NSLog(@"点击了关闭按钮。。。");
  UIViewController * rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
  
  [rootViewController dismissViewControllerAnimated:true completion:nil];
}


- (UILabel *)promptLabel {
  if (!_promptLabel) {
    _promptLabel = [[UILabel alloc] init];
    _promptLabel.backgroundColor = [UIColor clearColor];
    CGFloat promptLabelX = 0;
    CGFloat promptLabelY = 0.73 * self.view.frame.size.height;
    CGFloat promptLabelW = self.view.frame.size.width;
    CGFloat promptLabelH = 25;
    _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    _promptLabel.text = self.scanTip;
  }
  return _promptLabel;
}

- (UIView *)bottomView {
  if (!_bottomView) {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.scanView.frame))];
    _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
  }
  return _bottomView;
}

#pragma mark - - - 闪光灯按钮
- (UIButton *)flashlightBtn {
  if (!_flashlightBtn) {
    // 添加闪光灯按钮
    _flashlightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    CGFloat flashlightBtnW = 30;
    CGFloat flashlightBtnH = 30;
    CGFloat flashlightBtnX = 0.5 * (self.view.frame.size.width - flashlightBtnW);
    CGFloat flashlightBtnY = 0.55 * self.view.frame.size.height;
    _flashlightBtn.frame = CGRectMake(flashlightBtnX, flashlightBtnY, flashlightBtnW, flashlightBtnH);
    [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightOpenImage"] forState:(UIControlStateNormal)];
    [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightCloseImage"] forState:(UIControlStateSelected)];
    [_flashlightBtn addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _flashlightBtn;
}

- (void)flashlightBtn_action:(UIButton *)button {
  if (button.selected == NO) {
    [obtain openFlashlight];
    self.isSelectedFlashlightBtn = YES;
    button.selected = YES;
  } else {
    [self removeFlashlightBtn];
  }
}

- (void)removeFlashlightBtn {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [obtain closeFlashlight];
    self.isSelectedFlashlightBtn = NO;
    self.flashlightBtn.selected = NO;
    [self.flashlightBtn removeFromSuperview];
  });
}

@end
