// 来自 https://github.com/kingsic/SGQRCode/tree/master/SGQRCodeExample/Controller/WCQRCodeVC.h
#import <UIKit/UIKit.h>
#import <React/RCTBridgeModule.h>

@interface QrScanViewController : UIViewController
  @property(nonatomic, copy)RCTPromiseResolveBlock resolveBlock;
  @property(nonatomic, copy)RCTPromiseRejectBlock rejectBlock;

  @property(nonatomic, copy) NSString *scanTip;
@end
